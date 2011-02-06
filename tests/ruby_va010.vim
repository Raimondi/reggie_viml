" Test on Sample 11, go to first line inside block and :norm vakd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_011.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
3
normal 0vakd
call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ak', 'v') =~# maps.pva, 'Check ar mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 11', '', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
