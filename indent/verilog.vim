" Vim indent file
" Language: Verilog
" Maintainer: vim-verilog-mode

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal indentexpr=VerilogModeIndent(v:lnum)
setlocal indentkeys& indentkeys+=0=end,0=endcase,0=endfunction,0=endgenerate,0=endmodule,0=endprimitive,0=endspecify,0=endtable,0=endtask,0=join,0=join_any,0=join_none,0=else,0=default
let b:undo_indent = 'setlocal indentexpr< indentkeys<'

if exists('*VerilogModeIndent')
  finish
endif

let s:open_words = '^\s*\(\<\(unique\|unique0\|priority\)\>\s\+\)\?\<\(module\|macromodule\|primitive\|begin\|case\|casex\|casez\|fork\|function\|generate\|specify\|table\|task\)\>'
let s:close_words = '^\s*\<\(endmodule\|endprimitive\|end\|endcase\|join\|join_any\|join_none\|endfunction\|endgenerate\|endspecify\|endtable\|endtask\)\>'

function! s:StripCommentsAndStrings(line) abort
  let l:line = substitute(a:line, '"\%([^"\\]\|\\.\)*"', '""', 'g')
  let l:line = substitute(l:line, '//.*$', '', '')
  return l:line
endfunction

function! s:PrevCodeLine(lnum) abort
  let l:num = prevnonblank(a:lnum - 1)
  while l:num > 0
    let l:line = s:StripCommentsAndStrings(getline(l:num))
    if l:line =~# '^\s*\*/'
      let l:num -= 1
      while l:num > 0 && getline(l:num) !~# '/\*'
        let l:num -= 1
      endwhile
      let l:num = prevnonblank(l:num - 1)
      continue
    endif
    if l:line !~# '^\s*$' && l:line !~# '^\s*//'
      return l:num
    endif
    let l:num = prevnonblank(l:num - 1)
  endwhile
  return 0
endfunction

function! s:IsPreProc(line) abort
  return a:line =~# '^\s*`'
endfunction

function! s:IsOpen(line) abort
  let l:line = s:StripCommentsAndStrings(a:line)
  return l:line =~# '\<else\>.*\<begin\>\s*$'
        \ || l:line =~# '\<begin\>\s*\(:\s*\k\+\)\?\s*$'
        \ || (l:line =~# s:open_words && l:line !~# s:close_words)
endfunction

function! s:IsClose(line) abort
  return s:StripCommentsAndStrings(a:line) =~# s:close_words
endfunction

function! s:IsContinuation(line) abort
  let l:line = s:StripCommentsAndStrings(a:line)
  return l:line !~# '^\s*`'
        \ && l:line =~# '\(=\|+\|-\|\*\|/\|&\||\|\^\|?\)\s*$'
        \ && l:line !~# s:open_words
        \ && l:line !~# s:close_words
        \ && l:line !~# '^\s*$'
endfunction

function! s:IsSingleStatementOpen(line) abort
  let l:line = s:StripCommentsAndStrings(a:line)
  return l:line !~# ';\s*$'
        \ && l:line !~# '\<begin\>'
        \ && l:line !~# s:open_words
        \ && l:line !~# s:close_words
        \ && l:line =~# '^\s*\(\(else\s\+\)\?if\s*(.*)\|else\|for\s*(.*)\|while\s*(.*)\|repeat\s*(.*)\|forever\|initial\|final\|always\w*\s*\(@.*\)\?\)\s*$'
endfunction

function! s:ParenDelta(line) abort
  let l:line = s:StripCommentsAndStrings(a:line)
  let l:opens = len(split(l:line, '(\|{', 1)) - 1
  let l:closes = len(split(l:line, ')\|}', 1)) - 1
  return l:opens - l:closes
endfunction

function! s:IndentCache() abort
  if !exists('b:verilog_mode_indent_cache')
        \ || get(b:verilog_mode_indent_cache, 'tick', -1) != b:changedtick
    let b:verilog_mode_indent_cache = {
          \ 'tick': b:changedtick,
          \ 'levels': [0],
          \ 'comments': [0],
          \ }
  endif
  return b:verilog_mode_indent_cache
endfunction

function! s:AdvanceCache(lnum) abort
  let l:cache = s:IndentCache()
  while len(l:cache.levels) < a:lnum
    let l:num = len(l:cache.levels)
    let l:level = l:cache.levels[-1]
    let l:in_comment = l:cache.comments[-1]
    let l:line = s:StripCommentsAndStrings(getline(l:num))

    if l:in_comment
      call add(l:cache.levels, l:level)
      call add(l:cache.comments, l:line !~# '\*/')
      continue
    endif

    if l:line =~# '/\*' && l:line !~# '\*/'
      call add(l:cache.levels, l:level)
      call add(l:cache.comments, 1)
      continue
    endif

    if l:line =~# '^\s*$' || l:line =~# '^\s*//' || s:IsPreProc(l:line)
      call add(l:cache.levels, l:level)
      call add(l:cache.comments, 0)
      continue
    endif

    if s:IsClose(l:line)
      let l:level -= 1
    endif
    if s:IsOpen(l:line) || s:IsContinuation(l:line)
      let l:level += 1
    endif

    let l:level += s:ParenDelta(l:line)
    let l:level = max([l:level, 0])
    call add(l:cache.levels, l:level)
    call add(l:cache.comments, 0)
  endwhile
  return l:cache
endfunction

function! VerilogModeIndent(lnum) abort
  let l:current = getline(a:lnum)
  if s:IsPreProc(l:current)
    return 0
  endif

  if l:current =~# '^\s*\*'
    let l:comment_start = search('/\*', 'bnW')
    if l:comment_start > 0
      return indent(l:comment_start) + 1
    endif
  endif

  if l:current =~# '^\s*else\>'
    let l:prevnum = s:PrevCodeLine(a:lnum)
    if l:prevnum > 0 && getline(l:prevnum) =~# '^\s*assert\s\+property\>'
      return indent(l:prevnum) + shiftwidth()
    endif
  endif

  let l:cache = s:AdvanceCache(a:lnum)
  let l:level = l:cache.levels[a:lnum - 1]
  let l:stripped = s:StripCommentsAndStrings(l:current)
  if s:IsClose(l:stripped) || l:stripped =~# '^\s*[)}]'
    let l:level -= 1
  endif

  let l:amount = max([l:level, 0]) * shiftwidth()
  let l:prevnum = s:PrevCodeLine(a:lnum)
  if l:prevnum > 0
        \ && l:stripped !~# '^\s*\(else\|end\|join\|endcase\)\>'
        \ && s:IsSingleStatementOpen(getline(l:prevnum))
    let l:amount += shiftwidth()
  endif

  return l:amount
endfunction
