`timescale 1ns/1ps
`define COMPLEX_VERILOG_TEST 1

// TODO: fixture for syntax and indentation smoke tests.
module complex_verilog_test
    #(
        parameter WIDTH = 16,
        parameter DEPTH = 4,
        parameter RESET_VALUE = 16'h00ff
    )
    (
        input wire clk,
        input wire rst_n,
        input wire enable,
        input wire [WIDTH-1:0] data_i,
        output reg [WIDTH-1:0] data_o
    );

    localparam ADDR_W = 2;

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_W-1:0] wr_ptr;
    integer idx;

    /* Block comment with keywords that should not affect indent:
     * module begin endcase endmodule
     */

    function [WIDTH-1:0] mix_word;
        input [WIDTH-1:0] word;
        input [ADDR_W-1:0] salt;
        begin
            mix_word = word ^ {{(WIDTH-ADDR_W){1'b0}}, salt};
        end
    endfunction

    task automatic clear_memory;
        integer i;
        begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] = RESET_VALUE;
            end
        end
    endtask

    generate
        genvar g;
        for (g = 0; g < DEPTH; g = g + 1) begin : gen_debug
            wire selected = wr_ptr == g[ADDR_W-1:0];
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= {ADDR_W{1'b0}};
            data_o <= RESET_VALUE;
            clear_memory();
        end else if (enable) begin
            mem[wr_ptr] <= mix_word(data_i, wr_ptr);
            wr_ptr <= wr_ptr + 1'b1;
            case (wr_ptr)
                2'b00: data_o <= mem[0];
                2'b01: data_o <= mem[1];
                2'b10: data_o <= mem[2];
                default: data_o <= data_i;
            endcase
        end else begin
            data_o <= data_o;
        end
    end

`ifdef COMPLEX_VERILOG_TEST
    initial begin
        fork
            begin
                $display("complex_verilog_test WIDTH=%0d", WIDTH);
            end
            begin
                #5 $display("DEPTH=%0d", DEPTH);
            end
        join
    end
`endif

endmodule
