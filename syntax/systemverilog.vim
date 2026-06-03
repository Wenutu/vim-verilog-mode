" Vim syntax file
" Language: SystemVerilog
" Maintainer: vim-verilog-mode

if exists('b:current_syntax')
  finish
endif

execute 'source ' . fnameescape(expand('<sfile>:p:h') . '/verilog.vim')
unlet b:current_syntax

syntax sync minlines=120

syntax keyword systemverilogStatement always_comb always_ff always_latch
syntax keyword systemverilogStatement checker endchecker class endclass clocking endclocking
syntax keyword systemverilogStatement config endconfig covergroup endgroup interface endinterface
syntax keyword systemverilogStatement package endpackage program endprogram property endproperty
syntax keyword systemverilogStatement sequence endsequence modport final
syntax keyword systemverilogStatement accept_on assert assume before bind cover expect
syntax keyword systemverilogStatement first_match ignore_bins illegal_bins reject_on restrict
syntax keyword systemverilogStatement s_always s_eventually s_nexttime s_until s_until_with
syntax keyword systemverilogStatement sync_accept_on sync_reject_on throughout until until_with
syntax keyword systemverilogStatement alias break continue eventually implies nexttime strong weak

syntax keyword systemverilogConditional iff inside intersect matches randcase randsequence
syntax keyword systemverilogRepeat do foreach wait_order

syntax keyword systemverilogType bit byte chandle enum int logic longint nettype shortint
syntax keyword systemverilogType shortreal string struct type typedef union void
syntax keyword systemverilogType uwire var interconnect timeprecision timeunit
syntax keyword systemverilogDirection ref
syntax keyword systemverilogStorage automatic const context extern export import local
syntax keyword systemverilogStorage protected pure rand randc static super this virtual
syntax keyword systemverilogStorage tagged virtual with
syntax keyword systemverilogModifier bins binsof constraint coverpoint cross dist extends
syntax keyword systemverilogModifier global implements let new null packed priority soft
syntax keyword systemverilogModifier solve unique unique0 untyped weak wildcard within
syntax keyword systemverilogModifier ignore_bins illegal_bins randsequence randcase

syntax match systemverilogObjectMethod "\.\s*\(and\|delete\|exists\|find\|find_first\|find_first_index\|find_index\|find_last\|find_last_index\|first\|insert\|last\|max\|min\|next\|num\|or\|pop_back\|pop_front\|prev\|product\|push_back\|push_front\|reverse\|rsort\|shuffle\|size\|sort\|sum\|xor\)\>\s*("he=e-1
syntax match systemverilogAnnotation "@[A-Za-z_][A-Za-z0-9_$]*\>"

highlight default link systemverilogStatement Statement
highlight default link systemverilogConditional Conditional
highlight default link systemverilogRepeat Repeat
highlight default link systemverilogType Type
highlight default link systemverilogDirection StorageClass
highlight default link systemverilogStorage StorageClass
highlight default link systemverilogModifier Keyword
highlight default link systemverilogObjectMethod Function
highlight default link systemverilogAnnotation PreProc

let b:current_syntax = 'systemverilog'
