" Test on Sample 20, go to start of nested block and :norm vikd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_020.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
5
normal ^vikd
call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ik', 'v') =~# maps.pvi, 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 20', 'class Sample', '  include A', '  include B', '  ef s1', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
