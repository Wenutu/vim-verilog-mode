" Vim indent file
" Language:     Verilog & SystemVerilog (Unified)
" Maintainer:   Wenutu Shi <wenutushi@outlook.com>
" Original Authors: Chih-Tsun Huang and contributors
" Last Change:  Sun Aug 25 2024
" Version:      2.0

" DESCRIPTION:
" This single, self-contained file provides comprehensive indentation for
" both Verilog and SystemVerilog. It is based on the more feature-rich
" SystemVerilog indent logic to support modern language constructs.
"
" SPECIAL BEHAVIOR:
" If the 'foldmethod' is set to 'marker', this indent script will not activate.
" This is to prevent interference with manually managed code folding.
"
" CONFIGURABLE BUFFER VARIABLES:
"   b:verilog_indent_width:   Set a custom indent width (defaults to 'shiftwidth').
"   b:verilog_indent_modules: Indent width after a 'module' declaration (defaults to 0).
"   b:verilog_indent_ifdef_off: Set to 1 to disable indentation for `ifdef blocks.
"   b:verilog_indent_verbose: Set to 1 to echo debug messages for indentation.

" If user is using marker-based folding, respect that and do not apply auto-indent.
if &foldmethod == 'marker'
  finish
endif

" Only load this indent file once.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetVerilogIndent()
" Set indentkeys for both Verilog and SystemVerilog constructs.
setlocal indentkeys=!^F,o,O,0),0},=begin,=end,=join,=endcase,=join_any,=join_none
setlocal indentkeys+==endmodule,=endfunction,=endtask,=endspecify
setlocal indentkeys+==endclass,=endpackage,=endsequence,=endclocking
setlocal indentkeys+==endinterface,=endgroup,=endprogram,=endproperty,=endchecker
setlocal indentkeys+==`else,=`elsif,=`endif

let b:undo_indent = "setlocal indentexpr< indentkeys<"

" Only define the function once.
if exists("*GetVerilogIndent")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:multiple_comment = 0
let s:open_statement = 0

function GetVerilogIndent()

  " --- Setup Indent Variables ---
  if exists('b:verilog_indent_width')
    let l:offset = b:verilog_indent_width
  else
    let l:offset = shiftwidth()
  endif
  if exists('b:verilog_indent_modules')
    let l:indent_modules = l:offset
  else
    let l:indent_modules = 0
  endif
  if exists('b:verilog_indent_ifdef_off')
    let l:indent_ifdef = 0
  else
    let l:indent_ifdef = 1
  endif
  if exists('b:verilog_indent_verbose')
    let l:vverb_str = 'INDENT VERBOSE: '. v:lnum .":"
    let l:vverb = 1
  else
    let l:vverb = 0
  endif

  " --- Initialization ---
  let l:lnum = prevnonblank(v:lnum - 1)
  if l:lnum == 0
    return 0
  endif

  let l:curr_line  = getline(v:lnum)
  let l:last_line  = getline(l:lnum)
  let l:lnum2      = prevnonblank(l:lnum - 1)
  let l:last_line2 = getline(l:lnum2)
  let l:ind        = indent(l:lnum)

  " Regular expressions for matching
  let l:vlog_openstat = '\(\<or\>\|\([*/]\)\@<![*(,{><+-/%^&|!=?:]\([*/]\)\@!\)'
  let l:vlog_comment  = '\(//.*\|/\*.*\*/\s*\)'

  " --- Handle Multi-line Comments ---
  if l:curr_line =~ '^\s*/\*' && l:curr_line !~ '/\*.\{-}\*/'
    let s:multiple_comment += 1
    if l:vverb | echom l:vverb_str "Start of multi-line comment" | endif
  elseif l:curr_line =~ '\*/\s*$' && l:curr_line !~ '/\*.\{-}\*/'
    let s:multiple_comment -= 1
    if l:vverb | echom l:vverb_str "End of multi-line comment" | endif
    return l:ind
  endif
  if s:multiple_comment > 0
    return l:ind
  endif

  " --- Calculate Indent Based on Previous Line ---

  " Increase indent for block starters
  if l:last_line =~ '^\s*\(end\)\=\s*`\@<!\<\(if\|else\)\>' ||
    \ l:last_line =~ '^\s*\<\(for\|while\|repeat\|case\%[[zx]]\|do\|foreach\|forever\|randcase\)\>' ||
    \ l:last_line =~ '^\s*\<\(always\%(_comb\|_ff\|_latch\)\=\)\>' ||
    \ l:last_line =~ '^\s*\<\(initial\|specify\|fork\|final\)\>'
    if l:last_line !~ '\(;\|\<end\>\|\*/\)\s*' . l:vlog_comment . '*$' ||
      \ l:last_line =~ '\(//\|/\*\).*\(;\|\<end\>\)\s*' . l:vlog_comment . '*$'
      let l:ind = l:ind + l:offset
      if l:vverb | echom l:vverb_str "Indent after a control flow block." | endif
    endif
  " Increase indent for definition blocks (function, class, etc.)
  elseif l:last_line =~ '^\s*\<\(function\|task\|class\|package\|sequence\|clocking\|interface\)\>' ||
    \ l:last_line =~ '^\s*\(\w\+\s*:\)\=\s*\<covergroup\>' ||
    \ l:last_line =~ '^\s*\<\(property\|checker\|program\)\>' ||
    \ (l:last_line =~ '^\s*\<virtual\>' && l:last_line =~ '\<\(function\|task\|class\|interface\)\>') ||
    \ (l:last_line =~ '^\s*\<pure\>' && l:last_line =~ '\<virtual\>' && l:last_line =~ '\<\(function\|task\)\>')
    if l:last_line !~ '\<end\>\s*' . l:vlog_comment . '*$' ||
      \ l:last_line =~ '\(//\|/\*\).*\(;\|\<end\>\)\s*' . l:vlog_comment . '*$'
      let l:ind = l:ind + l:offset
      if l:vverb | echom l:vverb_str "Indent after a definition block." | endif
    endif
  " Indent after 'module'
  elseif l:last_line =~ '^\s*\(\<extern\>\s*\)\=\<module\>'
    let l:ind = l:ind + l:indent_modules
    if l:vverb && l:indent_modules | echom l:vverb_str "Indent after module statement." | endif
    if l:last_line =~ '[(,]\s*' . l:vlog_comment . '*$' && l:last_line !~ '\(//\|/\*\).*[(,]\s*' . l:vlog_comment . '*$'
      let l:ind = l:ind + l:offset
      if l:vverb | echom l:vverb_str "Indent after multi-line module statement." | endif
    endif
  " Indent after a 'begin', '{', or '('
  elseif l:last_line =~ '\(\<begin\>\)\(\s*:\s*\w\+\)*' . l:vlog_comment . '*$' ||
    \ (l:last_line =~ '[{(]' . l:vlog_comment . '*$' && l:last_line !~ '\(//\|/\*\).*[{(]')
    let l:ind = l:ind + l:offset
    if l:vverb | echom l:vverb_str "Indent after begin/{/(." | endif
  " De-indent for one-line blocks (e.g., if (cond) statement;)
  elseif (l:last_line !~ '\<begin\>' || l:last_line =~ '\(//\|/\*\).*\<begin\>') &&
    \ l:last_line2 =~ '\<\(`\@<!if\|`\@<!else\|for\|always\|initial\|do\|foreach\|forever\|final\)\>.*' . l:vlog_comment . '*$' &&
    \ l:last_line2 !~ '\(//\|/\*\).*\<\(`\@<!if\|`\@<!else\|for\|always\|initial\|do\|foreach\|forever\|final\)\>' &&
    \ l:last_line2 !~ l:vlog_openstat . '\s*' . l:vlog_comment . '*$' &&
    \ l:last_line2 !~ '\(;\|\<end\>\|\*/\)\s*' . l:vlog_comment . '*$'
    let l:ind = l:ind - l:offset
    if l:vverb | echom l:vverb_str "De-indent after a one-line block." | endif
  " Indent for multi-line statements
  elseif l:last_line =~ l:vlog_openstat . '\s*' . l:vlog_comment . '*$' &&
   \ l:last_line !~ '\(//\|/\*\).*' . l:vlog_openstat . '\s*$' &&
   \ l:last_line2 !~ l:vlog_openstat . '\s*' . l:vlog_comment . '*$'
    let l:ind = l:ind + l:offset
    let s:open_statement = 1
    if l:vverb | echom l:vverb_str "Indent after an open statement." | endif
  " Indent `ifdef blocks
  elseif l:last_line =~ '^\s*`\<\(ifn\?def\|elsif\|else\)\>' && l:indent_ifdef
    let l:ind = l:ind + l:offset
    if l:vverb | echom l:vverb_str "Indent after `ifdef/`elsif/`else." | endif
  endif


  " --- Adjust Indent for Current Line ---

  " De-indent for block enders
  if l:curr_line =~ '^\s*\<\(join\%(_any\|_none\)\=\|end\|endcase\)\>' ||
      \ l:curr_line =~ '^\s*\<\(end\%(function\|task\|specify\|class\|package\|sequence\|clocking\|interface\|group\|property\|checker\|program\)\)\>'
    let l:ind = l:ind - l:offset
    if l:vverb | echom l:vverb_str "De-indent for a block end." | endif
    if s:open_statement == 1
      let l:ind = l:ind - l:offset
      let s:open_statement = 0
      if l:vverb | echom l:vverb_str "De-indent for closing an open statement." | endif
    endif
  " De-indent for `endmodule`
  elseif l:curr_line =~ '^\s*\<endmodule\>'
    let l:ind = l:ind - l:indent_modules
    if l:vverb && l:indent_modules | echom l:vverb_str "De-indent for endmodule." | endif
  " De-indent for a standalone 'begin' that starts a block
  elseif l:curr_line =~ '^\s*\<begin\>'
    if l:last_line !~ '^\s*\<\(function\|task\|specify\|module\|class\|package\|sequence\|clocking\|interface\|covergroup\|property\|checker\|program\)\>' &&
      \ l:last_line !~ '^\s*\()*\s*;\|)\+\)\s*' . l:vlog_comment . '*$' &&
      \ (l:last_line =~ '\<\(`\@<!if\|`\@<!else\|for\|case\%[[zx]]\|always\%(_comb\|_ff\|_latch\)\=\|initial\|do\|foreach\|forever\|randcase\|final\)\>' ||
      \ l:last_line =~ ')\s*' . l:vlog_comment . '*$' || l:last_line =~ l:vlog_openstat . '\s*' . l:vlog_comment . '*$')
      let l:ind = l:ind - l:offset
      if l:vverb | echom l:vverb_str "De-indent a standalone begin." | endif
      if s:open_statement == 1
        let l:ind = l:ind - l:offset
        let s:open_statement = 0
        if l:vverb | echom l:vverb_str "De-indent for closing open statement before begin." | endif
      endif
    endif
  " De-indent `elsif/`else/`endif
  elseif l:curr_line =~ '^\s*`\<\(elsif\|else\|endif\)\>' && l:indent_ifdef
    let l:ind = l:ind - l:offset
    if l:vverb | echom l:vverb_str "De-indent `elsif/`else/`endif." | endif
  endif

  return l:ind
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:sw=2 ts=2 et