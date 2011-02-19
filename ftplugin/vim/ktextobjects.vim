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
" Pending:     - Consider continued lines for inner text objects.
" ============================================================================

" Set the rest of things
call ktextobjects#init()

" vim: set et sw=2 sts=2 tw=78: {{{1
