"=============================================================================
" File: autoload/verilog_mode.vim
" Description: Core logic with a switch for synchronous execution.
"=============================================================================

" --- State variables ---
let s:job_info = {}
let s:pending_update = {}

" --- Helper Functions ---
function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

function! s:update_buffer_content(content) abort
  let save_cursor = getpos('.')
  silent! %d _
  call setline(1, a:content)
  call setpos('.', save_cursor)
  silent! write
  echom '[Verilog-Mode] Buffer updated and saved.'
endfunction

" --- Public Functions ---
function! verilog_mode#invoke_emacs(action, ...) abort
  " a:1 controls whether to load extra scripts. Default to 0 (false).
  let load_extra_scripts = a:0 > 0 ? a:1 : 0

  if !empty(s:job_info) && g:verilog_mode_force_sync == 0
    echoerr '[Verilog-Mode] An Emacs process is already running. Please wait.'
    return
  endif

  if !exists('g:verilog_mode_elisp_script_path')
    echoerr '[Verilog-Mode] Elisp script path is not configured.'
    return
  endif

  let emacs_function = a:action == 'auto' ? 'verilog-batch-auto' : 'verilog-batch-delete-auto'
  let original_file_path = expand('%:p')
  if empty(original_file_path)
      echoerr '[Verilog-Mode] Buffer must be saved to a file first.'
      return
  endif

  let tmp_file = original_file_path . '.' . fnamemodify(tempname(), ':t') . '.tmp'
  if writefile(getline(1, '$'), tmp_file) != 0
    echoerr '[Verilog-Mode] Failed to write to temporary file: ' . tmp_file
    return
  endif

  let cmd = [
        \ g:verilog_mode_emacs_executable,
        \ '-batch',
        \ '-q',
        \ '-script', expand('~/.emacs'),
        \ '-l', g:verilog_mode_elisp_script_path
        \ ]
  
  if load_extra_scripts
    echom '[Verilog-Mode] Loading extra Elisp scripts...'
    if exists('g:verilog_mode_extra_elisp_scripts') && type(g:verilog_mode_extra_elisp_scripts) == type([])
      for s:script in g:verilog_mode_extra_elisp_scripts
        let cmd += ['-l', expand(s:script)]
      endfor
    endif
  endif
  
  let cmd += [tmp_file, '-f', emacs_function]

  echom '[Verilog-Mode] Invoking Emacs with command: ' . join(cmd, ' ')

  if (has('nvim') || has('job')) && !g:verilog_mode_force_sync
    call s:run_async(cmd, tmp_file)
  else
    call s:run_sync(cmd, tmp_file)
  endif
endfunction

" --- Asynchronous Execution ---
function! s:run_async(cmd, tmp_file) abort
  echom '[Verilog-Mode] Starting Emacs asynchronously...'
  let s:job_info = {
        \ 'bufnr': bufnr('%'),
        \ 'tmp_file': a:tmp_file,
        \ 'start_time': reltime()
        \ }
  let job_options = {
        \ 'exit_cb': s:SID() . 'on_exit',
        \ 'err_cb':  s:SID() . 'on_err',
        \ 'out_cb':  s:SID() . 'on_out',
        \ }
  let job_id = job_start(a:cmd, job_options)

  if job_status(job_id) == 'fail'
    echoerr '[Verilog-Mode] Failed to start async job.'
    let s:job_info = {}
    if filereadable(a:tmp_file)
      call delete(a:tmp_file)
    endif
  else
    let s:job_info.job_id = job_id
  endif
endfunction

" --- Synchronous Execution (Vim 7 fallback) ---
function! s:run_sync(cmd, tmp_file) abort
  echom '[Verilog-Mode] Running Emacs synchronously (Vim 7 fallback)...'
  call system(join(a:cmd))
  if v:shell_error
    echoerr '[Verilog-Mode] Emacs command failed with exit code: ' . v:shell_error
    call delete(a:tmp_file)
    return
  endif
  let new_content = readfile(a:tmp_file)
  call delete(a:tmp_file)
  call s:update_buffer_content(new_content)
endfunction

" --- Timer Callback for UI Update ---
function! s:apply_pending_update(timer_id) abort
  if empty(s:pending_update) | return | endif
  let bnr = s:pending_update.bufnr
  let new_content = s:pending_update.content
  let s:pending_update = {}
  if !bufexists(bnr) || !buflisted(bnr) | return | endif
  let win_id = bufwinid(bnr)
  if win_id > 0
    call win_gotoid(win_id)
  else
    execute 'vsplit | buffer ' . bnr
  endif
  call s:update_buffer_content(new_content)
endfunction

" --- Async Callbacks (unchanged) ---
function! s:on_exit(job_id, status) abort
  if empty(s:job_info) | return | endif
  let bnr = s:job_info.bufnr
  let tmp_file = s:job_info.tmp_file
  let start_time = s:job_info.start_time
  let s:job_info = {}
  let elapsed = reltimestr(reltime(start_time))
  echom printf('[Verilog-Mode] Async Emacs process finished with status %d in %s.', a:status, elapsed)
  if a:status != 0
    echohl WarningMsg
    echomsg '[Verilog-Mode] Emacs exited with a non-zero status. Buffer not modified.'
    echohl None
    call delete(tmp_file)
    return
  endif
  let new_content = readfile(tmp_file)
  call delete(tmp_file)
  let s:pending_update = {'bufnr': bnr, 'content': new_content}
  call timer_start(0, s:SID() . 'apply_pending_update')
endfunction
function! s:on_err(job_id, msglist) abort
  for msg in a:msglist
    if !empty(msg)
      echohl WarningMsg
      echomsg '[Verilog-Mode][Emacs stderr] ' . msg
      echohl None
    endif
  endfor
endfunction
function! s:on_out(job_id, msglist) abort
endfunction