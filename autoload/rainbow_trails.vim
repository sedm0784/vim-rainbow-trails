scriptencoding utf-8
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" FIXME: Profile to see if we can optimise. Otherwise, just try pulling
"        calculations/function calls out of inner loops.

let s:matches = []
let s:timers = []

let s:default_constant_interval = 1
let s:default_max_variable_interval = 5
let s:default_variable_timer_threshold = 30
let s:default_fade_rate_thresholds = [8, 30, 80, 150]
let s:default_colour_width_thresholds = [0, 0, 8]
let s:default_colours = ['RainbowRed', 'RainbowOrange', 'RainbowYellow', 'RainbowGreen', 'RainbowBlue', 'RainbowIndigo', 'RainbowViolet']

function! rainbow_trails#enable(enable) abort
  " FIXME: Check for timers feature.
  " FIXME: Check for 256 colours or termguicolors
  if a:enable
    augroup RainbowTrails
      autocmd!
      autocmd CursorMoved * call s:cursor_moved()
      autocmd WinLeave * call s:stop_trails()
      autocmd WinEnter * let w:rainbow_position = getpos('.')
      autocmd ColorScheme * call s:setup_colors()
    augroup END
    let w:rainbow_position = getpos('.')
    call s:setup_colors()
  else
    autocmd! RainbowTrails
  endif
endfunction


function! s:setup_colors() abort
    " FIXME: Document how user can set their own colours
    " FIXME: Should we only highlight colours defined in s:colours()?
    highlight default RainbowRed guibg=#ff0000 ctermbg=196
    highlight default RainbowOrange guibg=#ff7f00 ctermbg=208
    highlight default RainbowYellow guibg=#ffff00 ctermbg=226
    highlight default RainbowGreen guibg=#00ff00 ctermbg=46
    highlight default RainbowBlue guibg=#0000ff ctermbg=21
    highlight default RainbowIndigo guibg=#00005f ctermbg=17
    highlight default RainbowViolet guibg=#7f00ff ctermbg=129
endfunction


function! s:cursor_moved() abort
  let new_position = getpos('.')
  if exists('w:rainbow_position')
    call s:rainbow_start(new_position, w:rainbow_position)
  endif
  let w:rainbow_position = new_position
endfunction


function! s:rainbow_start(new_position, old_position)
  let positions = s:bresenham(
        \ a:old_position[2], a:old_position[1],
        \ a:new_position[2], a:new_position[1])

  if len(positions) == 0
    return
  endif

  " How long before each character in the rainbow fades away
  " With a colour width of 1, the first position should start with a value of
  " num_colours - 1, because it *starts* as the first colour and then cycles
  " through the other colours which have indexes 1-6, one per callback.
  " With larger colour widths, we need to multiply by the width, so each
  " colour is maintained for that number of callbacks.
  "
  " So e.g. with a colour width of 3 and 7 colours, we want timers to contain:
  " [18, 19, 20, 21, ...]
  let timers = range(len(positions))
  call map(timers, {k, v -> v + (len(s:colours()) - 1) * s:colour_width(len(positions))})

  let s:matches = []

  " Highlight everything with the first colour
  let first_colour_positions = copy(positions)
  while !empty(first_colour_positions)
    " FIXME: This limitation is no longer mentioned in the current :help
    " matchaddpos takes batches of up to 8 positions
    call add(s:matches, matchaddpos(s:colours()[-1], first_colour_positions[:7]))
    let first_colour_positions = first_colour_positions[8:]
  endwhile

  let timer_interval = max([1, get(g:, 'rainbow_constant_interval', s:default_constant_interval)])

  if len(timers) < s:variable_timer_threshold()
    " Map lengths of 1..<variable_timer_threshold to
    " rainbow_max_variable_interval-0 extra ms

    let timer_interval += s:variable_interval(len(timers))
  endif
  let fade_rate = -s:fade_rate(len(positions))
  let repeats = timers[-1] / fade_rate + 1
  let repeats += timers[-1] % fade_rate > 0
  call add(s:timers, timer_start(timer_interval, function(
        \ 's:rainbow_fade',
        \ [s:matches, positions, timers]),
        \ {'repeat': repeats}))
endfunction


function! s:variable_interval(length) abort
  " Convert max_variable_interval option to Float so entire calculation
  " below is coerced to Float
  let max_variable_interval = 1.0 * get(g:, 'rainbow_max_variable_interval', s:default_max_variable_interval)
  return float2nr(round(
        \ (max_variable_interval * (s:variable_timer_threshold() - a:length))
        \ / s:variable_timer_threshold()))
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
    " Don't add off-screen lines or lines hidden within closed folds
    if y >= line('w0') && y <= line('w$') && (foldclosed(y) == -1 || foldclosed(y) == y)
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

  let colour_width = s:colour_width(len(a:positions))

  let first_colour_positions = []
  for i in range(len(a:positions))
    let timer = a:timers[i]
    if timer <= 0
      continue
    elseif timer <= (len(s:colours())) * colour_width
      " Highlight this colour now, using 1-based indexing
      let colour_index = (timer + colour_width - 1) / colour_width - 1
      call add(a:matches, matchaddpos(s:colours()[colour_index], [a:positions[i]]))
    else
      " Add to first_colour_positions to highlight at end of this loop
      call add(first_colour_positions, a:positions[i])
    endif

    let a:timers[i] += s:fade_rate(len(a:positions))
  endfor

  while !empty(first_colour_positions)
    call add(a:matches, matchaddpos(s:colours()[-1], first_colour_positions[:7]))
    let first_colour_positions = first_colour_positions[8:]
  endwhile
endfunction


function! s:fade_rate(rainbow_length)
  let fade_rate = min([-1, get(g:, 'rainbow_constant_interval', s:default_constant_interval)])

  for threshold in get(g:, 'rainbow_fade_rate_thresholds', s:default_fade_rate_thresholds)
    if a:rainbow_length >= threshold
      let fade_rate -= 1
    endif
  endfor

  return fade_rate
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


function! s:colour_width(rainbow_length) abort
  let colour_width = 1
  for threshold in s:colour_width_thresholds()
    if a:rainbow_length >= threshold
      let colour_width += 1
    endif
  endfor
  return colour_width
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

"
" User Configuration Wrappers
"

function! s:variable_timer_threshold() abort
  return get(g:, 'rainbow_variable_timer_threshold', s:default_variable_timer_threshold)
endfunction


function s:colour_width_thresholds()
  " FIXME: Should this be fully dynamic, instead of configurable? Can we come
  "        up with a nice implementation of that that always works?
  return get(g:, 'rainbow_colour_width_thresholds', s:default_colour_width_thresholds)
endfunction


function! s:colours() abort
  return reverse(copy(get(g:, 'rainbow_colours',
        \ s:default_colours)))
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
