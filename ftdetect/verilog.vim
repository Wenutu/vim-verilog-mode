" =============================================================================
" File: ftdetect/verilog.vim
" Author: Wenutu Shi <wenutushi@outlook.com>
" Description: Filetype-specific settings for Verilog.
" =============================================================================

augroup verilog_mode_filetype
  autocmd!
  autocmd BufNewFile,BufRead *.v,*.vh setfiletype verilog
augroup END
