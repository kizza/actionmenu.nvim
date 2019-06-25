# A nice context menu for vim.

![Example](https://raw.githubusercontent.com/kizza/actionmenu.nvim/master/images/example.png)

This is intended for use within vim plugins or scripts, to open a context menu and provide a callback with the selected item.

[![Build Status](https://travis-ci.org/kizza/actionmenu.nvim.svg?branch=master)](https://travis-ci.org/kizza/actionmenu.nvim)

## Usage

The menu is opened with a simple function.  It will open at the current cursor location with whatever items your provide.

```vim
call actionmenu#open(items, callback, {opts})
```

- `items` each item can be a string or a dictionary (see [complete-items](http://vimdoc.sourceforge.net/htmldoc/insert.html#complete-items))
- `callback` either a string or a [funcref()](http://vimdoc.sourceforge.net/htmldoc/eval.html#Funcref)
  - Will be invoked with the selected `index` (zero based) and `item`
  - Cancelling a selection will invoke the callback with an `index` of -1
- `opts` _(optional)_ Currently allows you to specify the icon for the menu

## Examples

Simply paste the snippet below into your `.vimrc` then execute `:call Demo()`

```vim
func! Demo()
  call actionmenu#open(
    \ ['First', 'Second', 'Third'],
    \ 'Callback'
    \ )
endfunc

func! Callback(index, item)
  echo "I selected index " . a:index
endfunc
```

Below is an example using vim's `complete-items`

```vim
func! Demo()
  let l:items = [
    \ { 'word': 'First', 'abbr': '1st', 'user_data': 'Custom data 1' },
    \ { 'word': 'Second', 'abbr': '2nd', 'user_data': 'Custom data 2' }
    \ { 'word': 'Third', 'abbr': '3rd', 'user_data': 'Custom data 3' }
    \ ]

  call actionmenu#open(
    \ l:items,
    \ { index, item -> Callback(index, item) }
    \ )
endfunc

func! Callback(index, item)
  if a:index >= 0
    echo "Custom data is ". a:item['user_data']
  endif
endfunc
```

Open it with a custom icon (i've recently been using [nerdfonts](http://nerdfonts.com/) for this)
```vim
func! Demo()
  call actionmenu#open(
    \ ['First', 'Second', 'Third'],
    \ 'Callback',
    \ { 'icon': { 'character': 'X', 'foreground': 'yellow' } }
    \ )
endfunc

func! Callback(index, item)
  echo "I selected index " . a:index
endfunc
```

## Requirements
The [latest version of neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim) (which provides the "popup window" functionaity that is leveraged)

```
brew install --HEAD neovim
```

and this plugin (show below using [vim-plug](https://github.com/junegunn/vim-plug) installation - don't forget to run `:PlugInstall`)

```vim
if has('nvim')
  Plug 'kizza/actionmenu.nvim'
endif
```

Once installed, you can try it out by running `:call actionmenu#example()`

## Finally
Build it into your existing plugin or useful scripts however you like!
