"=============================================================================
" File: ftplugin/systemverilog.vim
" Description: Reuse vim-verilog-mode commands for SystemVerilog buffers.
"=============================================================================

execute 'source ' . fnameescape(expand('<sfile>:p:h') . '/verilog.vim')
