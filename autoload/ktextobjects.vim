" File:        autoload/ktextobjects.vim
" Version:     0.1a
" Modified:    2011-00-00
" Description: This plugin provides new text objects for keyword based blocks.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      The new text objects are 'ik' and 'ak'. Place this file in
"              'autoload/' inside $HOME/.vim or somewhere else in your
"              runtimepath.
"
"              :let testing_KeywordTextObjects = 1 to allow reloading of the
"              plugin without closing Vim.
"
"              Multiple sentences on a single line are not handled by this
"              plugin, the text objects might not work or work in an
"              unexpected way.
"
" Pending:     - Consider continued lines for inner text objects.
" ============================================================================

" Functions {{{1
" Load guard {{{2
if exists('testing_KeywordTextObjects')
  echom '----Loaded on: '.strftime("%Y %b %d %X")

  function! Test(first, last, test,...)
    if a:test == 1
      return s:Match(a:first, b:kto.start_p).', '.s:Match(a:first, b:kto.middle_p).', '.s:Match(a:first, b:kto.end_p)
    elseif a:test == 2
      return s:FindTextObject([a:first,0], [a:last,0], b:kto.middle_p)
    elseif a:test == 3
      return searchpairpos(b:kto.start_p, b:kto.middle_p, b:kto.end_p, a:1, b:kto.skip_e)
    elseif a:test == 4
      return match(getline('.'), 'bWn')
    elseif a:test == 5
      return searchpos(b:kto.start_p,'bn')
    else
      throw 'Ooops!'
    endif
  endfunction
  command! -bar -range -buffer -nargs=+ Test echom string(Test(<line1>, <line2>, <f-args>))
endif
let loaded_KeywordTextObjects = '0.1a'
 "}}}2

function! ktextobjects#init() "{{{1

  " Set b:undo_ftplugin
  let s:undo_ftplugin =
        \ 'sil! ounmap <buffer> ak|sil! ounmap <buffer> ik|'.
        \ 'sil! vunmap <buffer> ak|sil! vunmap <buffer> ik'.
        \ 'sil! unlet b:kto'
  if exists('b:undo_ftplugin') && b:undo_ftplugin !~ 'vunmap <buffer> ar'
    if b:undo_ftplugin =~ '^\s*$'
      let b:undo_ftplugin = s:undo_ftplugin
    else
      let b:undo_ftplugin = s:undo_ftplugin.'|'.b:undo_ftplugin
    endif
  elseif !exists('b:undo_ftplugin')
    let b:undo_ftplugin = s:undo_ftplugin
  endif

  " Create <Plug>mappings
  onoremap <silent> <buffer> <expr> <Plug>KeywordTextObjectsAll
        \ ktextobjects#TextObjectsAll(0)

  onoremap <silent> <buffer> <expr> <Plug>KeywordTextObjectsInner
        \ ktextobjects#TextObjectsInner(0)

  vnoremap <silent> <buffer> <Plug>KeywordTextObjectsAll
        \ :call ktextobjects#TextObjectsAll(1)<CR><Esc>gv

  vnoremap <silent> <buffer> <Plug>KeywordTextObjectsInner
        \ :call ktextobjects#TextObjectsInner(1)<CR><Esc>gv

  " Create useful mappings
  if !exists('testing_KeywordTextObjects')
    " Be nice with existing mappings

    if !hasmapto('<Plug>KeywordTextObjectsAll', 'o')
      omap <unique> <buffer> ak <Plug>KeywordTextObjectsAll
    endif

    if !hasmapto('<Plug>KeywordTextObjectsInner', 'o')
      omap <unique> <buffer> ik <Plug>KeywordTextObjectsInner
    endif

    if !hasmapto('<Plug>KeywordTextObjectsAll', 'v')
      vmap <unique> <buffer> ak <Plug>KeywordTextObjectsAll
    endif

    if !hasmapto('<Plug>KeywordTextObjectsInner', 'v')
      vmap <unique> <buffer> ik <Plug>KeywordTextObjectsInner
    endif
  else
    " Unless we are testing, be merciless in this case
    silent! ounmap <buffer> ak
    silent! ounmap <buffer> ik
    silent! vunmap <buffer> ak
    silent! vunmap <buffer> ik
    omap <buffer> ak <Plug>KeywordTextObjectsAll
    omap <buffer> ik <Plug>KeywordTextObjectsInner
    vmap <buffer> ak <Plug>KeywordTextObjectsAll
    vmap <buffer> ik <Plug>KeywordTextObjectsInner
  endif

endfunction "}}}1

function! ktextobjects#TextObjectsAll(visual) range "{{{2
  let lastline      = line('$')
  let start         = [0,0]
  let middle_p      = ''
  let end           = [-1,0]
  let count1        = v:count1 < 1 ? 1 : v:count1

  let t_start = [a:firstline + 1, 0]
  let t_end   = [a:lastline  - 1, 0]
  let passes  = 0

  let match_both_outer = (
        \ s:Match(t_start[0] - 1, b:kto.start_p) &&
        \ s:Match(t_end[0] + 1, b:kto.end_p))
  while  count1 > 0 &&
        \ (!(count1 > 1) || (t_start[0] - 1 > 1 && t_end[0] + 1 < lastline))
    let passes  += 1

    " Let's get some luv
    let [t_start, t_end] = s:FindTextObject([t_start[0] - 1, 0], [t_end[0] + 1, 0], middle_p)

    "echom string(t_start).';'.string(t_end).':'.passes
    if t_start[0] > 0 && t_end[0] > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    " Repeat if necessary
    if match_both_outer && passes == 1 &&
          \ start[0] == a:firstline && end[0] == a:lastline
      continue
    endif
    let count1  -= 1
  endwhile

  if a:visual
    if end[0] >= start[0] && start[0] >= 1 && end[0] >= 1
      " Do visual magic
      exec "normal! \<Esc>"
      call cursor(start)
      exec "normal! v".end[0]."G$h"
      "echom string(start).';'.string(end).':'.passes
    endif
  else
    if end[0] >= start[0] && start[0] >= 1 && end[0] >= 1
      " Do operator pending magic
      "echom getline(start[0])[:start[1] - 2]
      if start[1] <= 1 || getline(start[0])[:start[1] - 2] =~ '^\s*$'
        " Delete whole lines
        let to_eol   = '$'
        let from_bol = '0'
      else
        " Don't delete text behind start of block and leave one <CR>
        let to_eol   = '$h'
        let from_bol = ''
      endif
      return ':call cursor('.string(start).')|exec "normal! '.from_bol.'v'.end[0]."G".to_eol."\"\<CR>"
    else
      " No pair found, do nothing
      return "\<Esc>"
    endif
  endif

endfunction " }}}2

function! ktextobjects#TextObjectsInner(visual, ...) range "{{{2
  " Recursing?
  if a:0
    let firstline = a:1
    let lastline  = a:2
    let count1    = a:3 - 1
    let original  = [[firstline, 1], [lastline, len(getline(lastline)) + 1]]
  else
    let firstline = a:firstline
    let lastline  = a:lastline
    let count1    = v:count1 < 1 ? 1 : v:count1
    let original  = [getpos("'<")[1:2], getpos("'>")[1:2]]
  endif
  let line_eof    = line('$')
  let current     = {'start': [firstline,0], 'end': [lastline,0]}
  let middle_p    = b:kto.middle_p
  let l:count     = 0
  let d_start     = 0
  let d_end       = 0
  let i           = 0

  while i <= 2 && (current.start[0] + d_start) > 0 && (current.end[0] + d_end) <= line_eof
    let i += 1
    " Get a text object
    let [current.start, current.end] = s:FindTextObject(
          \ [current.start[0] + d_start, 0], [current.end[0] + d_end, 0], middle_p)
    "echom 'Current: '.string(current).', count: '.i
    " If it's null, stop looking
    if [current.start, current.end] == [[0,0],[0,0]]
      break
    endif
    let is_block = 0
    if [firstline, lastline] == [current.start[0], current.end[0]]
      " The original selection's range is the same as the one from the text
      " object.
      " It is a whole block
      let is_block = 1
    endif
    let is_repeat = 0
    " Find out what to do {{{
    " If:
    " - Is visual? AND
    "   - Is repeated? OR
    "   - Is the selection a previously selected text block?
    if a:visual
          \ && (a:0
          \     || (original[0][1] == 1
          \         && original[1][1] >= len(getline(getpos("'>")[1])) + 1))

      " Determine what is selected
      if getline(firstline - 1) =~ b:kto.middle_p ||
            \ getline(lastline + 1) =~ b:kto.middle_p
        " The line over and/or under matches a b:kto.middle_p
        if !is_block
          " It is repeated with an inner middle block
          let is_repeat = 4
          let middle_p = ''
          let d_start  = 0
          let d_end    = 0
        else
          " It is repeated with an inner middle block and a whole block
          let is_repeat = 3
          let middle_p = ''
          let d_start  = -1
          let d_end    = 1
        endif
      elseif [firstline - 1, lastline + 1] == [current.start[0], current.end[0]]
        " The text object limits are just over and under the original
        " selection
        " It is repeated, with an inner block
        let is_repeat = 2
        let d_start  = -1
        let d_end    = 1
      elseif is_block
        " It is repeated, with a whole block
        let is_repeat = 1
        let d_start  = -1
        let d_end    = 1
      endif
    endif "}}}
    "echom 'is_repeat: '.is_repeat.', is_block: '.is_block

    if is_repeat == 0
      " No need to loop
      break
    endif
  endwhile

  "echom 'Current: '.string(current).', count1: '.count1
  if count1 > 1
    " Let's recurse
    let current = ktextobjects#TextObjectsInner(a:visual, current.start[0] + 1, current.end[0] - 1, count1)
  endif
  if a:0
    return current
  endif
  if a:visual
    if current.end[0] >= current.start[0] && current.start[0] >= 1 && current.end[0] >= 1 && current.end[0] - current.start[0] > 1
      " Do visual magic
      exec "normal! \<Esc>".(current.start[0] + 1).'G'
      exec "normal! 0v".(current.end[0] - 1)."G$"
    endif
  else
    if current.end[0] >= current.start[0] && current.start[0] >= 1 && current.end[0] >= 1 && current.end[0] - current.start[0] > 1
      " Do operator pending magic
      return ':exec "normal! '.(current.start[0] + 1)
            \ .'G0v'.(current.end[0] - 1)."G$\"\<CR>"
    else
      " No pair found, do nothing
      return "\<Esc>"
    endif
  endif
endfunction "}}}2

function! s:FindTextObject(first, last, middle, ...) "{{{2
  if a:0
    let l:count = a:1 + 1
  else
    let l:count = 1
  endif
  "echom 'FTO count: '.l:count
  if a:first[0] > a:last[0]
    throw 'Muy mal... a:first > a:last'
  endif
  "echom 'Range : '.string([a:first, a:last])

  let first = {'start':[0,0], 'end':[0,0], 'range':0}
  let last  = {'start':[0,0], 'end':[0,0], 'range':0}

  " searchpair() starts looking at the cursor position. Find out where that
  " should be. Also determine if the current line should be searched.
  if s:Match(a:first[0], b:kto.end_p)
    let spos   = 1
    let sflags = b:kto.flags.'b'
  else
    let spos   = 9999
    let sflags = b:kto.flags.'bc'
  endif

  " Let's see where they are
  call cursor(a:first[0], spos)
  let first.start  = searchpairpos(b:kto.start_p,a:middle,b:kto.end_p,sflags,b:kto.skip_e)

  if a:middle == ''
    let s_match = s:Match(a:first[0], b:kto.start_p)
  else
    let s_match = s:Match(a:first[0], b:kto.start_p) || s:Match(a:first[0], a:middle)
  endif
  if s_match
    let epos   = 9999
    let eflags = b:kto.flags
  else
    let epos   = 1
    let eflags = b:kto.flags.'c'
  endif

  " Let's see where they are
  call cursor(a:first[0], epos)
  let first.end    = searchpairpos(b:kto.start_p,a:middle,b:kto.end_p,eflags,b:kto.skip_e)

  "echom 'First : '.string([first.start, first.end])
  if a:first == a:last
    let result = [first.start, first.end]
  else
    let [last.start, last.end] = s:FindTextObject(a:last, a:last, a:middle, l:count)
    "echom 'Last  : '.string([last.start, last.end])

    let first.range  = first.end[0] - first.start[0]
    let last.range   = last.end[0] - last.start[0]
    if first.end[0] <= last.start[0] &&
          \ (getline(first.end[0])  =~ b:kto.middle_p && first.range > 0) &&
          \ (getline(last.start[0]) =~ b:kto.middle_p && last.range  > 0)
      " Looks like a middle inner match, start over without looking for
      " b:kto.middle_p
      let result = s:FindTextObject(a:first, a:last, '', 1)

    else
      " Now, decide what to return
      if first.range > last.range
        if first.start[0] <= last.start[0] && first.end[0] >= last.end[0]
          " last is inside first
          let result = [first.start, first.end]
        elseif last.range == 0
          " Last is null
          let result = [first.start, first.end]
        else
          " Something is wrong, last is not inside first
          let result = [[0,0],[0,0]]
        endif
      elseif first.range < last.range
        if first.start[0] >= last.start[0] && first.end[0] <= last.end[0]
          " first is inside last
          let result = [last.start, last.end]
        elseif first.range == 0
          " first is null
          let result = [last.start, last.end]
        else
          " Something is wrong, first is not inside last
          let result = [[0,0],[0,0]]
        endif
      else
        if first.start[0] == last.start[0]
          " first and last are the same
          let result = [first.start, first.end]
        else
          " first and last are not the same
          "let result = [a:first, a:last]
          let result = [[0,0],[0,0]]
        endif
      endif

    endif
  endif
  "echom 'Result: '.string(result) . ', first: ' . string(first) . ', last' .
        \ string(last). ', spos: ' . spos . ', sflags: ' . sflags . ', epos: ' . epos . ', eflags: ' . eflags. '. middle_p: '.a:middle
  return result

endfunction "}}}2

function! s:Match(line, part) " {{{2
  call cursor(a:line, 1)
  let result = search(a:part, 'cW', a:line) > 0 && !eval(b:kto.skip_e)
  "echom result
  return result
endfunction " }}}2

" vim: set et sw=2 sts=2 tw=78: {{{1
