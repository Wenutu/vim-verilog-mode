"=============================================================================
" File: plugin/verilog_mode.vim
" Role: Provides GUI menu enhancements.
"=============================================================================

if exists('g:loaded_verilog_mode_plugin')
  finish
endif
let g:loaded_verilog_mode_plugin = 1

" --- GUI Menu Setup ---
if has('gui_running')
  noremenu <script> &Emacs.Verilog-mode.&Add\ AUTOs    :call verilog_mode#invoke_emacs('auto', 0)<CR>
  noremenu <script> &Emacs.Verilog-mode.&Delete\ AUTOs  :call verilog_mode#invoke_emacs('delete', 0)<CR>
  noremenu <script> &Emacs.Verilog-mode.Add\ AUTOs\ (E&xtra\ Config)    :call verilog_mode#invoke_emacs('auto', 1)<CR>
  noremenu <script> &Emacs.Verilog-mode.Delete\ AUTOs\ (E&xtra\ Config)  :call verilog_mode#invoke_emacs('delete', 1)<CR>
endif