if get(s:, 'loaded')
  finish
endif
let s:loaded = 1

let s:buffer = 0
let g:actionmenu#win = 0
let g:actionmenu#items = []

function! actionmenu#icon() abort
  let l:character = strcharpart(strpart(getline('.'), col('.') - 1), 0, 1)    " Current character
  let l:foreground = synIDattr(synID(line("."), col("."), 1), "fg")           " Current character foreground
  let l:default = {
    \ 'character': l:character,
    \ 'foreground': l:foreground
    \ }

  return get(g:, 'actionmenu#icon', l:default)
endfunction

function! actionmenu#open(items, callback, ...) abort
  if empty(a:items)
    return
  endif

  " Create the buffer
  if !s:buffer
    let s:buffer = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_option(s:buffer, 'syntax', 'OFF')
  endif

  " Prepare the menu
  let l:opts = get(a:, 1, 0)
  if type(l:opts['icon']) == type({})
    let l:icon = l:opts['icon']
  else
    let l:icon = actionmenu#icon()
  endif

  " Set the icon
  call nvim_buf_set_option(s:buffer, 'modifiable', v:true)
  call nvim_buf_set_lines(s:buffer, 0, -1, v:true, [l:icon['character']])

  let g:ActionMenuCallback = a:callback
  let g:actionmenu#items = a:items

  " Close the old window if opened
  call actionmenu#close()

  " Open the window
  let l:opts = {
    \ 'focusable': v:false,
    \ 'width': 1,
    \ 'height': 1,
    \ 'relative': 'cursor',
    \ 'row': 0,
    \ 'col': 0
    \}

  let g:actionmenu#win = nvim_open_win(s:buffer, v:true, l:opts)
  call nvim_win_set_option(g:actionmenu#win, 'foldenable', v:false)
  call nvim_win_set_option(g:actionmenu#win, 'wrap', v:true)
  call nvim_win_set_option(g:actionmenu#win, 'statusline', '')
  call nvim_win_set_option(g:actionmenu#win, 'number', v:false)
  call nvim_win_set_option(g:actionmenu#win, 'relativenumber', v:false)
  call nvim_win_set_option(g:actionmenu#win, 'cursorline', v:false)
  call nvim_win_set_option(g:actionmenu#win, 'winhl', 'Normal:Pmenu,NormalNC:Pmenu')

  " Setup the window
  set filetype=actionmenu
  if !empty(l:icon['foreground'])
    execute("hi ActionMenuContext ctermfg=" . l:icon['foreground'])
    syn match ActionMenuContext "."
  endif
endfunction

function! actionmenu#callback(index, item)
  call actionmenu#close()

  if type(g:ActionMenuCallback) == type("")
    execute("call " . g:ActionMenuCallback . "(a:index, a:item)")
  else
    call g:ActionMenuCallback(a:index, a:item)
  endif
endfunction

function! actionmenu#close()
  if g:actionmenu#win
    call feedkeys("\<C-w>\<C-c>")
    let g:actionmenu#win = 0
  endif
endfunction

"
" Examples
"

function! actionmenu#example() abort
  call actionmenu#open(['First', 'Second', 'Third'], { index, item -> actionmenu#example_callback(index, item) })
endfunction

function! actionmenu#example2() abort
  let custom = [
  \ { 'word': 'First', 'abbr': '1st', 'user_data': 'Custom data 1' },
  \ { 'word': 'Second', 'abbr': '2nd', 'user_data': 'Custom data 2' },
  \ { 'word': 'Third', 'abbr': '3rd', 'user_data': 'Custom data 3' }
  \ ]
  call actionmenu#open(custom, function('actionmenu#example_callback'), {
  \ 'icon': { 'character': 'X', 'foreground': 'yellow' }
  \ })
endfunction

function! actionmenu#example3() abort
  call actionmenu#open(['First', 'Second', 'Third'], "actionmenu#example_callback")
endfunction

function! actionmenu#example_callback(index, item) abort
  if a:index == -1
    echo "No item selected"
  elseif type(a:item) == type("")
    echo "Selected ". a:item . " position " . a:index
  else
    echo "Selected ". a:item['word'] . " position " . a:index . " (user_data = ". a:item['user_data'] . ")"
  endif
endfunction
