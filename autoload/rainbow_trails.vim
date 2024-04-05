scriptencoding utf-8
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" FIXME: Allow user to specify colours and timer interval
let s:colours = ['RainbowRed', 'RainbowOrange', 'RainbowYellow', 'RainbowGreen', 'RainbowBlue', 'RainbowIndigo', 'RainbowViolet']
let s:timer_interval = 1

let s:colours = reverse(s:colours)
let s:matches = []
let s:timers = []

let s:short_cutoff = 30
let s:long_cutoff = 80

function! rainbow_trails#enable(enable) abort
  " FIXME: Check for timers feature.
  " FIXME: Check for 256 colours or termguicolors
  if a:enable
    " FIXME: Get it working in 256-colour terms
    highlight default RainbowRed guibg=#ff0000
    highlight default RainbowOrange guibg=#ff7f00
    highlight default RainbowYellow guibg=#ffff00
    highlight default RainbowGreen guibg=#00ff00
    highlight default RainbowBlue guibg=#007fff
    highlight default RainbowIndigo guibg=#0000ff
    highlight default RainbowViolet guibg=#7f00ff
    augroup RainbowTrails
      autocmd!
      autocmd CursorMoved * call s:cursor_moved()
      autocmd WinLeave * call s:stop_trails()
    augroup END
  else
    autocmd! RainbowTrails
  endif
endfunction


function! s:cursor_moved() abort
  let new_position = getpos('.')
  if exists('w:position')
    call s:rainbow_start(new_position, w:position)
  endif
  let w:position = new_position
endfunction


function! s:rainbow_start(new_position, old_position)
  let positions = s:bresenham(
        \ a:old_position[2], a:old_position[1],
        \ a:new_position[2], a:new_position[1])

  let timers = range(len(positions))
  if len(timers) >= s:long_cutoff
    call map(timers, {k, v -> v / 3})
  elseif len(timers) >= s:short_cutoff
    call map(timers, {k, v -> v / 2})
  endif

  let s:matches = []

  let first_colour_positions = copy(positions)
  while !empty(first_colour_positions)
    call add(s:matches, matchaddpos(s:colours[-1], first_colour_positions[:7]))
    let first_colour_positions = first_colour_positions[8:]
  endwhile

  let timer_interval = s:timer_interval
  if len(timers) < s:short_cutoff
    " Map lengths of 1-29 to 7-0 extra ms
    let timer_interval += float2nr(round((7.0 * (s:short_cutoff - len(timers))) / s:short_cutoff))
  endif
  call add(s:timers, timer_start(timer_interval, function(
        \ 's:rainbow_fade',
        \ [s:matches, positions, timers]),
        \ {'repeat': len(s:colours) - 1 + len(positions)}))
endfunction


function! s:bresenham(x0, y0, x1, y1) abort
  let positions = []

  let dx = abs(a:x1 - a:x0)
  let sx = a:x0 < a:x1 ? 1 : -1
  let dy = -abs(a:y1 - a:y0)
  let sy = a:y0 < a:y1 ? 1 : -1
  let error = dx + dy

  let x = a:x0
  let y = a:y0
  while 1
    if y >= line('w0') && y <= line('w$')
      call add(positions, [y, x])
    endif
    if x == a:x1 && y == a:y1
      break
    endif
    let e2 = 2 * error
    if e2 >= dy
      if x == a:x1
        break
      endif
      let error = error + dy
      let x += sx
    endif
    if e2 <= dx
      if y == a:y1
        break
      endif
      let error = error + dx
      let y += sy
    endif
  endwhile

  return positions
endfunction


function! s:rainbow_fade(matches, positions, timers, timer_id) abort
  call s:clear_matches(a:matches)

  let first_colour_positions = []
  for i in range(len(a:positions))
    let timer = a:timers[i]
    if timer < 0
      continue
    elseif timer < len(s:colours) - 1
      call add(a:matches, matchaddpos(s:colours[timer], [a:positions[i]]))
    else
      call add(first_colour_positions, a:positions[i])
    endif

    if len(a:positions) >= s:long_cutoff
      let subtrahend = 3
    elseif len(a:positions) >= s:short_cutoff
      let subtrahend = 2
    else
      let subtrahend = 1
    endif
    let a:timers[i] -= subtrahend
  endfor

  while !empty(first_colour_positions)
    call add(a:matches, matchaddpos(s:colours[-1], first_colour_positions[:7]))
    let first_colour_positions = first_colour_positions[8:]
  endwhile
endfunction


function! s:stop_trails() abort
  call s:stop_timers()
  call s:clear_matches(s:matches)
endfunction


function! s:stop_timers() abort
  for id in s:timers
    call timer_stop(id)
  endfor

  let s:timers = []
endfunction


function! s:clear_matches(matches) abort
  for id in a:matches
    " FIXME: If the user starts two rainbows and switches windows before they
    "        complete, the second match is never deleted. Why?
    silent! call matchdelete(id)
  endfor
  if !empty(a:matches)
    call remove(a:matches, 0, -1)
  endif
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
