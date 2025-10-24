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
  else
    " Clear any lines if present
    call deletebufline(s:buffer, 1, '$')
  endif
  " call nvim_buf_set_lines(s:buffer, 0, -1, v:true, [l:icon['character']])
  let g:foobuf = s:buffer
  " echom "New buffer is " . s:buffer

  " Prepare the menu
  let l:opts = get(a:, 1, 0)
  if type(l:opts['icon']) == type({})
    let l:icon = l:opts['icon']
  else
    let l:icon = actionmenu#icon()
  endif
  let g:action_text_icon_char = l:icon['character']

  " Set the icon
  call nvim_buf_set_option(s:buffer, 'modifiable', v:true)
  " call nvim_buf_set_option(s:buffer, 'listchars', 'precedes:' . icon['character']) " Shows selecting menus
  " call nvim_buf_set_lines(s:buffer, 0, -1, v:true, [l:icon['character']])

  lua << EOF
  -- print("doing it")
  -- local buf = vim.api.nvim_get_current_buf() --
  local buf = vim.api.nvim_get_var('foobuf')
  local char = vim.api.nvim_get_var('action_text_icon_char')
  local ns_id = vim.api.nvim_create_namespace('Foo')
  -- print("Using buffer " .. buf)
  vim.api.nvim_set_hl(buf, 'MyVirtText', { bg = '#ff00ff', fg = '#99ccff' }) -- Green virtual text
  vim.api.nvim_buf_set_extmark(buf, ns_id, 0, 0, {
    -- sign_text = char,
    -- sign_hl_group = 'MyVirtText',
    -- line_hl_group = 'MyVirtText',
    virt_text = {{ '$', 'MyVirtText' }}, -- Single character with custom highlight
    virt_text_pos = 'inline', -- Place over the buffer content
    priority = 1000,
  })
  -- vim.api.nvim_command('highlight default HighlightLine guifg=#ff007c gui=bold ctermfg=198 cterm=bold ctermbg=darkgreen')
EOF

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
  call nvim_win_set_option(g:actionmenu#win, 'listchars', 'precedes:' . icon['character']) " Shows selecting menus
  call nvim_win_set_option(g:actionmenu#win, 'winhl', 'Normal:ActionMenu,Pmenu:ActionMenu,NormalNC:ActionMenu')

  " Setup the window
  set filetype=actionmenu
  if !empty(l:icon['foreground'])
    execute("hi ActionMenuContext ctermfg=" . l:icon['foreground'] .. " guibg=#99ccff")
    execute("hi ActionMenu ctermfg=" . l:icon['foreground'] .. " ctermbg=0 guibg=magenta guifg=green")
    " When shown via fillchars...
    " execute("hi NonText ctermfg=" . l:icon['foreground'] . " guifg=blue guibg=red")
    " execute("hi ActionMenu ctermfg=1 ctermbg=3 guifg=magenta guibg=yellow")
    " execute("hi ActionMenu ctermfg=1 ctermbg=3 guifg=red guibg=yellow")
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
    call nvim_win_close(g:actionmenu#win, v:true)
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
  if type(a:item) == type("")
    echo "Selected ". a:item . " position " . a:index
  else
    echo "Selected ". a:item['word'] . " position " . a:index . " (user_data = ". a:item['user_data'] . ")"
  endif
endfunction
