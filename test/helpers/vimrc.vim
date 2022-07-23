set nocompatible
set nobackup
set nowb
set noswapfile

let g:test_vimrc_loaded = 1

let s:plugin = expand('<sfile>:h:h:h')

execute 'set runtimepath+='.s:plugin

function TestCallback(index, item)
  let g:test_callback_index = a:index
  let g:test_callback_item = a:item
endfunction

function TestPrintCallback(index, item)
  if type(a:item) == type("")
    call feedkeys("A" . a:item)
  else
    call feedkeys("A" . a:item['word'])
  endif
endfunction
