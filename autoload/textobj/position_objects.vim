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

" textobj#position_objects#new() abort "{{{2
" Ditto
function! textobj#position_objects#new() abort
  return deepcopy(g:r)
endfunction "textobj#position_objects#new

