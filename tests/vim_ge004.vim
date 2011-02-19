" Test on Sample 8: Check for continued lines
call vimtest#StartTap()
call vimtap#Plan(7)
edit sample_008.vim
exec 'runtime ftplugin/vim/'.fname.'.vim'
call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.vi, 'v') =~# maps.pvi, 'Check Visual Inner mapping.')
"4
"normal 0vikd
"call vimtap#Is(getline(1,line('$')), ['" Sample 8', '', 'function s:apropo()', 'if this_line == too_big &&', '      \ is_also_continued == true', 'endif', 'endfunction', '', ''], 'Check if selection was correct.')
"undo
"17
"normal 0vikikikd
"call vimtap#Is(getline(1,line('$')), ['" Sample 8', '', 'function s:apropo()', 'if this_line == too_big &&', '      \ is_also_continued == true', '  " One comment if', '  " end', '  while this &&', '        \ that ||', '        \ those &&', '        \ these', '    echom 4', '    let too_big = false', '    try', '    endtry', '  endwhile', '  echom 9', '  let true = 1', '  let false = 0', 'endif', 'endfunction', '', ''], 'Check if selection was correct.')
"undo
"10
"normal 0dik
"call vimtap#Is(getline(1,line('$')), ['" Sample 8', '', 'function s:apropo()', 'if this_line == too_big &&', '      \ is_also_continued == true', '  " One comment if', '  " end', '  while this &&', '        \ that ||', '        \ those &&', '        \ these', '  endwhile', '  echom 9', '  let true = 1', '  let false = 0', 'endif', 'endfunction', '', ''], 'Check if selection was correct.')
"undo
"14
"normal 0d3ik
"call vimtap#Is(getline(1,line('$')), ['" Sample 8', '', 'function s:apropo()', 'if this_line == too_big &&', '      \ is_also_continued == true', '  " One comment if', '  " end', '  while this &&', '        \ that ||', '        \ those &&', '        \ these', '  endwhile', '  echom 9', '  let true = 1', '  let false = 0', 'endif', 'endfunction', '', ''], 'Check if selection was correct.')
"undo
20
"normal 0dik
echom '-–=|#>····<#|=–-'
silent! normal 2dik
call vimtap#Is(getline(1,line('$')), ['" Sample 8', '', 'function s:apropo()', 'if this_line == too_big &&', '      \ is_also_continued == true', '  " One comment if', '  " end', '  while this &&', '        \ that ||', '        \ those &&', '        \ these', '    echom 4', '    let too_big = false', '    try', '      " Another comment', '      let o = 1', '      for i in range(1,10)', '      endfor', '      undo', '      redo', '  endwhile', '  echom 9', '  let true = 1', '  let false = 0', 'endif', 'endfunction', '', ''], 'Check if selection was correct.')
call vimtest#Quit()
