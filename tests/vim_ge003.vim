" Test on Sample 2: Check for redo using repeat.vim
call vimtest#StartTap()
call vimtap#Plan(4)
edit sample_002.vim
let &runtimepath = expand('<sfile>:p:h:h:h').'/vim-repeat,'.&rtp
exec 'runtime ftplugin/vim/'.fname.'.vim'
call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.vi, 'v') =~# maps.pvi, 'Check Visual All mapping.')
9
normal 0dik
13
normal .
call vimtap#Is(getline(1,line('$')), ['" Sample 2', 'let i = 1', '', 'if i', '  let i = 2', 'elseif', '  echom 2', 'else', '  try', '  catch', '    echoe ''Trouble''', '  finally', '  endtry', 'endif'], 'Check if inner redo was correct.')
undo 0
9
normal 0dak
4
normal .
call vimtap#Is(getline(1,line('$')), ['" Sample 2', 'let i = 1', '', ''], 'Check if the selection from "endif" was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
