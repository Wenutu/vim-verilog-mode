" Vim syntax file
" Language: Verilog
" Maintainer: vim-verilog-mode

if exists('b:current_syntax')
  finish
endif

syntax case match
syntax sync minlines=80

syntax keyword verilogTodo TODO FIXME XXX contained

syntax region verilogBlockComment start="/\*" end="\*/" contains=verilogTodo,@Spell
syntax match verilogLineComment "//.*" contains=verilogTodo,@Spell
syntax region verilogString start=+"+ skip=+\\\\\|\\"+ end=+"+
syntax region verilogAttribute start="(\*" end="\*)" contains=verilogTodo
syntax match verilogEscapedIdentifier "\\\S\+\s"he=e-1

syntax match verilogPreProc "`[A-Za-z_][A-Za-z0-9_$]*\>"
syntax match verilogInclude "`include\>"
syntax match verilogDefine "`define\>"
syntax match verilogConditionalDirective "`\(ifdef\|ifndef\|elsif\|else\|endif\)\>"

syntax keyword verilogStatement module endmodule macromodule primitive endprimitive
syntax keyword verilogStatement generate endgenerate specify endspecify table endtable
syntax keyword verilogStatement function endfunction task endtask initial always
syntax keyword verilogStatement begin end fork join
syntax keyword verilogStatement assign deassign force release defparam disable wait return
syntax keyword verilogStatement cell config design edge endconfig incdir instance liblist library use
syntax keyword verilogStatement ifnone noshowcancelled pulsestyle_ondetect pulsestyle_onevent showcancelled
syntax keyword verilogStatement buf bufif0 bufif1 cmos nmos pmos rcmos rnmos rpmos
syntax keyword verilogStatement tran tranif0 tranif1 rtran rtranif0 rtranif1
syntax keyword verilogStatement and nand or nor xor xnor not notif0 notif1
syntax keyword verilogStatement pullup pulldown

syntax keyword verilogConditional if else case casex casez default endcase
syntax keyword verilogRepeat for forever repeat while

syntax keyword verilogType event genvar integer parameter localparam real realtime reg
syntax keyword verilogType signed specparam supply0 supply1 time tri tri0 tri1 triand
syntax keyword verilogType trior trireg unsigned wand wire wor
syntax keyword verilogDirection input output inout
syntax keyword verilogStrength highz0 highz1 large medium pull0 pull1 scalared small
syntax keyword verilogStrength strong0 strong1 vectored weak0 weak1

syntax match verilogNumber "\<\d[0-9_]*\>"
syntax match verilogNumber "\<\d[0-9_]*\(\.\d[0-9_]*\)\=\([eE][-+]\=\d[0-9_]*\)\=\>"
syntax match verilogNumber "\<\d[0-9_]*\s*'\s*[sS]\=[bBoOdDhH]\s*[0-9a-fA-F_xXzZ?_]\+\>"
syntax match verilogNumber "\<'[01xXzZ?]\>"
syntax match verilogReal "\<\d[0-9_]*\.\d[0-9_]*\([eE][-+]\=\d[0-9_]*\)\=\>"
syntax match verilogReal "\<\d[0-9_]*[eE][-+]\=\d[0-9_]*\>"

syntax match verilogSystemTask "\$[A-Za-z_][A-Za-z0-9_$]*\>"
syntax match verilogOperator "\(\~\|!\|%\|\^\|&\|\*\|+\|=\||\|?\|:\|<\|>\|-\|/[/*]\@!\)"
syntax match verilogDelimiter "[()[\]{},.;#@]"

highlight default link verilogTodo Todo
highlight default link verilogBlockComment Comment
highlight default link verilogLineComment Comment
highlight default link verilogString String
highlight default link verilogAttribute PreProc
highlight default link verilogEscapedIdentifier Identifier
highlight default link verilogPreProc PreProc
highlight default link verilogInclude Include
highlight default link verilogDefine Define
highlight default link verilogConditionalDirective PreCondit
highlight default link verilogStatement Statement
highlight default link verilogConditional Conditional
highlight default link verilogRepeat Repeat
highlight default link verilogType Type
highlight default link verilogDirection StorageClass
highlight default link verilogStrength Identifier
highlight default link verilogNumber Number
highlight default link verilogReal Float
highlight default link verilogSystemTask Function
highlight default link verilogOperator Operator
highlight default link verilogDelimiter Delimiter

let b:current_syntax = 'verilog'
