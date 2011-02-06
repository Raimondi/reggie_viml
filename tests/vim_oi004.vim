" Test on Sample 6, go to 'for' and :norm 0dik, repeat on 'endfor' and the
" middle of the block.
call vimtest#StartTap()
call vimtap#Plan(5)
edit sample_006.vim
exec 'runtime ftplugin/vim/'.fname.'.vim'
call vimtap#Ok(mapcheck(maps.poi, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.oi, 'o') =~# maps.poi, 'Check Visual All mapping.')
3
normal 0dik
call vimtap#Is(getline(1,line('$')), ['" Sample 6', '', 'for i in range(0,100)', 'endfor'], 'Check if the selection from "for" was correct.')
undo
4
normal 0dik
call vimtap#Is(getline(1,line('$')), ['" Sample 6', '', 'for i in range(0,100)', 'endfor'], 'Check if the selection from "endfor" was correct.')
undo
11
normal 0dik
call vimtap#Is(getline(1,line('$')), ['" Sample 6', '', 'for i in range(0,100)', 'endfor'], 'Check if the selection from inside was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
