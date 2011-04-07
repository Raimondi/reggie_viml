" File:        ftplugin/vim/reggie_to.vim
" Version:     1.0
" Modified:    2011-02-22
" Description: This ftplugin sets the values needed for VimL files.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" ============================================================================
let save_cpo = &cpo
set cpo&vim

" VimL settings:
let b:reggie_to_skip =
      \ 'getline(".") =~ "^\\s*sy\\%[ntax]\\s\\+region" ||' .
      \ 'synIDattr(synID(line("."),col("."),1),"name") =~? '.
      \ '"comment\\|string\\|vim\k\{-}var" ||'              .
      \ 'getline(".") =~ "|"'

" Start of the block matches this
let b:reggie_to_start = '\C\v^\s*\zs%('            .
      \ '<fu%[nction]>|<%(wh%[ile]|for)>|<if>|<try>|' .
      \ '<aug%[roup]\s+%(END>)@!\S'                   .
      \ ')'

" Middle of the block matches this
let b:reggie_to_middle = '\C\v^\s*\zs%(<el%[seif]>|<cat%[ch]>|<fina%[lly]>)'

" End of the block matches this
let b:reggie_to_end =
      \ '\C\v^\s*\zs%(<endf%[unction]>|<end%(w%[hile]|fo%[r])>|'.
      \ '<en%[dif]>|<endt%[ry]>|<aug%[roup]\s+END>)'

" Set the rest of things
call reggie_to#init()

let &cpo = save_cpo

" vim: set et sw=2 sts=2 tw=78: {{{1
