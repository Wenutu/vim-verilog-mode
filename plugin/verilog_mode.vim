"=============================================================================
" File: plugin/verilog_mode.vim
" Role: Provides GUI menu enhancements. All variable setup is now handled
"       by the ftplugin for robustness.
"=============================================================================

if exists('g:loaded_verilog_mode_plugin')
  finish
endif
let g:loaded_verilog_mode_plugin = 1

" --- GUI Menu Setup ---
" This is the only functionality that must be loaded at startup.
if has('gui_running')
  noremenu <script> &Emacs.Verilog-mode\ Add    :call verilog_mode#invoke_emacs('auto')<CR>
  noremenu <script> &Emacs.Verilog-mode\ Delete  :call verilog_mode#invoke_emacs('delete')<CR>
endif