" Test on Sample 6, go to the middle and :norm vikikd
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
7
normal 0vikikd
call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ik', 'v') =~# maps.pvi, 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 6', 'module Foo', '  class bar', '    catch :quitRequested do', '    def baz', '    end', '    end', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
