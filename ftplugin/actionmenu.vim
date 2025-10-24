" Only load once (subsequent times, just open pum)
if get(s:, 'loaded')
  call actionmenu#open_pum()
  finish
endif

let s:loaded = 1

" Style the buffer
setlocal signcolumn=no
" setlocal signcolumn=yes
setlocal scrolloff=0
setlocal sidescrolloff=0
setlocal nowrap
setlocal guicursor=i:block " To have the highlited square
" setlocal listchars+=extends:>,precedes:!

" Defaults
let s:selected_item = 0

function! actionmenu#open_pum()
  " call feedkeys("i\<C-x>\<C-u>") " Enter insert mode *after* the icon char (so that the pum text isn't visible)
  call feedkeys("A\<C-x>\<C-u>") " Enter insert mode *after* the icon char (so that the pum text isn't visible)
  " lua << EOF
  " require('cmp').complete({
  "   config = {
  "     sources = {
  "       { name = 'buffer' },
  "       { name = 'path' }
  "     }
  "   }
  " })
" EOF

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

function! actionmenu#on_complete_changed()
  echom "Pum changed"
  if !pumvisible()
    call actionmenu#close_pum()
  endif
endfunction

function! actionmenu#on_complete_done()
  " if !pumvisible()
    echom "Pum done"
  " endif
  call actionmenu#on_insert_leave()
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
" autocmd InsertLeave <buffer> :call actionmenu#on_insert_leave()
autocmd CompleteDone <buffer> :call actionmenu#on_complete_done()
autocmd CompleteChanged <buffer> :call actionmenu#on_complete_changed()

" pum completion function
function! actionmenu#complete_func(findstart, base)
  if a:findstart
    return 0
  else
    let items = copy(g:actionmenu#items)
    let action_items = map(items, {index, item -> actionmenu#pum_item_to_action_item(item, index)})
    echom "base len=" . a:base->len()
    if a:base->len() == 0
      echom "return all"
      return { 'words': action_items, 'refresh': 'always' }
    endif

    echom "trying"
    let matches = filter(action_items, {index, item -> a:base->len() == 0 || item.word =~? a:base})

    " let words = map(copy(g:actionmenu#items), {
    "   \ index, item ->
    "   \   actionmenu#pum_item_to_action_item(item, index)
    "   \ }
    "   \)
    return { 'words': matches, 'refresh': 'always' }
  endif
endfunction

" Set the pum completion function
setlocal completefunc=actionmenu#complete_func
setlocal completeopt=menuone,noinsert

" Open the pum immediately
call actionmenu#open_pum()
