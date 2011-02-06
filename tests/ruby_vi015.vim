" Test on Sample 6, go to start of first nested block and :norm vggikd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
3
normal vggikd
call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ak', 'v') =~# maps.pva, 'Check ar mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 6', 'module Foo', '  class bar', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
