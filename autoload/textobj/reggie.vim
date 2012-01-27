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

" p.to_l() dict abort "{{{3
" Return a list representation.
function! p.to_l() dict abort
  return self.position()
endfunction "p.to_l

" p.to_d() dict abort "{{{3
" Returns dictionary representation.
function! p.to_d() dict abort
  return {'line': self.line(), 'column': self.column()}
endfunction "p.to_d

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

" a.to_l() dict abort "{{{3
" Returns list representation.
function! a.to_l() dict abort
  return [self.start().to_l(), self.end().to_l()]
endfunction "a.to_l

" a.to_d() dict abort "{{{3
" Returns dictionary representation.
function! a.to_d() dict abort
  return {'start': self.start().to_d(), 'end': self.end().to_d()}
endfunction "a.to_d

" a.to_dl() dict abort "{{{3
" Returns dictionary representation.
function! a.to_dl() dict abort
  return {'start': self.start().to_l(), 'end': self.end().to_l()}
endfunction "a.to_dl

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

" b.to_l() dict abort "{{{3
" Returns list representation.
function! b.to_l() dict abort
  return [self.first().to_l(), self.last().to_l()]
endfunction "b.to_l

" b.to_d() dict abort "{{{3
" Returns dictionary representation.
function! b.to_d() dict abort
  return {'first': self.first().to_d(), 'last': self.last().to_d()}
endfunction "b.to_d

" b.to_dl() dict abort "{{{3
" Returns dictionary representation.
function! b.to_dl() dict abort
  return {'first': self.first().to_l(), 'last': self.last().to_l()}
endfunction "b.to_dl

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

" t.to_l() dict abort "{{{3
" Returns list representation.
function! t.to_l() dict abort
  return [self.start().to_l(), self.end().to_l()]
endfunction "t.to_l

" t.to_d() dict abort "{{{3
" Returns dictionary representation.
function! t.to_d() dict abort
  return {'start': self.start().to_d(), 'end': self.end().to_d()}
endfunction "t.to_d

" t.to_dl() dict abort "{{{3
" Returns a dictionary and list representation.
function! t.to_dl() dict abort
  return {'start': self.start().to_dl(), 'end': self.end().to_dl()}
endfunction "t.to_dl

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
  let object = substitute(a:object, '\W', '_', 'g')
  let obj = copy(get(self.templates, object, {}))
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

" c.post_process_text_object(to, options) dict abort "{{{3
" Ditto
function! c.post_process_text_object(to, options) dict abort
  let type = self.root.systems[a:options.id].post_processor_arg_type
   if type == 'o'
     let arg = a:to
   elseif type == 'l'
     let arg = a:to.to_l()
   elseif type == 'd'
     let arg = a:to.to_d()
   elseif type == 'm'
     let arg = a:to.to_dl()
   else
     echoe 'Post-Process Text Object: This should be seen, ever!'
   endif
   let [pos1, pos2] = self.root.systems[a:options.id].post_process(arg, a:options)
   return self.objects.new('area', self.objects.new('position', pos1), self.objects.new('position', pos2))
endfunction "c.post_process_text_object

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
        \ self.boundary_kind(to1.end()) == 'middle' &&
        \ self.boundary_kind(to2.start()) == 'middle'
    let to_all = self.find_text_object(a:pos1, {'inner': 0})
    if to_all.contains(to1) && to_all.contains(to2)
      let to = to1
      call to.end(to2.end())
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
  call cursor(a:boundary.first().to_l())
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
    return self.objects.new('text_object')
  endif
  if a:to1.equal(a:to2)
    return a:to1
  endif
  if a:to1.contains(a:to2)
    return a:to1
  elseif a:to2.contains(a:to1)
    return a:to2
  else
    return self.objects.new('text_object')
  endif
endfunction "c.choose_text_object

" c.push_boundary(boundary, forward, inner) dict abort "{{{3
" Ditto
function! c.push_boundary(boundary, forward, inner) dict
  let pos = self.find_from(a:boundary.first(), a:forward, a:inner)
  return self.get_boundary(pos)
endfunction "c.push_boundary

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
    "TODO: Manage lack of post-processor.
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
    let mapping = 'onoremap <expr><Plug>'
    let mapping .= self.name . '-' . a:id . '-o' . sufix . ' '
    let mapping .= self.name . 'handle_mapping('
    let mapping .= string(a:id)
    let mapping .= ', 0, '
    let mapping .= inner
    let mapping .= ", '" . self.systems[a:id].default_mode
    let mapping .= "')"
    execute mapping
    let mapping = 'vnoremap <Plug>'
    let mapping .= self.name . '-' . a:id . '-v' . sufix . ' '
    let mapping .= '<Esc>:exec ' . self.name . 'handle_mapping('
    let mapping .= string(a:id)
    let mapping .= ', 1'
    let mapping .= ', ' . inner
    let mapping .= ', visualmode()'
    let mapping .= ')<CR><Esc>gv'
    execute mapping
  endfor
endfunction "f.create_plug_mappings

" f.create_user_mappings(id) dict abort "{{{3
" Ditto
function! f.create_user_mappings(id) dict
  let local = self.systems[a:id].map_local ? '<buffer> ' : ''
  let mappings = []
  for mode in ['o',self.systems[a:id].map_visual_mode]
    for prefix in ['a', 'i']
      if self.get_options(a:id).overwrite_mappings ||
            \ empty(maparg(prefix . self.systems[a:id].map_sufix, mode))
        let mapping = mode . 'map '
        let mapping .= local . '<silent>'
        let mapping .= prefix . self.systems[a:id].map_sufix . ' '
        let mapping .= '<Plug>' . self.name . '-' . a:id . '-' . mode . prefix
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
    return "normal! `[" . a:options.mode . "`]"
  else
    return ":\<C-U>" .
          \ 'exec "normal! `[' .
          \ a:options.mode .
          \ '`]"' .
          \ "\<CR>"
  endif
endfunction "f.selection_command

" Systems {{{2
" TODO: Implement text-objects for any char with getchar() (:h <expr>).
let f.systems                          = {}
let f.defaults                         = {}
let f.defaults.always_middle           = 0
let f.defaults.map_local               = 1
let f.defaults.filetype                = 0
let f.defaults.map_sufix               = ''
let f.defaults.middle                  = ''
let f.defaults.skip                    = ''
let f.defaults.default_mode            = 'v'
let f.defaults.map_visual_mode         = 'v'
let f.defaults.overwrite_mappings      = 0
let f.defaults.linewise                = 0
let f.defaults.post_processor_arg_type = 'l' "one of o, d, l or m
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
  return deepcopy(g:f)
endfunction "textobj#reggie#get_dictionary

" textobj#reggie#get_objects() abort "{{{2
" Ditto
function! textobj#reggie#get_objects() abort
  return deepcopy(g:r)
endfunction "textobj#reggie#get_objects

" VimL text-objects {{{1
" Patterns' dict {{{2

let v = {}
let v.id = 'viml'
let v.map_sufix = 'z'
let v.map_local = 1
let v.post_processor_arg_type = 'o'
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
let v.objects = textobj#reggie#get_objects()
" v.post_process(to, options) dict abort "{{{3
" Ditto
function! v.post_process(to, options) dict abort
  if a:options.inner
    return self.post_process_inner(a:to, a:options)
  endif
  return self.post_process_all(a:to, a:options)
endfunction "v.post_process

" v.post_process_all(to, options) dict abort "{{{3
" Ditto
function! v.post_process_all(to, options) dict abort
  " TODO: Respect command separators (|, ;, etc.)
  " TODO: Consider continued lines.
  echom 'v.ppa: to => ' . a:to.to_s()
  if a:options.visual || v:operator != 'c'
    call cursor(a:to.end().last().to_l())
    let result = [[a:to.start().first().line(), 1], [a:to.end().last().line(), col('$')]]
    if !a:options.visual
      let a:options.mode = 'V'
    endif
  else
    call cursor(a:to.end().last().to_l())
    let result = [a:to.start().first(), [a:to.end().last().line(), col('$') - 1]]
  endif
  return result
endfunction "v.post_process_all

" v.post_process_inner(to, options) dict abort "{{{3
" Ditto
function! v.post_process_inner(to, options) dict abort
  if a:to.start().last().line() == a:to.end().first().line() + 1
    return map([0,0], 'self.objects.new("position")')
  endif
  if a:to.start().last().line() == a:to.end().first().line()
    " TODO: How to handle this? We need a way to respect command delimiters
    " in order to have a decent handling of things.
    return map([0,0], 'self.objects.new("position")')
  endif
  if a:options.visual || v:operator != 'c'
    let pos1 = self.objects.new('position',
          \ [a:to.start().last().line() + 1, 1])
    call cursor([a:to.end().last().line() - 1, 1])
    let pos2 = self.objects.new('position',
          \ [a:to.end().first().line() - 1, col('$') - 1])
    if !a:options.visual
      let a:options.mode = 'V'
    endif
  else
    call cursor([a:to.start().last().line() + 1, 1])
    let pos1 = self.objects.new('position',
          \ searchpos('^\s*', 'e'))
    call cursor([a:to.end().first().line() - 1, 1])
    let pos2 = self.objects.new('position',
          \ [a:to.end().first().line() - 1, col('$') - 1])
  endif
  return [pos1, pos2]
endfunction "v.post_process_inner

call textobj#reggie#setup(v, 1)
