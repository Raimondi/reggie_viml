" File:        ftplugin/vim/ktextobjects.vim
" Version:     0.1a
" Modified:    2011-00-00
" Description: This ftplugin sets the values needed for VimL files.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      The new text objects are 'ik' and 'ak'. Place this file in
"              'ftplugin/vim/' inside $HOME/.vim or somewhere else in your
"              runtimepath.
"
"              :let testing_KeywordTextObjects = 1 to allow reloading of the
"              plugin without closing Vim.
"
"              Multiple sentences on a single line are not handled by this
"              plugin, the text objects might not work or work in an
"              unexpected way.
"
" ============================================================================
let save_cpo = &cpo
set cpo&vim

" VimL settings:
let b:ktextobjects_skip =
      \ 'getline(".") =~ "^\\s*sy\\%[ntax]\\s\\+region" ||' .
      \ 'synIDattr(synID(line("."),col("."),1),"name") =~? '.
      \ '"comment\\|string\\|vim\k\{-}var"'

" Start of the block matches this
let b:ktextobjects_start = '\C\v^\s*\zs%('            .
      \ '<fu%[nction]>|<%(wh%[ile]|for)>|<if>|<try>|' .
      \ '<aug%[roup]\s+%(END>)@!\S'                   .
      \ ')'

" Middle of the block matches this
let b:ktextobjects_middle = '\C\v^\s*\zs%(<el%[seif]>|<cat%[ch]>|<fina%[lly]>)'

" End of the block matches this
let b:ktextobjects_end =
      \ '\C\v^\s*\zs%(<endf%[unction]>|<end%(w%[hile]|fo%[r])>|'.
      \ '<en%[dif]>|<endt%[ry]>|<aug%[roup]\s+END>)'

" Set the rest of things
call ktextobjects#init()

let &cpo = save_cpo

" vim: set et sw=2 sts=2 tw=78: {{{1
