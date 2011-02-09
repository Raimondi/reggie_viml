" These paths work only if the tests scripts's repos are in the same folder as
" this repo.
let &runtimepath = expand('<sfile>:p:h:h:h').'/runVimTests,'.&rtp
let &runtimepath = expand('<sfile>:p:h:h:h').'/vimtap,'.&rtp
let &runtimepath = expand('<sfile>:p:h:h').','.&rtp
filetype on
let maps =
      \ {'va': 'ak',
      \  'vi': 'ik',
      \  'oa': 'ak',
      \  'oi': 'ik',
      \  'pva': '<Plug>KeywordTextObjectsAll',
      \  'pvi': '<Plug>KeywordTextObjectsInner',
      \  'poa': '<Plug>KeywordTextObjectsAll',
      \  'poi': '<Plug>KeywordTextObjectsInner'}
let fname = 'ktextobjects'
