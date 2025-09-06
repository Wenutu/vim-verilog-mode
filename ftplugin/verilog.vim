"=============================================================================
" File: ftplugin/verilog.vim
" Description: Self-sufficient setup for Verilog filetype.
"=============================================================================

if exists('b:did_ftplugin_verilog_mode')
  finish
endif
let b:did_ftplugin_verilog_mode = 1

" --- Defensive Global Variable Initialization ---
" MODIFIED: Default mappings for simple/default mode
if !exists('g:verilog_mode_map_auto_add')
  let g:verilog_mode_map_auto_add = 'ta'
endif
if !exists('g:verilog_mode_map_auto_delete')
  let g:verilog_mode_map_auto_delete = 'td'
endif

" MODIFIED: Mappings for "Extra" mode (with extra elisp)
if !exists('g:verilog_mode_map_auto_add_extra')
  let g:verilog_mode_map_auto_add_extra = 'tA'
endif
if !exists('g:verilog_mode_map_auto_delete_extra')
  let g:verilog_mode_map_auto_delete_extra = 'tD'
endif

if !exists('g:verilog_mode_emacs_executable')
  let g:verilog_mode_emacs_executable = 'emacs'
endif
if !exists('g:verilog_mode_force_sync')
  let g:verilog_mode_force_sync = 0
endif
if !exists('g:verilog_mode_extra_elisp_scripts')
  let g:verilog_mode_extra_elisp_scripts = []
elseif type(g:verilog_mode_extra_elisp_scripts) != type([])
  echoerr '[Verilog-Mode] g:verilog_mode_extra_elisp_scripts must be a List.'
  let g:verilog_mode_extra_elisp_scripts = []
else
  for s:script in g:verilog_mode_extra_elisp_scripts
    if !filereadable(expand(s:script))
      echoerr '[Verilog-Mode] Extra elisp script is not readable: ' . s:script
    endif
  endfor
endif

if !exists('g:verilog_mode_elisp_script_path')
  let s:plugin_root = fnamemodify(expand('<sfile>'), ':h:h')
  let s:elisp_script = s:plugin_root . '/tools/verilog-mode.el.gz'
  if filereadable(s:elisp_script)
    let g:verilog_mode_elisp_script_path = s:elisp_script
  else
    echoerr '[Verilog-Mode] Critical error: could not find verilog-mode.el.gz'
  endif
else
  if !filereadable(g:verilog_mode_elisp_script_path)
    echoerr '[Verilog-Mode] Critical error: g:verilog_mode_elisp_script_path is set but the file is not readable'
  endif
endif

" --- Mappings ---
" Default mappings call with flag 0 (do NOT load extra scripts)
nnoremap <silent> <buffer> <Plug>VerilogModeAdd :call verilog_mode#invoke_emacs("auto", 0)<CR>
nnoremap <silent> <buffer> <Plug>VerilogModeDelete :call verilog_mode#invoke_emacs("delete", 0)<CR>

" Extra mappings call with flag 1 (load extra scripts)
nnoremap <silent> <buffer> <Plug>VerilogModeAddExtra :call verilog_mode#invoke_emacs("auto", 1)<CR>
nnoremap <silent> <buffer> <Plug>VerilogModeDeleteExtra :call verilog_mode#invoke_emacs("delete", 1)<CR>

" Map user-defined keys to default actions
if !hasmapto('<Plug>VerilogModeAdd', 'n')
  execute 'nnoremap <silent> <buffer> ' . g:verilog_mode_map_auto_add . ' <Plug>VerilogModeAdd'
endif
if !hasmapto('<Plug>VerilogModeDelete', 'n')
  execute 'nnoremap <silent> <buffer> ' . g:verilog_mode_map_auto_delete . ' <Plug>VerilogModeDelete'
endif

" Map user-defined keys to extra actions
if !hasmapto('<Plug>VerilogModeAddExtra', 'n')
  execute 'nnoremap <silent> <buffer> ' . g:verilog_mode_map_auto_add_extra . ' <Plug>VerilogModeAddExtra'
endif
if !hasmapto('<Plug>VerilogModeDeleteExtra', 'n')
  execute 'nnoremap <silent> <buffer> ' . g:verilog_mode_map_auto_delete_extra . ' <Plug>VerilogModeDeleteExtra'
endif

" --- Commands ---
" Default commands
command! -buffer VerilogAutoAdd   call verilog_mode#invoke_emacs('auto', 0)
command! -buffer VerilogAutoDelete call verilog_mode#invoke_emacs('delete', 0)

" Extra commands
command! -buffer VerilogAutoAddExtra   call verilog_mode#invoke_emacs('auto', 1)
command! -buffer VerilogAutoDeleteExtra call verilog_mode#invoke_emacs('delete', 1)