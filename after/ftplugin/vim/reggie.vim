" VimL text-objects {{{1
" Patterns' dict {{{2

let v = {}
let v.id = 'viml'
let v.map_sufix = 'z'
let v.map_local = 1
let v.filetype = 1
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
let v.objects = textobj#position_objects#new()
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

" {{{2
call textobj#reggie#setup(v, 1)
