" Test on Sample 9: Ignore lines with |
call vimtest#StartTap()
call vimtap#Plan(1)
edit sample_009.vim
exec 'runtime ftplugin/vim/'.fname.'.vim'
"call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
"call vimtap#Ok(maparg(maps.vi, 'v') =~# maps.pvi, 'Check Visual Inner mapping.')
5
silent! normal yak
call vimtap#Is(@", "if 0\n  if 1 | echo 2 | else | echo3 | endif\nendif\n", 'Check if selection was correct.')
call vimtest#Quit()
