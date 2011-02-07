" File:        ftplugin/ruby/ktextobjects.vim
" Version:     0.1a
" Modified:    2011-00-00
" Description: This ftplugin sets the values needed for Ruby files.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      The new text objects are 'ik' and 'ak'. Place this file in
"              'ftplugin/ruby/' inside $HOME/.vim or somewhere else in your
"              runtimepath.
"
"              :let testing_KeywordTextObjects = 1 to allow reloading of the
"              plugin without closing Vim.
"
"              Multiple sentences on a single line are not handled by this
"              plugin, the text objects might not work or work in an
"              unexpected way.
"
" Pending:     - Consider continued lines for inner text objects.
"=============================================================================

" Allow users to disable ftplugins
if exists('no_plugin_maps') || exists('no_ruby_maps') || exists('b:kto')
  " User doesn't want this functionality.
  finish
endif

" Variables {{{1
" One Dict to rule them all, One Dict to find them,
" One Dict to bring them all and in the darkness unlet them...
let b:kto = {}

" Lines where this expression returns 1 will be skipped
" Expression borrowed from default ruby ftplugin
let b:kto.skip_e =
      \ "synIDattr(synID(line('.'),col('.'),0),'name') =~ '"            .
      \ "\\<ruby\\%(String\\|StringDelimiter\\|ASCIICode\\|Escape\\|"   .
      \ "Interpolation\\|NoInterpolation\\|Comment\\|Documentation\\|"  .
      \ "ConditionalModifier\\|RepeatModifier\\|OptionalDo\\|"          .
      \ "Function\\|BlockArgument\\|KeywordAsMethod\\|ClassVariable\\|" .
      \ "InstanceVariable\\|GlobalVariable\\|Symbol\\)\\>'"

" List of words that start a block at the beginning of the line
let b:kto.beg_words =
      \ '<def>|<module>|<class>|<case>|<if>|<unless>|<begin>|'.
      \ '<for>|<until>|<while>|<catch>'

" Start of the block matches this
let b:kto.start_p = '\C\v^\s*\zs%('.b:kto.beg_words.')|%(%('.b:kto.beg_words.').*)@<!<do>'

" Middle of the block matches this
let b:kto.middle_p= '\C\v^\s*\zs%(<els%(e|if)>|<rescue>|<ensure>|<when>)'

" End of the block matches this
let b:kto.end_p   = '\C\v^\s*\zs<end>'

" Don't wrap or move the cursor
let b:kto.flags = 'Wn'

" }}}1

" Set the rest of things
call ktextobjects#init()

" vim: set et sw=2 sts=2 tw=78: {{{1
