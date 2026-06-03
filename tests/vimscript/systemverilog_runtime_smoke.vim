" Smoke tests for the built-in SystemVerilog runtime files.

let s:root = fnamemodify(expand('<sfile>:p:h'), ':h:h')
execute 'set runtimepath^=' . fnameescape(s:root)
call delete(s:root . '/tests/systemverilog_runtime_smoke.fail')
call delete(s:root . '/tests/systemverilog_runtime_smoke.ok')
syntax on
filetype plugin indent on
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

execute 'edit ' . fnameescape(s:root . '/tests/fixtures/complex_systemverilog.sv')
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
  call assert_equal(a:amount, SystemVerilogModeIndent(l:num), 'indent for line ' . l:num . ': ' . getline(l:num))
endfunction

call assert_equal('systemverilog', &filetype)
call assert_equal('systemverilog', get(b:, 'current_syntax', ''))
call assert_equal('SystemVerilogModeIndent(v:lnum)', &l:indentexpr)
call assert_equal(1, &l:expandtab)
call assert_equal(4, &l:tabstop)
call assert_equal(4, &l:shiftwidth)
call assert_equal(4, &l:softtabstop)
call assert_equal(2, exists(':VerilogAutoAdd'))
call assert_equal('<Plug>VerilogModeAdd', maparg('ta', 'n'))

call s:CheckSyntax('interface', 'systemverilogStatement')
call s:CheckSyntax('logic', 'systemverilogType')
call s:CheckSyntax('modport', 'systemverilogStatement')
call s:CheckSyntax('typedef', 'systemverilogType')
call s:CheckSyntax('struct', 'systemverilogType')
call s:CheckSyntax('class', 'systemverilogStatement')
call s:CheckSyntax('rand', 'systemverilogStorage')
call s:CheckSyntax('constraint', 'systemverilogModifier')
call s:CheckSyntax('foreach', 'systemverilogRepeat')
call s:CheckSyntax('always_ff', 'systemverilogStatement')
call s:CheckSyntax('unique', 'systemverilogModifier')
call s:CheckSyntax('property', 'systemverilogStatement')
call s:CheckSyntax('\$error', 'verilogSystemTask')

call s:CheckIndent('^\s*logic valid', 4)
call s:CheckIndent('^\s*input ready', 8)
call s:CheckIndent('^endinterface', 0)
call s:CheckIndent('^\s*typedef enum', 4)
call s:CheckIndent('^\s*PKT_IDLE', 8)
call s:CheckIndent('^class packet_driver', 0)
call s:CheckIndent('^\s*rand bit', 4)
call s:CheckIndent('^\s*burst_len inside', 8)
call s:CheckIndent('^\s*this.vif', 8)
call s:CheckIndent('^\s*foreach', 8)
call s:CheckIndent('^\s*vif.valid <= 1''b1', 16)
call s:CheckIndent('^endclass', 0)
call s:CheckIndent('^\s*import packet_pkg', 4)
call s:CheckIndent('^\s*parameter int WIDTH', 8)
call s:CheckIndent('^\s*packet_state_e state', 4)
call s:CheckIndent('^\s*if (!rst_n)', 8)
call s:CheckIndent('^\s*unique case', 12)
call s:CheckIndent('^\s*PKT_IDLE: state', 16)
call s:CheckIndent('^\s*bus.valid |->', 8)
call s:CheckIndent('^\s*else \$error', 8)
call s:CheckIndent('^\s*endproperty', 4)
call s:CheckIndent('^\s*coverpoint state', 8)
call s:CheckIndent('^endmodule', 0)

let s:before_reindent = getline(1, '$')
silent normal! gg=G
call assert_equal(s:before_reindent, getline(1, '$'), 'gg=G should keep the SystemVerilog fixture stable')

if !empty(v:errors)
  call writefile(v:errors, s:root . '/tests/systemverilog_runtime_smoke.fail')
  cquit
endif

call writefile(['systemverilog runtime smoke test passed'], s:root . '/tests/systemverilog_runtime_smoke.ok')
qa!
