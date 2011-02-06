" Test on Sample 11, go to first line inside block and :norm vikd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_011.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
3
normal 0vikd
call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ik', 'v') =~# maps.pvi, 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 11', 'catch :quitRequested do', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
