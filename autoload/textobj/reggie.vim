" Old code {{{9
" FindFrom(pattern, pos, forward, middle, ...) {{{16
" Look for a pair.
" Returns position of match.
" - pattern: Dictionary with patterns and skip expression.
" - pos: A list in the format accepted by cursor().
" - forward: Boolean.
" - middle: Boolean
function! FindFrom(pattern, pos, forward, middle, ...)
  call cursor(a:pos)
  let f_b = a:forward ? '' : 'b'
  let matchHere = FindAt(a:pattern, a:pos)
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
  let middle = a:middle ? a:pattern.middle : ''
  let end = searchpairpos(a:pattern.start, middle, a:pattern.end, flags, a:pattern.skip)
  return end
endfunction "FindStart

" GetBoundary(pattern, pos) {{{16
" Determine which pattern is found at the given position, if any.
" Returns a dict with the following entries:
"   - kind: Empty if no match found, otherwise the name of the pattern.
"   - start: Boolean, true if the match starts at 'pos'.
"   - end: Boolean, true if the match ends at 'pos'.
"   - first, last: positions of the start and the end of the match
"     respectively.
" pattern: Dictionary with patterns and skip expression as used by searchpair().
" pos: A list in the format accepted by cursor().
function! GetBoundary(pattern, pos)
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
  for kind in keys(filter(copy(a:pattern), 'v:key != "skip" && v:val != ""'))
    let pos1 = searchpos(a:pattern[kind], 'Wcb', 0, 100)
    if pos1[0] == 0 || eval(a:pattern.skip)
      call cursor(pos0)
      continue
    endif
    let pos2 = searchpos(a:pattern[kind], 'Wcne', 0, 100)
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
endfunction "GetBoundary

" FindAt(pattern, pos) {{{16
" Determine which pattern is found at the given position, if any.
" Returns an empty string ('') if none found. If a match is found returns the
" name of the matching pattern.
" pattern: Dictionary with patterns and skip expression.
" pos: A list in the format accepted by cursor().
function! FindAt(pattern, pos)
  " Position cursor
  call cursor(a:pos)
  " Should the current position be skipped?
  let skip = eval(a:pattern.skip)
  if skip
    return ''
  endif
  for kind in keys(filter(copy(a:pattern), 'v:key != "skip" && v:val != ""'))
    if searchpos(a:pattern[kind], "cn", line(".")) == a:pos[0:1]
      return kind
    endif
  endfor
  return ''
endfunction "FindAt

" FindTextObject(pattern, pos, inner) {{{16
function! FindTextObject(pattern, pos, inner)
  let to = NewTextObject()
  let boundary = GetBoundary(a:pattern, a:pos)
  if boundary.kind == 'start'
    let to.start.first = boundary.first
    let to.start.last = boundary.last
    let to.start.kind = boundary.kind
    let to.end.first = FindFrom(a:pattern, a:pos, 1, a:inner)
    let boundary = GetBoundary(filter(copy(a:pattern), 'v:key != "start"'), to.end.first)
    let to.end.last = boundary.last
    let to.end.kind = boundary.kind
  elseif boundary.kind == 'middle' && a:inner
    let to.start.first = boundary.first
    let to.start.last = boundary.last
    let to.start.kind = boundary.kind
    let to.end.first = FindFrom(a:pattern, a:pos, 1, a:inner)
    let boundary = GetBoundary(filter(copy(a:pattern), 'v:key != "start"'), to.end.first)
    let to.end.last = boundary.last
    let to.end.kind = boundary.kind
  elseif boundary.kind == 'end'
    let to.end.first = boundary.first
    let to.end.last = boundary.last
    let to.end.kind = boundary.kind
    let to.start.first = FindFrom(a:pattern, boundary.first, 0, a:inner)
    let boundary = GetBoundary(filter(copy(a:pattern), 'v:key != "end"'), to.start.first)
    let to.start.last = boundary.last
    let to.start.kind = boundary.kind
  else
    let to.start.first = FindFrom(a:pattern, a:pos, 0, a:inner)
    let boundary = GetBoundary(filter(copy(a:pattern), 'v:key != "end"'), to.start.first)
    let to.start.last = boundary.last
    let to.start.kind = boundary.kind
    let to.end.first = FindFrom(a:pattern, a:pos, 1, a:inner)
    let boundary = GetBoundary(filter(copy(a:pattern), 'v:key != "start"'), to.end.first)
    let to.end.last = boundary.last
    let to.end.kind = boundary.kind
  endif
  let to.kind = TextObjectKind(to)
  return (to.start.first[0] > 0 && to.end.first[0] > 0) ? to : {}
endfunction "FindTextObject

" SetMarks(pos1, pos2) "{{{16
" Set the `[ and `] marks.
" - pos1, pos2: List
function! SetMarks(pos1, pos2)
  "let gpos1 = [0] + a:pos1 + [0]
  "let gpos2 = [0] + a:pos2 + [0]
  let result1 = setpos("'[", Gpos(a:pos1)) + 1
  let result2 = setpos("']", Gpos(a:pos2)) + 1
  return result1 && result2
endfunction "SetMarks

" Pos(pos) "{{{16
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

" Gpos(pos) "{{{16
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

" ReggieTextObj(dict, visual, inner) "{{{16
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
    let to = GetTextObjectFromArea(a:dict.pattern, pos1, pos2, inner)
    echom '* From area.'
  else
    let pos1 = Pos(getpos('.'))
    let to = FindTextObject(a:dict.pattern, pos1, inner)
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
      let to = ExpandTextObject(a:dict.pattern, to, a:visual, inner)
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
    let to_temp = ExpandTextObject(a:dict.pattern, to, a:visual, inner)
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

" GetTextObjectFromArea(pattern, pos1, pos2, inner) "{{{16
" Ditto.
function! GetTextObjectFromArea(pattern, pos1, pos2, inner)
  if a:pos1 == a:pos2
    return FindTextObject(a:pattern, a:pos1, a:inner)
  endif
  let to1 = FindTextObject(a:pattern, a:pos1, a:inner)
  let to2 = FindTextObject(a:pattern, a:pos2, a:inner)
  echom '* GetTextFromArea'
  let to = ChooseTextObject(to1, to2)
  if empty(to) && !empty(to1) && !empty(to2) &&
        \ to1.end.kind == 'middle' && to2.start.kind == 'middle'
    let to_all = FindTextObject(a:pattern, a:pos1, 0)
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

" NewTextObject(...) "{{{16
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

" ChooseTextObject(to1, to2) "{{{16
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

" BeforeThan(pos1, pos2) "{{{16
" Return 1 if pos1 is before pos2, 0 otherwise.
function! BeforeThan(pos1, pos2)
  let pos1 = Pos(a:pos1)
  let pos2 = Pos(a:pos2)
  return pos1[0] < pos2[0] ||
        \ (pos1[0] == pos2[0] && pos1[1] < pos2[1])
endfunction "BeforeThan

" BeforeThanOrEqualTo(pos1, pos2) "{{{16
" Return 1 if pos1 is before pos2, 0 otherwise.
function! BeforeThanOrEqualTo(pos1, pos2)
  let pos1 = Pos(a:pos1)
  let pos2 = Pos(a:pos2)
  return BeforeThan(pos1, pos2) ||
        \ pos1 == pos2
endfunction "BeforeThanOrEqualTo

" AfterThan(pos1, pos2) "{{{16
" Returns 1 if pos1 is after pos2, 0 otherwise.
function! AfterThan(pos1, pos2)
  let pos1 = Pos(a:pos1)
  let pos2 = Pos(a:pos2)
  return BeforeThan(pos2, pos1)
endfunction "AfterThan

" AfterThanOrEqualTo(pos1, pos2) "{{{16
" Returns 1 if pos1 is after pos2, 0 otherwise.
function! AfterThanOrEqualTo(pos1, pos2)
  let pos1 = Pos(a:pos1)
  let pos2 = Pos(a:pos2)
  return BeforeThan(pos2, pos1) ||
        \ pos1 == pos2
endfunction "AfterThanOrEqualTo

" Contains(area1, area2) "{{{16
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

" ContainsOrEqual(area1, area2) "{{{16
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

" PostProcessTextObject(dict, to, visual, inner) "{{{16
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

" PostProcessAll(dict, to, visual) "{{{16
"
function! PostProcessAll(dict, to, visual)
  let a:to.final.start = copy(a:to.start.first)
  let a:to.final.end = copy(a:to.end.last)
endfunction "PostProcessAll

" PostProcessInner(dict, to, visual) "{{{16
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

" CancelAction(visual) "{{{16
" Return a string that will cancel the action.
function! CancelAction(visual)
  call winrestview(s:saved_view)
  redir END
  return a:visual ? '' : "\<Esc>"
endfunction "CancelAction

" ExpandTextObject(pattern, to, visual, inner) "{{{16
" Find a container text object, if any.
function! ExpandTextObject(pattern, to, visual, inner)
  echom '* ETO.a:to: '
  echom string(a:to)
  let to = NewTextObject(a:to)
  echom '* ETO2'
  if a:to.kind == 'top' || a:to.kind == 'middle'
    let to.start = a:to.start
    let to.end = PushBoundary(a:pattern, a:to.end, 1, a:visual, a:inner)
  elseif a:to.kind == 'bottom'
    let to.start = PushBoundary(a:pattern, a:to.start, 0, a:visual, a:inner)
    let to.end = a:to.end
  elseif a:to.kind == 'whole'
    let to.start = PushBoundary(a:pattern, a:to.start, 0, a:visual, a:inner)
    let to.end = PushBoundary(a:pattern, a:to.end, 1, a:visual, a:inner)
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

" PushBoundary(pattern, boundary, forward, visual, inner) "{{{16
" Expand boundary of the given text object.
function! PushBoundary(pattern, boundary, forward, visual, inner)
  let boundary = NewBoundary(a:boundary)
  let boundary.first = FindFrom(a:pattern, a:boundary.first, a:forward, a:inner, 0)
  if boundary.first[0] == 0
    return a:boundary
  else
    let boundary_temp = GetBoundary(a:pattern, boundary.first)
    let boundary.last = boundary_temp.last
    let boundary.kind = boundary_temp.kind
    return boundary
  endif
endfunction "PushBoundary

" NewBoundary(...) "{{{16
" Returns a new boundary, if a boundary is given it will be merged.
function! NewBoundary(...)
  let boundary = {
        \ 'first': [0,0],
        \ 'last': [0,0],
        \ 'kind': ''}
  return a:0 ? extend(copy(a:1), boundary, 'force') : boundary
endfunction "NewBoundary

" TextObjectKind(to) "{{{16
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

" NewTextObjectDict(...) "{{{16
" Returns a dict with all the stuff needed to handle a set of text objects.
function! NewTextObjectDict(...)
  let d = {}
  let d.Pos = function('Pos')
  let d.Gpos = function('Gpos')
  let d.BeforeThan = function('BeforeThan')
  let d.BeforeThanOrEqualTo = function('BeforeThanOrEqualTo')
  let d.AfterThan = function('AfterThan')
  let d.AfterThanOrEqualTo = function('AfterThanOrEqualTo')
endfunction "NewTextObjectDict

" Text-object objects framework {{{1
" Define position object {{{2
let p = {}
" p.init(list) dict abort "{{{3
" Ditto
function! p.init(list) dict
  let self.priv = {}
  let self.priv.class = 'position'
  if len(a:list) == 1 && type(a:list[0]) == type([]) && len(a:list[0]) == 2
    let self.priv.position = get(a:list, 0, [0,0])
  elseif len(a:list) == 1 && type(a:list[0]) == type({})
    let self.priv.position = copy(a:list[0].position())
  else
    let self.priv.position = [0,0]
    if len(a:list) > 0
      echoe 'Position init: Wrong number or type of arguments! Args: ' . string(a:list)
    endif
  endif
endfunction "p.init

" p.to_s() dict abort "{{{3
" Ditto
function! p.to_s() dict abort
  return '{Class: Position => ' . string(self.position()) . '}'
endfunction "p.to_s

" p.position(...) dict abort "{{{3
" Get position in [line, column] format, if an argument is given the position will be
" in the form [0, line, column, 0]
function! p.position(...) dict
  if a:0 == 1 && type(a:1) == type([])
    let self.priv.position = self.to_pos(copy(a:1))
  elseif a:0 == 1 && type(a:1) == type({})
    let self.priv.position = copy(a:1.position())
  elseif a:0
    echoe 'Position position: Wrong number or type of arguments! Args: ' . string(a:000)
  endif
  return self.priv.position
endfunction "p.position

" p.line() dict abort "{{{3
" Get line number.
function! p.line() dict
  return self.position()[0]
endfunction "p.line

" p.column() dict abort "{{{3
" Get column number.
function! p.column() dict
  return self.position()[1]
endfunction "p.column

" p.valid() dict abort "{{{3
" 
function! p.valid() dict
  return self.line() > 0 && self.column() > 0
endfunction "p.valid

" p.to_pos(...) dict abort "{{{3
" Returns a list in the format [line, col]
" - pos: List.
function! p.to_pos(...) dict
  if !a:0
    return self.position()
  endif
  let len = len(a:1)
  if len == 2
    return a:1
  elseif len == 3
    return a:1[0:1]
  elseif len == 4
    return a:1[1:2]
  else
    return[0,0]
  endif
endfunction "p.to_pos

" p.to_gpos(...) dict abort "{{{3
" Returns a list in the format used by setpos().
" - pos: List.
function! p.to_gpos(...) dict
  if !a:0
    return [0] + self.position() + [0]
  endif
  let len = len(a:1)
  if len == 2
    return [0] + a:1 + [0]
  elseif len == 3
    return [0] + a:1
  elseif len == 4
    return a:1
  else
    return[0,0,0,0]
  endif
endfunction "p.to_gpos

" p.setpos(...) dict abort "{{{3
" Ditto
function! p.setpos(...) dict
  return setpos(a:0 ? '.' : a:1, self.to_gpos()) + 1
endfunction "p.setpos

" p.equal(position) dict abort "{{{3
" Returns 1 if the given positions is the same.
function! p.equal(position) dict
  return self.position() == a:position.position()
endfunction "p.equal

" p.before(position) "{{{3
" Ditto
function! p.before(position)
  return self.line() < a:position.line() ||
        \ (self.line() == a:position.line() && self.column() < a:position.column())
endfunction "p.before

" p.before_or_equal(position) "{{{3
" Ditto
function! p.before_or_equal(position)
  return self.line() < a:position.line() ||
        \ self.line() == a:position.line() && self.column() < a:position.column() ||
        \ self.equal(a:position)
endfunction "p.before_or_equal

" p.after(position) dict abort "{{{3
" 
function! p.after(position) dict
  return a:position.before(self)
endfunction "p.after

" p.after_or_equal(position) dict abort "{{{3
" 
function! p.after_or_equal(position) dict
  return a:position.before_or_equal(self)
endfunction "p.after_or_equal

" Define area object {{{2
let a = {}
" a.init(list) dict abort "{{{3
" Ditto
function! a.init(list) dict
  let self.priv = {}
  let self.priv.class = 'area'
  if len(a:list) == 2 &&
        \ self.root.is_object(a:list[0]) &&
        \ a:list[0].class('position') &&
        \ self.root.is_object(a:list[1]) &&
        \ a:list[1].class('position')
    call self.start(self.root.new('position', a:list[0]))
    call self.end(self.root.new('position', a:list[1]))
  else
    call self.start(self.root.new('position'))
    call self.end(self.root.new('position'))
    if len(a:list) > 0
      echoe 'Area init: Wrong number or type of arguments! Args: ' . string(a:list)
    endif
  endif
endfunction "a.init

" a.to_s() dict abort "{{{3
" Ditto
function! a.to_s() dict abort
  return '{Class: Area => Start: ' . self.start().to_s() . ', End: ' . self.end().to_s() . '}'
endfunction "a.to_s

" a.valid() dict abort "{{{3
" Ditto
function! a.valid() dict abort
  return self.start().valid() && self.end().valid()
endfunction "a.valid

" a.start(...) dict abort "{{{3
" Accessor
function! a.start(...) dict
  if a:0 == 1 && self.root.is_object(a:1) && a:1.class('position')
    let self.priv.start = a:1
  elseif a:0
    echoe 'Area start: Wrong number or type of arguments! Args: ' . string(a:000)
  endif
  return self.priv.start
endfunction "a.start

" a.end(...) dict abort "{{{3
" Accessor
function! a.end(...) dict
  if a:0 == 1 && self.root.is_object(a:1) && a:1.class('position')
    let self.priv.end = a:1
  elseif a:0
    echoe 'Area end: Wrong number or type of arguments! Args: ' . string(a:000)
  endif
  return self.priv.end
endfunction "a.end

" a.equal(area) dict abort "{{{3
" Ditto
function! a.equal(area) dict
  return self.start().equal(a:area.start()) &&
        \ self.end().equal(a:area.end())
endfunction "a.equal

" a.contains(area) dict abort "{{{3
" Ditto
function! a.contains(area) dict
  return self.start().before_or_equal(a:area.start()) &&
        \ self.end().after_or_equal(a:area.end())
endfunction "a.contains

" Define boundary object {{{2
let b = {}
" b.init(list) dict abort "{{{3
" Ditto
function! b.init(list) dict
  let self.priv = {}
  let self.priv.class = 'boundary'
  if len(a:list) == 2 &&
        \ self.root.is_object(a:list[0]) &&
        \ a:list[0].class('position') &&
        \ self.root.is_object(a:list[1]) &&
        \ a:list[1].class('position')
    call self.first(a:list[0])
    call self.last(a:list[1])
  else
    call self.first(self.root.new('position'))
    call self.last(self.root.new('position'))
    if len(a:list) > 0
      echoe 'Boundary init: Wrong number or type of arguments! Args: ' . string(a:list)
    endif
  endif
endfunction "b.init

" b.to_s() dict abort "{{{3
" Ditto
function! b.to_s() dict abort
  return '{Class: Boundary => First: ' . self.first().to_s() . ', Last: ' . self.last().to_s() . '}'
endfunction "b.to_s

" b.valid() dict abort "{{{3
" Ditto
function! b.valid() dict
  return self.first().valid() && self.last().valid()
endfunction "b.valid

" b.first(...) dict abort "{{{3
" accessor
function! b.first(...) dict
  if a:0 == 1 && self.root.is_object(a:1) && a:1.class('position')
    let self.priv.first = a:1
  elseif a:0
    echoe 'Boundary first: Wrong number or type of arguments! Args: ' . string(a:000)
  endif
  return self.priv.first
endfunction "b.first

" b.last(...) dict abort "{{{3
" accessor
function! b.last(...) dict
  if a:0 == 1 && self.root.is_object(a:1) && a:1.class('position')
    let self.priv.last = a:1
  elseif a:0
    echoe 'Boundary last: Wrong number or type of arguments! Args: ' . string(a:000)
  endif
  return self.priv.last
endfunction "b.last

" b.equal(boundary) dcit abort "{{{3
" Ditto
function! b.equal(boundary) dict abort
  return self.first().equal(a:boundary.first()) && self.last().equal(a:boundary.last())
endfunction "b.equal
" b.starts_before(boundary) dict abort "{{{3
" Ditto
function! b.starts_before(boundary) dict
  return self.first().before(a:boundary.first())
endfunction "b.starts_before

" b.ends_after(boundary) dict abort "{{{3
" Ditto
function! b.ends_after(boundary) dict
  return self.last().after(a:boundary.last())
endfunction "b.ends_after

" b.contains(boundary) dict abort "{{{3
" Ditto
function! b.contains(boundary) dict
  return self.starts_before(a:boundary) &&
        \ self.ends_after(a:boundary)
endfunction "b.contains

" Define text-object object {{{2
let t = {}
" t.init(list) dict abort "{{{3
" Ditto
function! t.init(list) dict
  let self.priv = {}
  let self.priv.class = 'text-object'
  if len(a:list) == 2 &&
        \ self.root.is_object(a:list[0]) &&
        \ a:list[0].class('boundary') &&
        \ self.root.is_object(a:list[1]) &&
        \ a:list[1].class('boundary')
    call self.start(a:list[0])
    call self.end(a:list[1])
  else
    call self.start(self.root.new('boundary'))
    call self.end(self.root.new('boundary'))
    if len(a:list) > 0
      echoe 'Text-object init: Wrong number or type of arguments! Args: ' . string(a:list)
    endif
  endif
endfunction "t.init

" t.to_s() dict abort "{{{3
" Ditto
function! t.to_s() dict abort
  return '{Class: Text-Object => Start: ' . self.start().to_s() . ', End: ' . self.end().to_s() . '}'
endfunction "t.to_s

" t.valid() dict abort "{{{3
" Ditto
function! t.valid() dict
  return self.start().valid() && self.end().valid()
endfunction "t.valid

" t.start(...) dict abort "{{{3
" accessor
function! t.start(...) dict
  if a:0 == 1 && self.root.is_object(a:1) && a:1.class('boundary')
    let self.priv.start = a:1
  elseif a:0
    echoe 'Text-object start: Wrong number or type of arguments! Args: ' . string(a:000)
  endif
  return self.priv.start
endfunction "t.start

" t.end(...) dict abort "{{{3
" accessor
function! t.end(...) dict
  if a:0 == 1 && self.root.is_object(a:1) && a:1.class('boundary')
    let self.priv.end = a:1
  elseif a:0
    echoe 'Text-object end: Wrong number or type of arguments! Args: ' . string(a:000)
  endif
  return self.priv.end
endfunction "t.end

" t.equal(to) dict abort "{{{3
" Ditto
function! t.equal(to) dict
  return self.start().equal(a:to.start()) && self.end().equal(a:to.end())
endfunction "t.equal
" t.contains(to) dict abort "{{{3
" Ditto
function! t.contains(to) dict
  return (self.start().starts_before(a:to.start()) ||
        \ self.start().equal(a:to.start())) &&
        \ (self.end().ends_after(a:to.end()) ||
        \ self.end().equal(a:to.end()))
endfunction "t.contains

" Object's templates repository {{{2
"TODO: IMplement IDs & to_s()
let r = {}
let r.templates = {}
let r.templates.position    = p
let r.templates.area        = a
let r.templates.boundary    = b
let r.templates.text_object = t
" r.new(object) dict abort "{{{3
" Returns a new object.
function! r.new(object, ...) dict
  let obj = copy(get(self.templates, a:object, {}))
  if empty(obj)
    echoe 'There is no template for "'.a:object.'"!'
    return
  endif
  let obj.root = self
  call obj.init(a:000)
  let obj.class = self.class
  let obj.id = self.obj_id
  lockvar 2 obj
  return obj
endfunction "r.new

" r.class() dict abort "{{{3
" Get class or see if it's the same as the given one.
function! r.class(...) dict
  if a:0
    return self.priv.class == a:1
  endif
  return self.priv.class
endfunction "r.class

" r.obj_id(...) dict abort "{{{3
" Dito
function! r.obj_id(...) dict abort
  if a:0 == 1 && type(a:1) == type(0)
    let self.priv.id = a:1
  elseif a:0
    echoe 'ID: Wrong number or type of arguments! Args: ' . string(a:000)
  endif
  return self.priv.id
endfunction "r.obj_id

" r.is_object(obj) dict abort "{{{3
" Return 1 if the argument is an object.
function! r.is_object(obj) dict
  return type(a:obj) == 4 &&
        \has_key(a:obj, 'class') &&
        \type(a:obj.class) == 2 &&
        \type(a:obj.class()) == 1 &&
        \index(keys(self.templates), substitute(a:obj.class(), '\W', '_', 'g')) > -1
endfunction "r.is_object

" Regular Expression text-objects {{{1
" Define criteria dict abort {{{2
let c = {}
let c.kind = 'Regular Expression'
let c.objects = r
" c.get_positions(options) dict abort "{{{3
" Ditto
function! c.get_positions(options) dict
  call self.reset(a:options)
  let to = self.get_text_object(a:options)
  let area = self.post_process_text_object(to, a:options)
  echom 'c.gp: area => ' . area.to_s()
  return [area.start().to_gpos(), area.end().to_gpos()]
endfunction "c.get_positions

" c.reset(options) dict abort "{{{3
" Ditto
function! c.reset(options) dict
  let self.skip = a:options.skip
  let self.patterns = a:options.patterns
endfunction "c.reset

" c.get_text_object(options) dict abort "{{{3
" Ditto
function! c.get_text_object(options) dict
  let pos1 = self.objects.new('position')
  if a:options.visual
    let pos2 = self.objects.new('position')
    call pos1.position(getpos("'<"))
    call pos2.position(getpos("'>"))
    let to = self.get_text_object_from_area(pos1, pos2, a:options)
  else
    call pos1.position(getpos('.'))
    let to = self.find_text_object(pos1, a:options)
  endif
  echom 'gto: to => ' . to.to_s()
  if !to.valid()
    return to
  endif
  let original = self.objects.new('area')
  call original.start(pos1)
  call original.end(a:options.visual ? pos2 : pos1)
  if a:options.visual
    let final = self.post_process_text_object(to, a:options)
    if !final.valid()
      return self.objects.new('text_object')
    endif
    if original.contains(final)
      let to = self.expand_text_object(to, a:options)
      if !to.valid()
        return to
      endif
    endif
  endif
  echo 'gto: count => ' . a:options.count
  for i in range(a:options.count - 1)
    let to_temp = self.expand_text_object(to, a:options)
    echo 'gto: to_temp => ' . to_temp.to_s()
    if !to_temp.valid()
      break
    endif
    let to = to_temp
  endfor
  echom 'gto: to => ' . to.to_s()
  return to
endfunction "c.get_text_object

" c.get_text_object_from_area(pos1, pos2, options) dict abort "{{{3
" Ditto
function! c.get_text_object_from_area(pos1, pos2, options) dict
  if a:pos1.equal(a:pos2)
    return self.find_text_object(a:pos1, a:options)
  endif
  let to1 = self.find_text_object(a:pos1, a:options)
  echom 'c.gtofa: to1 => ' . to1.to_s()
  let to2 = self.find_text_object(a:pos2, a:options)
  echom 'c.gtofa: to2 => ' . to2.to_s()
  let to = self.choose_text_object(to1, to2)
  if !to.valid() && to1.valid() && to2.valid() &&
        \ self.boundary_kind(to1.end) == 'middle' &&
        \ self.boundary_kind(to2.start) == 'middle'
    let to_all = self.find_text_object(a:pos1, {'inner': 0})
    if to_all.contains(to1) && to_all.contains(to2)
      let to = to1
      call to.end(to2.end)
    else
      return self.objects.new('text-object')
    endif
  endif
  if !to.valid()
    return self.objects.new('text-object')
  endif
  return to
endfunction "c.get_text_object_from_area

" c.find_text_object(pos, options) dict abort "{{{3
" Ditto
function! c.find_text_object(pos, options) dict
  let to = self.objects.new('text_object')
  let boundary = self.get_boundary(a:pos)
  let pos = self.objects.new('position')
  if self.boundary_kind(boundary) == 'start'
    echom 'c.fto: '.1
    call to.start(boundary)
    call pos.position(self.find_from(a:pos, 1, a:options.inner))
    call to.end(self.get_boundary(pos))
  elseif self.boundary_kind(boundary) == 'middle' && a:options.inner
    echom 'c.fto: '.2
    call to.start(boundary)
    call pos.position(self.find_from(a:pos, 1, a:options.inner))
    call to.end(self.get_boundary(pos))
  elseif self.boundary_kind(boundary) == 'end'
    echom 'c.fto: '.3
    call to.end(boundary)
    call pos.position(self.find_from(a:pos, 0, a:options.inner))
    call to.start(self.get_boundary(pos))
  else
    echom 'c.fto: '.4
    call pos.position(self.find_from(a:pos, 0, a:options.inner))
    call to.start(self.get_boundary(pos))
    call pos.position(self.find_from(a:pos, 1, a:options.inner))
    call to.end(self.get_boundary(pos))
  endif
  return to
endfunction "c.find_text_object

" c.expand_text_object(to, options) dict abort "{{{3
" Ditto
function! c.expand_text_object(to, options) dict
  echo 'c.eto: a:to => '.a:to.to_s()
  let to = self.objects.new('text_object')
  let kind = self.text_object_kind(a:to)
  if kind == 'top' || kind == 'middle'
    echo 1
    call to.start(a:to.start())
    call to.end(self.push_boundary(a:to.end(), 1, a:options.inner))
  elseif kind == 'bottom'
    echo 2
    call to.start(self.push_boundary(a:to.start(), 0, a:options.inner))
    call to.end(a:to.end())
  elseif kind == 'whole'
    echo 3
    call to.start(self.push_boundary(a:to.start(), 0, a:options.inner))
    call to.end(self.push_boundary(a:to.end(), 1, a:options.inner))
  else
    echo 4
    return self.objects.new('text_object')
  endif
  if to.equal(a:to)
    return self.objects.new('text_object')
  endif
  return to
endfunction "c.expand_text_object

" c.find_at(position) dict abort "{{{3
" Determine which pattern is found at the given position, if any.
function! c.find_at(position) dict
  " Position cursor
  call cursor(a:position.position())
  let result = ['', -1]
  " Should the current position be skipped?
  if eval(self.skip)
    return result
  endif
  "TODO: Why 'end' is not detected?
  for kind in keys(filter(copy(self.patterns), 'v:val != ""'))
    if searchpos(self.patterns[kind], "cn", line(".")) == a:position.position()
      let result = [kind, 1]
      echom 'c.fa: result => ' . string(result)
      break
    endif
    if searchpos(self.patterns[kind], "cne", line(".")) == a:position.position()
      let result = [kind, 0]
      echom 'c.fa: result => ' . string(result)
      break
    endif
  endfor
  echom 'c.fa: result => ' . string(result)
  return result
endfunction "c.find_at

" c.find_from(pos, forward, middle, ...) dict abort "{{{3
" Looks for a pair and returns its position.
function! c.find_from(pos, forward, inner, ...) dict
  call cursor(a:pos)
  let pos = self.objects.new('position')
  let f_b = a:forward ? '' : 'b'
  let [matchHere, start] = self.find_at(a:pos)
  echom 'c.ff: matchHere => ' . matchHere . ', forward => '. a:forward . ', inner => '. a:inner
  if matchHere == 'start' && a:forward
    echom 'c.ff: 1'
    let f_c = ''
  elseif matchHere == 'middle'
    echom 'c.ff: 2'
    let f_c = ''
  elseif matchHere == 'end' && !a:forward
    echom 'c.ff: 3'
    if !start
      " searchpair() doesn't detect the 'end' word under the cursor unles it's on
      " thecursor is at the beggining of it.
      call search(self.patterns.end, "cb", line("."))
    endif
    let f_c = ''
  else
    echom 'c.ff: 4'
    let f_c = a:0 && a:1 ? 'c' : ''
  endif
  let flags = 'Wn'.f_b.f_c
  echom 'c.ff: flags => ' . flags
  let middle = (a:inner || get(self, 'always_middle', 0) ? self.patterns.middle : '')
  call pos.position(searchpairpos(self.patterns.start, middle, self.patterns.end, flags, self.skip))
  return pos
endfunction "c.find_from

" c.get_boundary(pos) dict abort "{{{3
" Ditto
function! c.get_boundary(pos) dict
  let boundary = self.objects.new('boundary')
  let in = 0
  if !a:pos.valid()
    return boundary
  endif
  " Position cursor
  call cursor(a:pos.position())
  let pos1 = self.objects.new('position')
  let pos2 = self.objects.new('position')
  for kind in keys(filter(copy(self.patterns), 'v:val != ""'))
    call pos1.position(searchpos(self.patterns[kind], 'Wcb', 0, 100))
    if !pos1.valid() || eval(self.skip)
      call cursor(a:pos.position())
      continue
    endif
    call pos2.position(searchpos(self.patterns[kind], 'Wcne', 0, 100))
    if pos2.before(a:pos)
      call cursor(a:pos.position())
      continue
    endif
    let in = 1
    break
  endfor
  if !in
    return boundary
  endif
  call boundary.first(pos1)
  call boundary.last(pos2)
  return boundary
endfunction "c.get_boundary

" c.boundary_kind(boundary) dict abort "{{{3
" Ditto
function! c.boundary_kind(boundary) dict
  call cursor(a:boundary.first())
  let pos = self.objects.new('position')
  for kind in keys(filter(copy(self.patterns), 'v:val != ""'))
    call pos.position(searchpos(self.patterns[kind], 'Wcn', 0, 100))
    if pos.valid() && pos.equal(a:boundary.first())
      return kind
    endif
  endfor
  return ''
endfunction "c.boundary_kind

" c.text_object_kind(to) dict abort "{{{3
" Ditto
function! c.text_object_kind(to) dict
  if self.boundary_kind(a:to.start()) == 'start' && self.boundary_kind(a:to.end()) == 'middle'
    return 'top'
  elseif self.boundary_kind(a:to.start()) == 'middle' && self.boundary_kind(a:to.end()) == 'end'
    return 'bottom'
  elseif self.boundary_kind(a:to.start()) == 'middle' && self.boundary_kind(a:to.end()) == 'middle'
    return 'middle'
  elseif self.boundary_kind(a:to.start()) == 'start' && self.boundary_kind(a:to.end()) == 'end'
    return 'whole'
  else
    return ''
  endif
endfunction "c.text_object_kind

" c.choose_text_object(to1, to2) dict abort "{{{3
" Ditto
function! c.choose_text_object(to1, to2) dict
  if empty(a:to1) || empty(a:to2)
    return {}
  endif
  if a:to1.equal(a:to2)
    return a:to1
  endif
  if a:to1.contains(a:to2)
    return a:to1
  elseif a:to2.contains(a:to1)
    return a:to2
  else
    return {}
  endif
endfunction "c.choose_text_object

" c.push_boundary(boundary, forward, inner) dict abort "{{{3
" Ditto
function! c.push_boundary(boundary, forward, inner) dict
  let pos = self.find_from(a:boundary.first(), a:forward, a:inner)
  return self.get_boundary(pos)
endfunction "c.push_boundary

" c.post_process_text_object(to, options) dict abort "{{{3
" Ditto
function! c.post_process_text_object(to, options) dict abort
  if a:options.inner
    return self.post_process_inner(a:to, a:options)
  endif
  return self.post_process_all(a:to, a:options)
  3230
endfunction "c.post_process_text_object

" c.post_process_all(to, options) dict abort "{{{3
" Ditto
function! c.post_process_all(to, options) dict abort
  return self.objects.new('area', a:to.start().first(), a:to.end().last())
endfunction "c.post_process_all

" c.post_process_inner(to, options) dict abort "{{{3
" Ditto
function! c.post_process_inner(to, options) dict abort
  if len(getline(a:to.start().last().line())) > a:to.start().last().column()
    let pos1 = self.objects.new('position', a:to.start().last().line(), a:to.start().column() + 1)
  else
    let pos1 = self.objects.new('position', a:to.start().last().line() + 1, 1)
  endif
  if a:to.end.first[1] > 1
    let pos2 = self.objects.new('position', a:to.end().first().line(), a:to.end().first().column() - 1)
  else
    let pos2 = self.objects.new('position', a:to.end().first().line() - 1, len(getline(a:to.end().first()line() - 1)))
  endif
  return self.objects.new('area', [pos1, pos2])
endfunction "c.post_process_inner

" Text-object framework {{{1
let f = {}
let f.name = 'textobj#reggie#'
let c.root = f
let f.criteria = c
" Main functions {{{2
" f.valid_position(pos) dict abort "{{{3
" Ditto
function! f.valid_position(pos) dict
  return a:pos[0] > 0 && a:pos[1] > 0
endfunction "f.valid_position

" f.handle_mapping(options) dict abort "{{{3
" Ditto
function! f.handle_mapping(id, visual, inner, mode) dict
  let s:saved_view = winsaveview()
  let self.current_id = a:id
  let options = self.systems[a:id]
  let options.visual = a:visual
  let options.inner = a:inner
  let options.mode = a:mode
  let options.count = self.get_count(options)
  let [pos1, pos2] = self.criteria.get_positions(options)
  echo pos1
  echo pos2
  if !self.valid_position(pos1[1:2]) || !self.valid_position(pos2[1:2])
    return self.cancel(options)
  endif
  call self.set_marks(pos1, pos2)
  call winrestview(s:saved_view)
  return self.selection_command(options)
endfunction "f.handle_mapping

" f.setup(settings, ...) dict abort "{{{3
" Ditto
function! f.setup(settings, ...) dict abort
  let options = a:settings
  " Check for an 'id' key.
  if !has_key(a:settings, 'id') || empty(a:settings.id)
    echoe 'Setup: The ''id'' key is either missing or empty!'
  endif
  if !has_key(self.systems, options.id) || a:0
    " Check for patterns.
    if !has_key(a:settings, 'start') || empty(a:settings.start) ||
          \ !has_key(a:settings, 'end') || empty(a:settings.end)
      echoe 'Setup: The ''start'' and/or ''end'' keys are either missing or empty!'
    endif
    " Check for key to map.
    if !has_key(a:settings, 'map_sufix') || empty(a:settings.map_sufix)
      echoe 'Setup: The ''map_sufix'' key is either missing or empty!'
    endif
    call extend(options, self.defaults, 'keep')
    let options.patterns = {}
    let options.patterns.start = options.start
    let options.patterns.middle = options.middle
    let options.patterns.end = options.end
    let self.systems[options.id] = options
    call self.create_plug_mappings(options.id)
  endif
  call self.create_user_mappings(options.id)
endfunction "f.setup

" f.create_plug_mappings(id) dict abort "{{{3
"  Ditto
function! f.create_plug_mappings(id) dict
  "TODO: Put this on the settings as strings to be used after setup.
  for [sufix, inner] in [['a', 0], ['i', 1]]
    execute 'onoremap <expr><Plug>' . self.name . '-' . a:id . '-o' . sufix . ' ' .
          \ self.name . 'handle_mapping(' . string(a:id) . ', 0, ' . inner . ', ' . self.systems[a:id].default_mode . ')'
    execute 'vnoremap <Plug>' . self.name . '-' . a:id . '-v' . sufix .
          \ ' <Esc>:exec ' . self.name . 'handle_mapping(' .
          \ string(a:id) . ', 1, ' . inner . ', visualmode())<CR><Esc>gv'
  endfor
endfunction "f.create_plug_mappings

" f.create_user_mappings(id) dict abort "{{{3
" Ditto
function! f.create_user_mappings(id) dict
  let mappings = []
  for mode in ['o',self.systems[a:id].map_visual_mode]
    for prefix in ['a', 'i']
      if self.get_options(a:id).overwrite_mappings ||
            \ empty(maparg(prefix . self.systems[a:id].map_sufix, mode))
        let mapping = mode . 'map ' . prefix . self.systems[a:id].map_sufix .
              \ ' <Plug>' . self.name . '-' . a:id . '-' . mode . prefix
        call add(mappings, mapping)
      else
        echoe 'Create user mappings: A mapping to ''' . prefix . self.systems[a:id].map_sufix . ''' in ' . (mode == 'o' ? 'opreator pending' : 'visual') . ' mode already exists! Aborting.'
        return
      endif
    endfor
  endfor
  for mapping in mappings
    execute mapping
  endfor
endfunction "f.create_user_mappings

" Selection tools {{{2
" f.get_count(options) dict abort "{{{3
" Ditto
function! f.get_count(options) dict
  if a:options.visual
    return v:prevcount == 0 ? 1 : v:prevcount
  else
    return v:count1
  endif
endfunction "f.get_count

" f.cancel(options) dict abort "{{{3
" Ditto
function! f.cancel(options) dict
  call winrestview(s:saved_view)
  return a:options.visual ? '' : "\<Esc>"
endfunction "f.cancel

" f.set_marks(pos1, pos2) dict abort "{{{3
" Ditto
function! f.set_marks(pos1, pos2) dict abort
  return (setpos("'[", a:pos1) + 1) &&
        \ (setpos("']", a:pos2) + 1)
endfunction "f.set_marks

" f.selection_command(options) dict abort "{{{3
" Ditto
function! f.selection_command(options) dict
  if a:options.visual
    return "normal! `[".a:options.mode."`]"
  else
    return ":\<C-U>".'exec "normal! `['.a:options.mode.'`]"' . "\<CR>"
  endif
endfunction "f.selection_command

" Systems {{{2
" TODO: Implement text-objects for any char with getchar() (:h <expr>).
let f.systems                     = {}
let f.defaults                    = {}
let f.defaults.always_middle      = 0
let f.defaults.map_local          = 1
let f.defaults.map_sufix          = ''
let f.defaults.middle             = ''
let f.defaults.skip               = ''
let f.defaults.default_mode       = 'v'
let f.defaults.map_visual_mode    = 'v'
let f.defaults.overwrite_mappings = 0
" f.get_options(id) dict abort "{{{3
" Ditto
function! f.get_options(...) dict
  return self.systems[a:0 ? a:1 : self.current_id]
endfunction "f.get_options

" Library functions. {{{1
" textobj#reggie#setup(options) "{{{2
" Ditto
function! textobj#reggie#setup(...)
  return call(g:f.setup, a:000, g:f)
endfunction "textobj#reggie#setup

" textobj#reggie#handle_mapping(...) "{{{2
" Ditto
function! textobj#reggie#handle_mapping(...)
  redir => g:log
  let result = call(g:f.handle_mapping, a:000, g:f)
  echo ' '
  echom result
  echo ' '
  echo g:f
  redir END
  return result
endfunction "textobj#reggie#handle_mapping

" textobj#reggie#get_dictionary() "{{{2
" Ditto
function! textobj#reggie#get_dictionary()
  return deepcopy(f)
endfunction "textobj#reggie#get_dictionary
" VimL text-objects {{{1
" Patterns' dict {{{2

let v = {}
let v.id = 'viml'
let v.map_sufix = 'z'
let v.map_local = 1
let v.overwrite_mappings = 1
let v.skip =
      \ 'getline(".") =~ "^\\s*sy\\%[ntax]\\s\\+region" ||' .
      \ 'synIDattr(synID(line("."),col("."),1),"name") =~? ' .
      \ '"\\mcomment\\|string\\|vim\k\{-}var"'
let v.start =
      \ '\C\m\%(^\||\)\s*\zs\%(' .
      \ '\<fu\%[nction]\>\|\<\%(wh\%[ile]\|for\)\>\|\<if\>\|\<try\>\|' .
      \ '\<aug\%[roup]\s\+\%(END\>\)\@!\S' .
      \ '\)'
let v.middle =
      \ '\C\m\%(^\||\)\s*\zs\%(\<el\%[seif]\>\|\<cat\%[ch]\>\|\<fina\%[lly]\>\)'
let v.end =
      \ '\C\m\%(^\||\)\s*\zs\%(\<endf\%[unction]\>\|\<end\%(w\%[hile]\|fo\%[r]\)\>\|'.
      \ '\<en\%[dif]\>\|\<endt\%[ry]\>\|\<aug\%[roup]\s\+END\>\)'

call textobj#reggie#setup(v, 1)

"finish "{{{1
let pattern = {}
" VimL settings:
let pattern.skip =
      \ 'getline(".") =~ "^\\s*sy\\%[ntax]\\s\\+region" ||' .
      \ 'synIDattr(synID(line("."),col("."),1),"name") =~? '.
      \ '"\\mcomment\\|string\\|vim\k\{-}var"'
" Start of the block matches this
let pattern.start = '\C\m\%(^\||\)\s*\zs\%('.
      \ '\<fu\%[nction]\>\|\<\%(wh\%[ile]\|for\)\>\|\<if\>\|\<try\>\|'.
      \ '\<aug\%[roup]\s\+\%(END\>\)\@!\S'.
      \ '\)'
" Middle of the block matches this
let pattern.middle = '\C\m\%(^\||\)\s*\zs\%(\<el\%[seif]\>\|\<cat\%[ch]\>\|\<fina\%[lly]\>\)'
" End of the block matches this
let pattern.end =
      \ '\C\m\%(^\||\)\s*\zs\%(\<endf\%[unction]\>\|\<end\%(w\%[hile]\|fo\%[r]\)\>\|'.
      \ '\<en\%[dif]\>\|\<endt\%[ry]\>\|\<aug\%[roup]\s\+END\>\)'
let dict = {}
let dict.pattern = pattern
let dict.intersect_txtobjs = 0
onoremap <expr> ax ReggieTextObj(dict, 0, 0)
onoremap <expr> ix ReggieTextObj(dict, 0, 1)
vnoremap  ax <Esc>:exec ReggieTextObj(dict, 1, 0, visualmode())<CR><Esc>gv
vnoremap  ix <Esc>:exec ReggieTextObj(dict, 1, 1, visualmode())<CR><Esc>gv
finish
{{{1
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
  for a in []
    echo a
  endfor
endif
if {
  if {
    zldkfh
    abcABC
    aljdñh
     }
    }
