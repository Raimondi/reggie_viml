" Test on Sample 6, go to last end and norm dik
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
12
normal ^dik
call vimtap#Ok(mapcheck(maps.poi, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ik', 'o') =~# maps.poi, 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 6', 'module Foo', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
