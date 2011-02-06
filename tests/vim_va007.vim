" Test on Sample 2, go to the middle and :norm vakakakd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_002.vim
exec 'runtime ftplugin/vim/'.fname.'.vim'
call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.va, 'v') =~# maps.pva, 'Check Visual All mapping.')
12
normal 0vakakakd
call vimtap#Is(getline(1,line('$')), ['" Sample 2', 'let i = 1', '', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
