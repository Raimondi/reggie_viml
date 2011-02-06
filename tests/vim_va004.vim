" Test on Sample 5, go to 'augroup' and :norm vakakd, repeat on 'augroup END'.
call vimtest#StartTap()
call vimtap#Plan(4)
edit sample_005.vim
exec 'runtime ftplugin/vim/'.fname.'.vim'
call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.va, 'v') =~# maps.pva, 'Check Visual All mapping.')
3
normal 0vakd
call vimtap#Is(getline(1,line('$')), ['" Sample 5', '', ''], 'Check if the selection from "augroup" was correct.')
undo
7
normal 0vakd
call vimtap#Is(getline(1,line('$')), ['" Sample 5', '', ''], 'Check if the selection from "augroup END" was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
