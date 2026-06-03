`timescale 1ns/1ps

interface packet_if #(parameter WIDTH = 32) (input logic clk);
    logic valid;
    logic ready;
    logic [WIDTH-1:0] data;

    modport master (
        input ready,
        output valid,
        output data
    );

    modport slave (
        input valid,
        input data,
        output ready
    );
endinterface

package packet_pkg;
    typedef enum logic [1:0] {
        PKT_IDLE,
        PKT_BUSY,
        PKT_DONE
    } packet_state_e;

    typedef struct packed {
        logic [7:0] opcode;
        logic [23:0] payload;
    } packet_word_t;
endpackage

class packet_driver;
    rand bit [7:0] burst_len;
    virtual packet_if.master vif;

    constraint c_burst_len {
        burst_len inside {[1:16]};
    }

    function new(virtual packet_if.master vif);
        this.vif = vif;
    endfunction

    task automatic drive(packet_pkg::packet_word_t word);
        foreach (word.payload[idx]) begin
            if (idx < burst_len) begin
                vif.valid <= 1'b1;
            end else begin
                vif.valid <= 1'b0;
            end
        end
    endtask
endclass

module complex_systemverilog_test
    import packet_pkg::*;
    #(
        parameter int WIDTH = 32
    )
    (
        input logic clk,
        input logic rst_n,
        packet_if.master bus
    );

    packet_state_e state;
    packet_word_t current_word;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= PKT_IDLE;
        end else begin
            unique case (state)
                PKT_IDLE: state <= bus.valid ? PKT_BUSY : PKT_IDLE;
                PKT_BUSY: state <= bus.ready ? PKT_DONE : PKT_BUSY;
                default: state <= PKT_IDLE;
            endcase
        end
    end

    property p_valid_until_ready;
        @(posedge clk) disable iff (!rst_n)
        bus.valid |-> ##[1:4] bus.ready;
    endproperty

    assert property (p_valid_until_ready)
        else $error("valid dropped before ready");

    covergroup cg_state @(posedge clk);
        coverpoint state {
            bins all_states[] = {PKT_IDLE, PKT_BUSY, PKT_DONE};
        }
    endgroup

endmodule
