" Test on Sample 1, go to class and :norm dak
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_001.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
2
normal 0dak
call vimtap#Ok(mapcheck(maps.poa, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ak', 'o') =~# maps.poa, 'Check ar mapping.')
call vimtap#Is(getline(1,4), ['# Sample 1', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
