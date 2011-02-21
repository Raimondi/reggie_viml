" File:        ftplugin/ruby/reggie_to.vim
" Version:     1.0
" Modified:    2011-02-20
" Description: This ftplugin sets the values needed for Ruby files.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
"=============================================================================

" Lines where this expression returns 1 will be skipped
" Expression borrowed from default ruby ftplugin
let b:reggie_to_skip =
      \ "synIDattr(synID(line('.'),col('.'),0),'name') =~ '"            .
      \ "\\<ruby\\%(String\\|StringDelimiter\\|ASCIICode\\|Escape\\|"   .
      \ "Interpolation\\|NoInterpolation\\|Comment\\|Documentation\\|"  .
      \ "ConditionalModifier\\|RepeatModifier\\|OptionalDo\\|"          .
      \ "Function\\|BlockArgument\\|KeywordAsMethod\\|ClassVariable\\|" .
      \ "InstanceVariable\\|GlobalVariable\\|Symbol\\)\\>'"

" List of words that start a block at the beginning of the line
let s:beg_words =
      \ '<def>|<module>|<class>|<case>|<if>|<unless>|<begin>|'.
      \ '<for>|<until>|<while>|<catch>'

" Start of the block matches this
let b:reggie_to_start =
      \ '\C\v^\s*\zs%('.s:beg_words.')|'.
      \ '%(%('.s:beg_words.').*)@<!<do>'

" Middle of the block matches this
let b:reggie_to_middle = '\C\v^\s*\zs%(<els%(e|if)>|<rescue>|<ensure>|<when>)'

" End of the block matches this
let b:reggie_to_end   = '\C\v^\s*\zs<end>'

" Set the rest of things
call reggie_to#init()

" vim: set et sw=2 sts=2 tw=78: {{{1
