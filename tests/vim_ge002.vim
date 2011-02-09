" Test on Sample 2: Check for behaviour of gU
call vimtest#StartTap()
call vimtap#Plan(4)
edit sample_002.vim
exec 'runtime ftplugin/vim/'.fname.'.vim'
call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.vi, 'v') =~# maps.pvi, 'Check Visual All mapping.')
9
normal 0gUak
call vimtap#Is(getline(1,line('$')), ['" Sample 2', 'let i = 1', '', 'if i', '  let i = 2', 'elseif', '  echom 2', 'else', '  TRY', '    CALL SYSTEM(''ECHO 1'')', '  CATCH', '    ECHOE ''TROUBLE''', '  FINALLY', '    ECHOM 3', '  ENDTRY', 'endif'], 'Check if all was right was correct.')
undo
8
normal 0gUik
call vimtap#Is(getline(1,line('$')), ['" Sample 2', 'let i = 1', '', 'if i', '  let i = 2', 'elseif', '  echom 2', 'else', '  TRY', '    CALL SYSTEM(''ECHO 1'')', '  CATCH', '    ECHOE ''TROUBLE''', '  FINALLY', '    ECHOM 3', '  ENDTRY', 'endif'], 'Check if inner was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
