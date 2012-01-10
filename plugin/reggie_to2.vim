" FindFrom(pat, pos, forward, middle, ...) {{{1
" Look for a pair.
" Returns position of match.
" - pat: Dictionary with patterns and skip expression.
" - pos: A list in the format accepted by cursor().
" - forward: Boolean.
" - middle: Boolean
function! FindFrom(pat, pos, forward, middle, ...)
  call cursor(a:pos)
  let f_b = a:forward ? '' : 'b'
  let matchHere = FindAt(a:pat, a:pos)
  if matchHere == 'start' && a:forward
    let f_c = ''
  elseif matchHere == 'middle'
    let f_c = ''
  elseif matchHere == 'end' && !a:forward
    let f_c = ''
  else
    let f_c = a:0 && a:1 ? 'c' : ''
  endif
  let flags = 'Wn'.f_b.f_c
  let middle = a:middle ? a:pat.middle : ''
  let end = searchpairpos(a:pat.start, middle, a:pat.end, flags, a:pat.skip)
  return end
endfunction "FindStart

" IsInMatch(pat, pos) i{{{1
" Determine which pattern is found at the given position, if any.
" Returns a dict with the following entries:
"   - kind: Empty if no match found, otherwise the name of the pattern.
"   - start: Boolean, true if the match starts at 'pos'.
"   - end: Boolean, true if the match ends at 'pos'.
"   - first, last: positions of the start and the end of the match
"     respectively.
" pat: Dictionary with patterns and skip expression as used by searchpair().
" pos: A list in the format accepted by cursor().
function! IsInMatch(pat, pos)
  let pos0 = Pos(a:pos)
  let res = NewBoundary()
  let res.start = 0
  let res.end = 0
  let in = 0
  if pos0[0] == 0
    "echoe '"'.string(pos0).'" is not a valid position!'
    return res
  endif
  " Position cursor
  call cursor(pos0)
  for kind in filter(keys(a:pat), 'v:val != "skip" && v:val != ""')
    let pos1 = searchpos(a:pat[kind], 'Wcb', 0, 100)
    if pos1[0] == 0 || eval(a:pat.skip)
      call cursor(pos0)
      continue
    endif
    let pos2 = searchpos(a:pat[kind], 'Wcne', 0, 100)
    if pos2[0] < pos0[0] || (pos2[0] == pos0[0] && pos2[1] < pos0[1])
      call cursor(pos0)
      continue
    endif
    let in = 1
    break
  endfor
  if !in
    return res
  endif
  let res.kind = kind
  let res.start = pos1 == pos0
  let res.end = pos2 == pos0
  let res.first = pos1
  let res.last = pos2
  return res
endfunction "IsInMatch

" FindAt(pat, pos) {{{1
" Determine which pattern is found at the given position, if any.
" Returns an empty string ('') if none found. If a match is found returns the
" name of the matching pattern.
" pat: Dictionary with patterns and skip expression.
" pos: A list in the format accepted by cursor().
function! FindAt(pat, pos)
  " Position cursor
  call cursor(a:pos)
  " Should the current position be skipped?
  let skip = eval(a:pat.skip)
  if skip
    return ''
  endif
  for kind in filter(keys(a:pat), 'v:val != "skip" && v:val != ""')
    if searchpos(a:pat[kind], "cn", line(".")) == a:pos[0:1]
      return kind
    endif
  endfor
  return ''
endfunction "FindAt

" FindTextObject(pat, pos, inner) {{{1
function! FindTextObject(pat, pos, inner)
  let to = NewTextObject()
  let boundary = IsInMatch(a:pat, a:pos)
  if boundary.kind == 'start'
    let to.start.first = boundary.first
    let to.start.last = boundary.last
    let to.start.kind = boundary.kind
    let to.end.first = FindFrom(a:pat, a:pos, 1, a:inner)
    let boundary = IsInMatch(filter(copy(a:pat), 'v:key != "start"'), to.end.first)
    let to.end.last = boundary.last
    let to.end.kind = boundary.kind
  elseif boundary.kind == 'middle' && a:inner
    let to.start.first = boundary.first
    let to.start.last = boundary.last
    let to.start.kind = boundary.kind
    let to.end.first = FindFrom(a:pat, a:pos, 1, a:inner)
    let boundary = IsInMatch(filter(copy(a:pat), 'v:key != "start"'), to.end.first)
    let to.end.last = boundary.last
    let to.end.kind = boundary.kind
  elseif boundary.kind == 'end'
    let to.end.first = boundary.first
    let to.end.last = boundary.last
    let to.end.kind = boundary.kind
    let to.start.first = FindFrom(a:pat, boundary.first, 0, a:inner)
    let boundary = IsInMatch(filter(copy(a:pat), 'v:key != "end"'), to.start.first)
    let to.start.last = boundary.last
    let to.start.kind = boundary.kind
  else
    let to.start.first = FindFrom(a:pat, a:pos, 0, a:inner)
    let boundary = IsInMatch(filter(copy(a:pat), 'v:key != "end"'), to.start.first)
    let to.start.last = boundary.last
    let to.start.kind = boundary.kind
    let to.end.first = FindFrom(a:pat, a:pos, 1, a:inner)
    let boundary = IsInMatch(filter(copy(a:pat), 'v:key != "start"'), to.end.first)
    let to.end.last = boundary.last
    let to.end.kind = boundary.kind
  endif
  let to.kind = TextObjectKind(to)
  return (to.start.first[0] > 0 && to.end.first[0] > 0) ? to : {}
endfunction "FindTextObject

" MatchEnd(pat, pos) {{{1
function! MatchEnd(pat, pos)
  call cursor(a:pos)
  return searchpos(a:pat, 'Wnce')
endfunction "MatchEnd

" SetMarks(pos1, pos2) "{{{1
" Set the `[ and `] marks.
" - pos1, pos2: List
function! SetMarks(pos1, pos2)
  "let gpos1 = [0] + a:pos1 + [0]
  "let gpos2 = [0] + a:pos2 + [0]
  let result1 = setpos("'[", Gpos(a:pos1)) + 1
  let result2 = setpos("']", Gpos(a:pos2)) + 1
  return result1 && result2
endfunction "SetMarks

" Pos(pos) "{{{1
" Returns a list in the format [line, col]
" - pos: List.
function! Pos(pos)
  let len = len(a:pos)
  if len == 2
    return a:pos
  elseif len == 3
    return a:pos[0:1]
  elseif len == 4
    return a:pos[1:2]
  else
    return[0,0]
  endif
endfunction "Pos

" Gpos(pos) "{{{1
" Returns a list in the format used by setpos().
" - pos: List.
function! Gpos(pos)
  let len = len(a:pos)
  if len == 2
    return [0] + a:pos + [0]
  elseif len == 3
    return [0] + a:pos
  elseif len == 4
    return a:pos
  else
    return[0,0,0,0]
  endif
endfunction "Gpos

" ReggieTextObj(dict, visual, inner) "{{{1
" Finds a text object and returns an ex command to select it.
" - dict: Dictionary.
" - visual: Boolean. True for visual mappings.
" - inner: Boolean. True for 'inner' text objects.
function! ReggieTextObj(dict, visual, inner, ...)
  let s:saved_view = winsaveview()
  if !exists('g:log')
    let g:log = ''
  endif
  redir => g:log
  echom '* * '.strftime('%c')
  let last_command = {}
  let inner = get(a:dict, 'force_middle', 0) ? 1 : a:inner
  if a:visual
    " We could be starting from a visual area bigger than one char, so we need
    " to do some extra magic to handle that case.
    let pos1 = Pos(getpos("'<"))
    let pos2 = Pos(getpos("'>"))
    echom '* pos1: '.string(pos1)
    echom '* pos2: '.string(pos2)
    let to = GetTextObjectFromArea(a:dict.pat, pos1, pos2, inner)
    echom '* From area.'
  else
    let pos1 = Pos(getpos('.'))
    let to = FindTextObject(a:dict.pat, pos1, inner)
  endif
  if empty(to)
    return CancelAction(a:visual)
  endif
  let to.orig.start = pos1
  let to.orig.end = a:visual ? pos2 : pos1
  if a:visual
    if !PostProcessTextObject(a:dict, to, a:visual, inner)
      return CancelAction(a:visual)
    endif
    echom '* Dict: '
    if to.orig.start == to.final.start && to.orig.end == to.final.end ||
          \ Contains(to.orig, to.final)
      let to = ExpandTextObject(a:dict.pat, to, a:visual, inner)
      echom '* Dict: '
      if empty(to)
        return CancelAction(a:visual)
      endif
    endif
  endif
  " Handle a given count.
  if a:visual
    let repeat = v:prevcount == 0 ? 0 : v:prevcount - 1
  else
    let repeat = v:count1 - 1
  endif
  for i in range(repeat)
    echom '* repeating ' . (i + 1)
    let to_temp = ExpandTextObject(a:dict.pat, to, a:visual, inner)
    if empty(to_temp)
      break
    endif
    let to = to_temp
  endfor
  if !to.post_processed && !PostProcessTextObject(a:dict, to, a:visual, inner)
    return CancelAction(a:visual)
  endif
  let mode = a:0 ? a:1 : 'v'
  let last_command.to = to
  call SetMarks(to.final.start, to.final.end)
  if a:visual
    let last_command.ex_command = "normal! `[".mode."`]"
  else
    let last_command.ex_command = ":\<C-U>".'exec "normal! `['.mode.'`]"'."\<CR>"
  endif
  echom last_command.ex_command
  redir END
  call winrestview(s:saved_view)
  return last_command.ex_command
endfunction "ReggieTextObj

" GetTextObjectFromArea(pat, pos1, pos2, inner) "{{{1
" Ditto.
function! GetTextObjectFromArea(pat, pos1, pos2, inner)
  if a:pos1 == a:pos2
    return FindTextObject(a:pat, a:pos1, a:inner)
  endif
  let to1 = FindTextObject(a:pat, a:pos1, a:inner)
  let to2 = FindTextObject(a:pat, a:pos2, a:inner)
  echom '* GetTextFromArea'
  let to = ChooseTextObject(to1, to2)
  if empty(to) && !empty(to1) && !empty(to2) &&
        \ to1.end.kind == 'middle' && to2.start.kind == 'middle'
    let to_all = FindTextObject(a:pat, a:pos1, 0)
    echom '* Repeat on middles'
    if ContainsOrEqual(to_all, to1) && ContainsOrEqual(to_all, to2)
      let to = to1
      let to.end = to2.end
      let to.kind = TextObjectKind(to)
    else
      return {}
    endif
  endif
  if empty(to)
    return {}
  endif
  return to
endfunction "GetTextObjectFromArea

" NewTextObject(...) "{{{1
" Returns a new text object, if a dict is given the keys will be merged with
" exception of the 'start', 'end' and 'post_processed'.
function! NewTextObject(...)
  let to = {'start': NewBoundary(),
        \ 'end': NewBoundary(),
        \ 'orig': {'start': 0, 'end': 0},
        \ 'final': {'start': 0, 'end': 0},
        \ 'kind': '',
        \ 'post_processed': 0}
  return a:0 ? extend(copy(a:1), to, 'force') : to
endfunction "NewTextObject

" ChooseTextObject(to1, to2) "{{{1
" Choose the text object that contains the other, if any.
function! ChooseTextObject(to1, to2)
  if empty(a:to1) || empty(a:to2)
    return {}
  endif
  if a:to1 == a:to2
    return a:to1
  endif
  let area1 = {'start': a:to1.start.first, 'end': a:to1.end.last}
  let area2 = {'start': a:to2.start.first, 'end': a:to2.end.last}
  if Contains(area1, area2)
    return a:to1
  elseif Contains(area2, area1)
    return a:to2
  else
    return {}
  endif
endfunction "ChooseTextObject

" BeforeThan(pos1, pos2) "{{{1
" Return 1 if pos1 is before pos2, 0 otherwise.
function! BeforeThan(pos1, pos2)
  let pos1 = Pos(a:pos1)
  let pos2 = Pos(a:pos2)
  return pos1[0] < pos2[0] ||
        \ (pos1[0] == pos2[0] && pos1[1] < pos2[1])
endfunction "BeforeThan

" BeforeThanOrEqualTo(pos1, pos2) "{{{1
" Return 1 if pos1 is before pos2, 0 otherwise.
function! BeforeThanOrEqualTo(pos1, pos2)
  let pos1 = Pos(a:pos1)
  let pos2 = Pos(a:pos2)
  return BeforeThan(pos1, pos2) ||
        \ pos1 == pos2
endfunction "BeforeThanOrEqualTo

" AfterThan(pos1, pos2) "{{{1
" Returns 1 if pos1 is after pos2, 0 otherwise.
function! AfterThan(pos1, pos2)
  let pos1 = Pos(a:pos1)
  let pos2 = Pos(a:pos2)
  return BeforeThan(pos2, pos1)
endfunction "AfterThan

" AfterThanOrEqualTo(pos1, pos2) "{{{1
" Returns 1 if pos1 is after pos2, 0 otherwise.
function! AfterThanOrEqualTo(pos1, pos2)
  let pos1 = Pos(a:pos1)
  let pos2 = Pos(a:pos2)
  return BeforeThan(pos2, pos1) ||
        \ pos1 == pos2
endfunction "AfterThanOrEqualTo

" Contains(area1, area2) "{{{1
" Returns 1 if obj1 contains obj2, 0 otherwise.
" - obj1, obj2: Dictionaries with two entries named 'start' and 'end'.
function! Contains(obj1, obj2)
  if type(a:obj1.end) == type([])
    let obj1 = map(copy(a:obj1), 'Pos(v:val)')
    let obj2 = map(copy(a:obj2), 'Pos(v:val)')
    return BeforeThan(obj1.start, obj2.start) &&
          \ AfterThan(obj1.end, obj2.end)
  elseif type(a:obj1.end) == type({})
    return BeforeThan(a:obj1.start.last, a:obj2.start.first) &&
          \ AfterThan(a:obj1.end.first, a:obj2.end.last)
  endif
endfunction "Contains

" ContainsOrEqual(area1, area2) "{{{1
" Returns 1 if obj1 contains obj2, 0 otherwise.
" - obj1, obj2: Dictionaries with two entries named 'start' and 'end'.
function! ContainsOrEqual(obj1, obj2)
  if type(a:obj1.end) == type([])
    let obj1 = map(copy(a:obj1), 'Pos(v:val)')
    let obj2 = map(copy(a:obj2), 'Pos(v:val)')
    return BeforeThanOrEqualTo(obj1.start, obj2.start) &&
          \ AfterThanOrEqualTo(obj1.end, obj2.end)
  elseif type(a:obj1.end) == type({})
    return BeforeThanOrEqualTo(a:obj1.start.first, a:obj2.start.first) &&
          \ AfterThanOrEqualTo(a:obj1.end.last, a:obj2.end.last)
  endif
endfunction "ContainsOrEqual

" PostProcessTextObject(dict, to, visual, inner) "{{{1
" description
function! PostProcessTextObject(dict, to, visual, inner) abort
  let a:to.post_processed = 1
  "return [a:to.start.first, a:to.end.last]
  if a:inner
    call PostProcessInner(a:dict, a:to, a:visual)
  else
    call PostProcessAll(a:dict, a:to, a:visual)
  endif
  echom '* Postprocessed.'
  if BeforeThan(a:to.final.start, a:to.final.end)
    return 1
  else
    return 0
  end
endfunction "PostProcessTextObject

" PostProcessAll(dict, to, visual) "{{{1
"
function! PostProcessAll(dict, to, visual)
  let a:to.final.start = copy(a:to.start.first)
  let a:to.final.end = copy(a:to.end.last)
endfunction "PostProcessAll

" PostProcessInner(dict, to, visual) "{{{1
"
function! PostProcessInner(dict, to, visual)
  if len(getline(a:to.start.last[0])) > a:to.start.last[1]
    let a:to.final.start = [a:to.start.last[0], a:to.start.last[1] + 1]
  else
    let a:to.final.start = [a:to.start.last[0] + 1, 1]
  endif
  if a:to.end.first[1] > 1
    let a:to.final.end = [a:to.end.first[0], a:to.end.first[1] - 1]
  else
    let a:to.final.end = [a:to.end.first[0] - 1, len(getline(a:to.end.first[0] - 1))]
  endif
endfunction "PostProcessInner

" CancelAction(visual) "{{{1
" Return a string that will cancel the action.
function! CancelAction(visual)
  call winrestview(s:saved_view)
  redir END
  return a:visual ? '' : "\<Esc>"
endfunction "CancelAction

" ExpandTextObject(pat, to, visual, inner) "{{{1
" Find a container text object, if any.
function! ExpandTextObject(pat, to, visual, inner)
  echom '* ETO.a:to: '
  echom string(a:to)
  let to = NewTextObject(a:to)
  echom '* ETO2'
  if a:to.kind == 'top' || a:to.kind == 'middle'
    let to.start = a:to.start
    let to.end = ExpandBoundary(a:pat, a:to.end, 1, a:visual, 1)
  elseif a:to.kind == 'bottom'
    let to.start = ExpandBoundary(a:pat, a:to.start, 0, a:visual, 1)
    let to.end = a:to.end
  elseif a:to.kind == 'whole'
    let to.start = ExpandBoundary(a:pat, a:to.start, 0, a:visual, 1)
    let to.end = ExpandBoundary(a:pat, a:to.end, 1, a:visual, 1)
  else
    return {}
  endif
  if to.start == a:to.start && to.end == a:to.end
    return {}
  endif
  let to.kind = TextObjectKind(to)
  echom string(a:to)
  return to
endfunction "ExpandTextObject

" ExpandBoundary(pat, to, forward, visual) "{{{1
" Expand boundary of the given text object.
function! ExpandBoundary(pat, boundary, forward, visual, inner)
  let boundary = NewBoundary(a:boundary)
  let boundary.first = FindFrom(a:pat, a:boundary.first, a:forward, a:inner, 0)
  if boundary.first[0] == 0
    return a:boundary
  else
    let boundary_temp = IsInMatch(a:pat, boundary.first)
    let boundary.last = boundary_temp.last
    let boundary.kind = boundary_temp.kind
    return boundary
  endif
endfunction "ExpandTop

" NewBoundary(...) "{{{1
" Returns a new boundary, if a boundary is given it will be merged.
function! NewBoundary(...)
  let boundary = {
        \ 'first': [0,0],
        \ 'last': [0,0],
        \ 'kind': ''}
  return a:0 ? extend(copy(a:1), boundary, 'force') : boundary
endfunction "NewBoundary

" TextObjectKind(to) "{{{1
" Checks what kind of text objects was given.
function! TextObjectKind(to)
  if a:to.start.kind == 'start' && a:to.end.kind == 'middle'
    return 'top'
  elseif a:to.start.kind == 'middle' && a:to.end.kind == 'end'
    return 'bottom'
  elseif a:to.start.kind == 'middle' && a:to.end.kind == 'middle'
    return 'middle'
  elseif a:to.start.kind == 'start' && a:to.end.kind == 'end'
    return 'whole'
  else
    return ''
  endif
endfunction "TextObjectKind

" Temporal stuff {{{1
" Patterns' dict
let pat = {}
" VimL settings:
let pat.skip =
      \ 'getline(".") =~ "^\\s*sy\\%[ntax]\\s\\+region" ||' .
      \ 'synIDattr(synID(line("."),col("."),1),"name") =~? '.
      \ '"\\mcomment\\|string\\|vim\k\{-}var"'
" Start of the block matches this
let pat.start = '\C\m\%(^\||\)\s*\zs\%('.
      \ '\<fu\%[nction]\>\|\<\%(wh\%[ile]\|for\)\>\|\<if\>\|\<try\>\|'.
      \ '\<aug\%[roup]\s\+\%(END\>\)\@!\S'.
      \ '\)'
" Middle of the block matches this
let pat.middle = '\C\m\%(^\||\)\s*\zs\%(\<el\%[seif]\>\|\<cat\%[ch]\>\|\<fina\%[lly]\>\)'
" End of the block matches this
let pat.end =
      \ '\C\m\%(^\||\)\s*\zs\%(\<endf\%[unction]\>\|\<end\%(w\%[hile]\|fo\%[r]\)\>\|'.
      \ '\<en\%[dif]\>\|\<endt\%[ry]\>\|\<aug\%[roup]\s\+END\>\)'
let dict = {}
let dict.pat = pat
let dict.intersect_txtobjs = 0
onoremap <expr> ax ReggieTextObj(dict, 0, 0)
onoremap <expr> ix ReggieTextObj(dict, 0, 1)
vnoremap  ax <Esc>:exec ReggieTextObj(dict, 1, 0, visualmode())<CR><Esc>gv
vnoremap  ix <Esc>:exec ReggieTextObj(dict, 1, 1, visualmode())<CR><Esc>gv
"

finish "{{{1
if 1
  if 2
  elseif
  elseif | elseif
    echo 1
  else
  endif
  if 1
    echo 1
  else
    echo 2
  endif
else
  echo 2
endif
if {
  if {
    zldkfh
    aljdh
     }
    }
