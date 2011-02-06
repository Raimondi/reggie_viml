" Test on Sample 6, go to the middle and :norm vakakd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
7
normal 0vakakd
call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ak', 'v') =~# maps.pva, 'Check ar mapping.')
call vimtap#Is(getline(1,13), ['# Sample 6', 'module Foo', '  class bar', '    catch :quitRequested do', '    ', '    end', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
