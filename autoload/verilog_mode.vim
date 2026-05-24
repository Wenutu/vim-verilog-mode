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

function! s:update_buffer_content(content)
  let save_cursor = getpos('.')
  silent! %d _
  call setline(1, a:content)
  call setpos('.', save_cursor)
  silent! write
  echom '[Verilog-Mode] Buffer updated and saved.'
endfunction

" --- Public Functions ---
function! s:shell_join(argv)
  let l:parts = []
  for l:item in a:argv
    call add(l:parts, shellescape(l:item))
  endfor
  return join(l:parts, ' ')
endfunction

function! s:echo_failure(summary, details)
  echohl ErrorMsg
  echomsg a:summary
  echohl None

  if empty(a:details)
    echomsg '[Verilog-Mode] No output was captured from Emacs.'
    return
  endif

  echomsg '[Verilog-Mode] Emacs output:'
  let l:lines = type(a:details) == type([]) ? a:details : split(a:details, "\n")
  let l:max_lines = 80
  for l:line in l:lines[:l:max_lines - 1]
    if !empty(l:line)
      echomsg '[Verilog-Mode] ' . l:line
    endif
  endfor
  if len(l:lines) > l:max_lines
    echomsg printf('[Verilog-Mode] ... %d more lines omitted', len(l:lines) - l:max_lines)
  endif
endfunction

function! s:record_job_output(kind, msg)
  if empty(s:job_info) || !has_key(s:job_info, 'output')
    return
  endif

  let l:messages = type(a:msg) == type([]) ? a:msg : [a:msg]
  for l:msg in l:messages
    if !empty(l:msg)
      call add(s:job_info.output, '[' . a:kind . '] ' . l:msg)
    endif
  endfor
endfunction

function! verilog_mode#invoke_emacs(action, ...)
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
        \ expand(g:verilog_mode_emacs_executable),
        \ '-batch',
        \ '-q'
        \ ]

  let user_emacs_script = expand('~/.emacs')
  if filereadable(user_emacs_script)
    let cmd += ['-script', user_emacs_script]
  endif

  let cmd += ['-l', expand(g:verilog_mode_elisp_script_path)]
  
  if load_extra_scripts
    echom '[Verilog-Mode] Loading extra Elisp scripts...'
    if exists('g:verilog_mode_extra_elisp_scripts') && type(g:verilog_mode_extra_elisp_scripts) == type([])
      for l:script in g:verilog_mode_extra_elisp_scripts
        let cmd += ['-l', expand(l:script)]
      endfor
    endif
  endif
  
  let cmd += [tmp_file, '-f', emacs_function]

  " echom '[Verilog-Mode] Invoking Emacs with command: ' . join(cmd, ' ')

  if has('job') && exists('*job_start') && exists('*job_status') && !g:verilog_mode_force_sync
    call s:run_async(cmd, tmp_file)
  else
    call s:run_sync(cmd, tmp_file)
  endif
endfunction

" --- Asynchronous Execution ---
function! s:run_async(cmd, tmp_file)
  echom '[Verilog-Mode] Starting Emacs asynchronously...'
  let s:job_info = {
        \ 'bufnr': bufnr('%'),
        \ 'tmp_file': a:tmp_file,
        \ 'start_time': reltime(),
        \ 'output': []
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
function! s:run_sync(cmd, tmp_file)
  echom '[Verilog-Mode] Running Emacs synchronously (Vim 7 fallback)...'
  let l:output = system(s:shell_join(a:cmd) . ' 2>&1')
  if v:shell_error
    call s:echo_failure('[Verilog-Mode] Emacs command failed with exit code: ' . v:shell_error, l:output)
    call delete(a:tmp_file)
    return
  endif
  let new_content = readfile(a:tmp_file)
  call delete(a:tmp_file)
  call s:update_buffer_content(new_content)
endfunction

" --- Timer Callback for UI Update ---
function! s:apply_pending_update(timer_id)
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
function! s:on_exit(job_id, status)
  if empty(s:job_info) | return | endif
  let bnr = s:job_info.bufnr
  let tmp_file = s:job_info.tmp_file
  let start_time = s:job_info.start_time
  let output = has_key(s:job_info, 'output') ? copy(s:job_info.output) : []
  let s:job_info = {}
  let elapsed = reltimestr(reltime(start_time))
  echom printf('[Verilog-Mode] Async Emacs process finished with status %d in %s.', a:status, elapsed)
  if a:status != 0
    call s:echo_failure('[Verilog-Mode] Emacs exited with status ' . a:status . '. Buffer not modified.', output)
    call delete(tmp_file)
    return
  endif
  let new_content = readfile(tmp_file)
  call delete(tmp_file)
  let s:pending_update = {'bufnr': bnr, 'content': new_content}
  if exists('*timer_start')
    call timer_start(0, s:SID() . 'apply_pending_update')
  else
    call s:apply_pending_update(0)
  endif
endfunction
function! s:on_err(job_id, msglist)
  call s:record_job_output('stderr', a:msglist)
endfunction
function! s:on_out(job_id, msglist)
  call s:record_job_output('stdout', a:msglist)
endfunction
