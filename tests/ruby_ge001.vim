" Test to check for mappings with filetype plugin on
call vimtest#StartTap()
call vimtap#Plan(8)
filetype plugin on
edit sample_1.rb

call vimtap#Ok(mapcheck(maps.pva, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ak', 'v') =~# maps.pva, 'Check ar mapping.')

call vimtap#Ok(mapcheck(maps.pvi, 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ik', 'v') =~# maps.pvi, 'Check ar mapping.')

call vimtap#Ok(mapcheck(maps.poa, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ak', 'o') =~# maps.poa, 'Check ar mapping.')

call vimtap#Ok(mapcheck(maps.poi, 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ik', 'o') =~# maps.poi, 'Check ar mapping.')

call vimtest#SaveOut()
call vimtest#Quit()

