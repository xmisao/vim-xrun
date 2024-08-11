if exists('g:loaded_xrun')
  finish
endif
let g:loaded_xrun = 1

function! s:CreateOrReuseBuffer(name)
  let l:buf = bufnr(a:name)

  if l:buf == -1
    execute 'vnew ' . a:name
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    let l:buf = bufnr('%')
  else
    let l:win = bufwinnr(l:buf)
    if l:win != -1
      execute l:win . 'wincmd w'
    else
      execute 'vsplit'
      execute 'buffer ' . l:buf
    endif
  endif

  return l:buf
endfunction

function! s:GetSelectedText2(start, end, mode)
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]

  if a:start == line_start && a:end == line_end
    " Visual mode
    " NOTE: https://stackoverflow.com/a/61486601
    let lines = getline(line_start, line_end)
    if a:mode ==# 'v'
      let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
      let lines[0] = lines[0][column_start - 1:]
    elseif  a:mode == "\<c-v>"
      let new_lines = []
      let i = 0
      for line in lines
        let lines[i] = line[column_start - 1: column_end - (&selection == 'inclusive' ? 1 : 2)]
        let i = i + 1
      endfor
    else
      return ''
    endif
    return join(lines, "\n")
  else
    " Normal mode
    return join(getline(a:start, a:end), "\n")
  endif
endfunction

function! s:AppendOutput(bufnr, channel, msg)
  call appendbufline(a:bufnr, '$', a:msg)
  call win_execute(bufwinid(a:bufnr), 'normal! G')
endfunction

function! s:JobExit(bufnr, temp_file, job, status)
  call delete(a:temp_file)
endfunction

function! s:Xrun(start, end, cmd) range
  let selected_text = s:GetSelectedText2(a:start, a:end, visualmode())

  let temp_file = tempname()
  call writefile(split(selected_text, "\n", 1), temp_file)

  let output_bufnr = s:CreateOrReuseBuffer("XrunOutput")

  let job = job_start(a:cmd . ' ' . temp_file, {
        \ 'out_cb': function('s:AppendOutput', [output_bufnr]),
        \ 'err_cb': function('s:AppendOutput', [output_bufnr]),
        \ 'exit_cb': function('s:JobExit', [output_bufnr, temp_file])
        \ })

  setlocal statusline=%{job_status(b:job)}
  let b:job = job
endfunction

command! -range=% -nargs=1 Xrun <line1>,<line2>call s:Xrun(<line1>, <line2>, <q-args>)
