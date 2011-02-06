" Test on Sample 5, go to first line inside nested block and :norm dik, needs
" syntax on to ignore keywords inside strings and comments
call vimtest#StartTap()
call vimtap#Plan(3)
syntax on
edit sample_005.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
6
normal ^dik
call vimtap#Ok(mapcheck(maps.poi, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ik', 'o') =~# maps.poi, 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 5', 'class Foo', '  # [cursor]', '  # vir/var should select Foo class', '  if true', '  elsif false', '    # for each ''end'', remove *keyword* from stack', '    # if an ''end'' is found when stack is empty, jump to match ''%''', '  else', '    puts ''do'' # This line is not a loop just because do appears on it.', '    # selecting ''all'' of an if/else construct means from the opening', '    # ''if'' to the closing ''end''.', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
