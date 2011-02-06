" Test on Sample 1, go inside block and :norm v4akd.
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_001.vim
exec 'runtime ftplugin/vim/'.fname.'.vim'
call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.va, 'v') =~# maps.pva, 'Check Visual All mapping.')
26
normal 0v4akd
call vimtap#Is(getline(1,line('$')), ['" Sample 1', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
