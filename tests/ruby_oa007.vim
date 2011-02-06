" Test on Sample 5, go to first line inside nested block and :norm dak, needs
" syntax on to ignore keywords inside strings and comments
call vimtest#StartTap()
call vimtap#Plan(3)
syntax on
edit sample_005.rb
exec 'runtime ftplugin/ruby/'.fname.'.vim'
6
normal ^dak
call vimtap#Ok(mapcheck(maps.poa, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ak', 'o') =~# maps.poa, 'Check ar mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 5', 'class Foo', '  # [cursor]', '  # vir/var should select Foo class', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
