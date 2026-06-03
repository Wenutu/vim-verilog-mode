" Smoke tests for the built-in Verilog runtime files.

let s:root = fnamemodify(expand('<sfile>:p:h'), ':h:h')
execute 'set runtimepath^=' . fnameescape(s:root)
call delete(s:root . '/tests/verilog_runtime_smoke.fail')
call delete(s:root . '/tests/verilog_runtime_smoke.ok')
syntax on
filetype plugin indent on
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

execute 'edit ' . fnameescape(s:root . '/tests/fixtures/complex_verilog.v')
syntax sync fromstart

function! s:Line(pattern) abort
  let l:num = search(a:pattern, 'nw')
  call assert_true(l:num > 0, 'missing line matching: ' . a:pattern)
  return l:num
endfunction

function! s:SyntaxName(pattern) abort
  let l:num = s:Line(a:pattern)
  let l:col = match(getline(l:num), a:pattern) + 1
  call assert_true(l:col > 0, 'missing syntax column for: ' . a:pattern)
  return synIDattr(synID(l:num, l:col, 1), 'name')
endfunction

function! s:CheckSyntax(pattern, group) abort
  call assert_equal(a:group, s:SyntaxName(a:pattern), 'syntax group for ' . a:pattern)
endfunction

function! s:CheckIndent(pattern, amount) abort
  let l:num = s:Line(a:pattern)
  call assert_equal(a:amount, VerilogModeIndent(l:num), 'indent for line ' . l:num . ': ' . getline(l:num))
endfunction

call assert_equal('verilog', &filetype)
call assert_equal('verilog', get(b:, 'current_syntax', ''))
call assert_equal('VerilogModeIndent(v:lnum)', &l:indentexpr)
call assert_equal(1, &l:expandtab)
call assert_equal(4, &l:tabstop)
call assert_equal(4, &l:shiftwidth)
call assert_equal(4, &l:softtabstop)
call assert_equal(2, exists(':VerilogAutoAdd'))
call assert_equal('<Plug>VerilogModeAdd', maparg('ta', 'n'))

call s:CheckSyntax('`timescale', 'verilogPreProc')
call s:CheckSyntax('// TODO', 'verilogLineComment')
call s:CheckSyntax('module', 'verilogStatement')
call s:CheckSyntax('parameter', 'verilogType')
call s:CheckSyntax('input', 'verilogDirection')
call s:CheckSyntax('function', 'verilogStatement')
call s:CheckSyntax('for (i', 'verilogRepeat')
call s:CheckSyntax('case (wr_ptr)', 'verilogConditional')
call s:CheckSyntax('\$display', 'verilogSystemTask')
call s:CheckSyntax('"complex_verilog_test WIDTH=%0d"', 'verilogString')
call s:CheckSyntax("16'h00ff", 'verilogNumber')

call s:CheckIndent('^\s*parameter WIDTH', 8)
call s:CheckIndent('^\s*input wire clk', 8)
call s:CheckIndent('^\s*input \[WIDTH-1:0\] word', 8)
call s:CheckIndent('^\s*mix_word =', 12)
call s:CheckIndent('^\s*endfunction', 4)
call s:CheckIndent('^\s*for (i = 0', 12)
call s:CheckIndent('^\s*mem\[i\] = RESET_VALUE', 16)
call s:CheckIndent('^\s*endtask', 4)
call s:CheckIndent('^\s*genvar g', 8)
call s:CheckIndent('^\s*wire selected', 12)
call s:CheckIndent('^\s*if (!rst_n)', 8)
call s:CheckIndent('^\s*wr_ptr <= {ADDR_W', 12)
call s:CheckIndent('^\s*case (wr_ptr)', 12)
call s:CheckIndent('^\s*2''b00', 16)
call s:CheckIndent('^\s*endcase', 12)
call s:CheckIndent('^\s*fork', 8)
call s:CheckIndent('^\s*join', 8)
call s:CheckIndent('^endmodule', 0)

let s:before_reindent = getline(1, '$')
silent normal! gg=G
call assert_equal(s:before_reindent, getline(1, '$'), 'gg=G should keep the Verilog fixture stable')

if !empty(v:errors)
  call writefile(v:errors, s:root . '/tests/verilog_runtime_smoke.fail')
  cquit
endif

call writefile(['verilog runtime smoke test passed'], s:root . '/tests/verilog_runtime_smoke.ok')
qa!
