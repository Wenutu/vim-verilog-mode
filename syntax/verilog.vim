" Vim syntax file
" Language:    Verilog and SystemVerilog
" Maintainer:  Vim Community
" Last Change: 2023
" Description: A comprehensive syntax file for both Verilog and SystemVerilog.

" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" --- Basic Setup ---
" Store cpoptions
let s:cpo_save = &cpo
set cpo&vim

" Override 'iskeyword' to include characters like '$' and '_'
setlocal iskeyword=@,48-57,_,$,192-255

" --- Options ---
" To disable code folding, add `let g:verilog_fold = 0` to your .vimrc
if !exists("g:verilog_fold")
  let g:verilog_fold = 1
endif

" To disable highlighting of ALL_CAPS words as constants
if !exists("g:verilog_disable_constant_highlight")
  let g:verilog_disable_constant_highlight = 0
endif

" --- Keyword Definitions ---

" Verilog-2001 and SystemVerilog Statements
syn keyword verilogStatement    alias always always_comb always_ff always_latch assign automatic begin deassign defparam disable edge else fork forever generate initial join localparam parameter release repeat wait
syn keyword verilogStatement    assert assume bind cover final force import export package program protected specify specparam

" Control Flow and Conditionals
syn keyword verilogConditional  if else case casex casez default
syn keyword verilogRepeat       for while foreach do return break continue

" Data Types
syn keyword verilogType         buf bufif0 bufif1 byte cell chandle cmos const class deassign defparam design disable edge endconfig endgenerate endprimitive endtable event force fork genvar highz0 highz1 ifnone incdir include initial inout input instance integer large liblist library localparam macromodule medium nand negedge nmos nor noshowcancelled not notif0 notif1 or output parameter pmos posedge primitive pull0 pull1 pulldown pullup pulsestyle_onevent pulsestyle_ondetect rcmos real realtime reg release rnmos rpmos rtran rtranif0 rtranif1 scalared showcancelled signed small specparam strong0 strong1 supply0 supply1 table time tran tranif0 tranif1 tri tri0 tri1 triand trior trireg unsigned use vectored wait wand weak0 weak1 wire wor xnor xor semaphore mailbox bit logic int longint shortint shortreal string struct tagged time typedef union untyped var virtual void enum

" Storage Classes
syn keyword verilogStorageClass static extern automatic

" Pre-processor Directives and System Tasks
syn match   verilogSystemTask   "\$[a-zA-Z0-9_$]\+"
syn match   verilogCompilerDirective "`[a-zA-Z0-9_$]\+"

" Operators (as keywords for better highlighting)
syn keyword verilogOperator     and or not nand nor xor xnor

" Special Keywords and Objects
syn keyword verilogTodo         contained TODO FIXME XXX
syn keyword verilogObject       super null this

" --- Regions and Matches ---

" Numbers (binary, octal, decimal, hex, real)
syn match   verilogNumber   "\<\d\+'[sS]\?[bB][0-1_xXzZ?]\+\>"
syn match   verilogNumber   "\<\d\+'[sS]\?[oO][0-7_xXzZ?]\+\>"
syn match   verilogNumber   "\<\d\+'[sS]\?[dD][0-9_xXzZ?]\+\>"
syn match   verilogNumber   "\<\d\+'[sS]\?[hH][0-9a-fA-F_xXzZ?]\+\>"
syn match   verilogNumber   "\<[0-9][0-9_]*\>"
syn match   verilogNumber   "\<[0-9_]\+\.[0-9_]*\([eE][+-]\?[0-9_]\+\)\?\>"

" Constants (e.g., PARAM_NAME)
if !g:verilog_disable_constant_highlight
  syn match   verilogConstant "\<[A-Z][A-Z0-9_]*\>"
endif

" Strings
syn region  verilogString   start=+"+ skip=+\\"+ end=+"+

" Attributes
syn region  verilogAttribute start="(\*" end="\*)"

" Comments
syn region  verilogComment  start="/\*" end="\*/" contains=verilogTodo fold
syn match   verilogComment  "//.*" contains=verilogTodo
syn cluster verilogCommentGroup contains=verilogComment

" Synopsys Directives (special comments)
syn match   verilogDirective "//\s*synopsys\>.*$"
syn region  verilogDirective start="/\*\s*synopsys\>" end="\*/"

" --- Code Folding ---
if g:verilog_fold
  syn region verilogFoldBlock  start="\<begin\>" end="\<end\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldBlock  start="\<fork\>" end="\<join\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldBlock  start="\<case\>" end="\<endcase\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<module\>" end="\<endmodule\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<primitive\>" end="\<endprimitive\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<function\>" end="\<endfunction\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<task\>" end="\<endtask\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<class\>" end="\<endclass\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<package\>" end="\<endpackage\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<program\>" end="\<endprogram\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<interface\>" end="\<endinterface\>" transparent fold contains=ALLBUT,@verilogCommentGroup
  syn region verilogFoldModule start="\<config\>" end="\<endconfig\>" transparent fold contains=ALLBUT,@verilogCommentGroup
endif

" --- Syntax Highlighting Links ---
if version >= 508 || !exists("did_verilog_syn_inits")
  if version < 508
    let did_verilog_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink verilogStatement         Statement
  HiLink verilogConditional       Conditional
  HiLink verilogRepeat            Repeat
  HiLink verilogType              Type
  HiLink verilogStorageClass      StorageClass
  HiLink verilogOperator          Operator
  HiLink verilogObject            Identifier
  HiLink verilogSystemTask        Special
  HiLink verilogCompilerDirective PreProc
  HiLink verilogConstant          Constant
  HiLink verilogString            String
  HiLink verilogNumber            Number
  HiLink verilogComment           Comment
  HiLink verilogDirective         SpecialComment
  HiLink verilogTodo              Todo
  HiLink verilogAttribute         SpecialComment

  delcommand HiLink
endif

" --- Finalization ---
let b:current_syntax = "verilog"

" Restore cpoptions
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=2 sw=2 et