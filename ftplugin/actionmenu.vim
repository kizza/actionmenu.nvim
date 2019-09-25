" Only load once (subsequent times, just open pum)
" if get(s:, 'loaded')
"   call actionmenu#open_pum()
"   finish
" endif
" let s:loaded = 1

" Style the buffer
setlocal signcolumn=no
setlocal sidescrolloff=0

" Defaults
let s:selected_item = 0

function! actionmenu#open_pum()
  call feedkeys("i\<C-x>\<C-u>")
endfunction!

function! actionmenu#select_item()
  if pumvisible()
    call feedkeys("\<C-y>")
    if !empty(v:completed_item)
      let s:selected_item = v:completed_item
    endif
  endif
  call actionmenu#close_pum()
endfunction

function! actionmenu#close_pum()
  call feedkeys("\<esc>")
endfunction

function! actionmenu#on_insert_leave()
  if type(s:selected_item) == type({})
    call actionmenu#callback(s:selected_item['user_data'], g:actionmenu#items[s:selected_item['user_data']])
    let s:selected_item = 0   " Clear the selected item once selected
  else
    call actionmenu#callback(-1, 0)
  endif
endfunction

function! actionmenu#pum_item_to_action_item(item, index) abort
  if type(a:item) == type("")
    return { 'word': a:item, 'user_data': a:index }
  else
    return { 'word': a:item['word'], 'user_data': a:index }
  endif
endfunction

" Mappings
mapclear <buffer>
imapclear <buffer>
inoremap <nowait><buffer> <expr> <CR> actionmenu#select_item()
imap <nowait><buffer> <C-y> <CR>
imap <nowait><buffer> <C-e> <esc>
inoremap <nowait><buffer> <Up> <C-p>
inoremap <nowait><buffer> <Down> <C-n>
inoremap <nowait><buffer> k <C-p>
inoremap <nowait><buffer> j <C-n>

" Events
augroup actionmeun
  autocmd!
  autocmd InsertLeave <buffer> :call actionmenu#on_insert_leave()
augroup END

" pum completion function
function! actionmenu#complete_func(findstart, base)
  if a:findstart
    return 1
  else
    return map(copy(g:actionmenu#items), {
      \ index, item ->
      \   actionmenu#pum_item_to_action_item(item, index)
      \ }
      \)
  endif
endfunction

" Set the pum completion function
setlocal completefunc=actionmenu#complete_func
setlocal completeopt+=menuone

" Open the pum immediately
call actionmenu#open_pum()
