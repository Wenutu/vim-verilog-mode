" =============================================================================
" File: ftdetect/verilog.vim
" Author: Wenutu Shi <wenutushi@outlook.com>
" Description: Filetype-specific settings for Verilog.
" =============================================================================

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

au BufNewFile,BufRead *.v,*.vh,*.sv,*.svh  setfiletype verilog