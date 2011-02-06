" Test on Sample 1, go to class and :norm vakd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_001.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
2
normal 0vakd
call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ak', 'v') =~# maps.pva, 'Check ar mapping.')
call vimtap#Is(getline(1,4), ['# Sample 1', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
