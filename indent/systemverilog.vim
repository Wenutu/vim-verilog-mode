" Vim indent file
" Language: SystemVerilog
" Maintainer: vim-verilog-mode

if exists('b:did_indent')
  finish
endif

execute 'source ' . fnameescape(expand('<sfile>:p:h') . '/verilog.vim')

setlocal indentexpr=SystemVerilogModeIndent(v:lnum)
setlocal indentkeys+=0=endclass,0=endclocking,0=endconfig,0=endgroup,0=endinterface,0=endpackage,0=endprogram,0=endproperty,0=endsequence,0=endchecker
let b:undo_indent = 'setlocal indentexpr< indentkeys<'

if exists('*SystemVerilogModeIndent')
  finish
endif

let s:sv_open_words = '^\s*\<\(class\|clocking\|config\|covergroup\|interface\|package\|program\|property\|sequence\|checker\)\>'
let s:sv_close_words = '^\s*\<\(endclass\|endclocking\|endconfig\|endgroup\|endinterface\|endpackage\|endprogram\|endproperty\|endsequence\|endchecker\)\>'

function! s:SVStripCommentsAndStrings(line) abort
  let l:line = substitute(a:line, '"\%([^"\\]\|\\.\)*"', '""', 'g')
  let l:line = substitute(l:line, '//.*$', '', '')
  return l:line
endfunction

function! s:SVIsOpen(line) abort
  let l:line = s:SVStripCommentsAndStrings(a:line)
  return l:line =~# s:sv_open_words && l:line !~# s:sv_close_words
endfunction

function! s:SVIsClose(line) abort
  return s:SVStripCommentsAndStrings(a:line) =~# s:sv_close_words
endfunction

function! s:SVIndentCache() abort
  if !exists('b:systemverilog_mode_indent_cache')
        \ || get(b:systemverilog_mode_indent_cache, 'tick', -1) != b:changedtick
    let b:systemverilog_mode_indent_cache = {
          \ 'tick': b:changedtick,
          \ 'levels': [0],
          \ }
  endif
  return b:systemverilog_mode_indent_cache
endfunction

function! s:SVAdvanceCache(lnum) abort
  let l:cache = s:SVIndentCache()
  while len(l:cache.levels) < a:lnum
    let l:num = len(l:cache.levels)
    let l:level = l:cache.levels[-1]
    let l:line = s:SVStripCommentsAndStrings(getline(l:num))

    if l:line =~# '^\s*$' || l:line =~# '^\s*//' || l:line =~# '^\s*`'
      call add(l:cache.levels, l:level)
      continue
    endif

    if s:SVIsClose(l:line)
      let l:level -= 1
    endif
    if s:SVIsOpen(l:line)
      let l:level += 1
    endif

    call add(l:cache.levels, max([l:level, 0]))
  endwhile
  return l:cache
endfunction

function! SystemVerilogModeIndent(lnum) abort
  let l:base = VerilogModeIndent(a:lnum)
  let l:cache = s:SVAdvanceCache(a:lnum)
  let l:level = l:cache.levels[a:lnum - 1]

  if s:SVIsClose(getline(a:lnum))
    let l:level -= 1
  endif

  return max([l:base + l:level * shiftwidth(), 0])
endfunction
