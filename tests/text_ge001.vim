
" Test to check for mappings with filetype plugin on
call vimtest#StartTap()
call vimtap#Plan(12)
edit sample_001.txt

let b:ktextobjects_start = 'k\d'
let b:ktextobjects_end   = 'e\d'
call ktextobjects#init()

call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.va, 'v') =~# maps.pva, 'Check Visual All mapping.')

call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.vi, 'v') =~# maps.pvi, 'Check Visual Inner mapping.')

call vimtap#Ok(mapcheck(maps.poa, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.oa, 'o') =~# maps.poa, 'Check Op. Pending All mapping.')

call vimtap#Ok(mapcheck(maps.poi, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg(maps.oi, 'o') =~# maps.poi, 'Check Op. Pending Inner mapping.')

5
normal 03dik
call vimtap#Is(getline(1,line('$')), ['k1 fkjg', 'k2 fkjg', 'e3', 'e4'], 'Check if normal 03dik was correct.')
undo
6
normal 0vakd
call vimtap#Is(getline(1,line('$')), ['k1 fkjg', 'k2 fkjg', 'k3 fkjg fkjg', '', 'e2', 'e3', 'e4'], 'Check if normal 0vakd was correct.')
undo
6
normal 0v2ikd
call vimtap#Is(getline(1,line('$')), ['k1 fkjg', 'k2 fkjg', 'k3 fkjg fkjg', 'e2', 'e3', 'e4'], 'Check if normal 0v2ikd was correct.')
undo
exec b:undo_ftplugin
let b:ktextobjects_map = 'j'
call ktextobjects#init()
6
normal 0vijijd
call vimtap#Is(getline(1,line('$')), ['k1 fkjg', 'k2 fkjg', 'k3 fkjg fkjg', 'e2', 'e3', 'e4'], 'Check if normal 0vijijd was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
