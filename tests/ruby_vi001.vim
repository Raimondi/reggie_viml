" Test on Sample 1, go to class and :norm vikd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_001.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
2
normal 0vikd
call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ik', 'v') =~# maps.pvi, 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 1', 'class Foo', 'end'], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()

