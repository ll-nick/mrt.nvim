if exists("current_compiler")
    finish
endif
" Most of the erroformat can simply be taken from the gcc.vim file
runtime compiler/gcc.vim
let current_compiler = "mrt"

let s:save_cpo = &cpo
set cpo&vim

CompilerSet makeprg=TERM=dumb\ mrt\ build\ --no-color

" We just need parse additional catkin messages to know which package is
" currently being built
CompilerSet errorformat^=
		\%DErrors%\\s%\\+<<\ %\\w%\\+:%\\w%\\+\ %f/build%.%#.log,
		\%E%f:%l:%c:\ %t%*[^:]:\ %m,
		\%C%.%#|%.%#

let &cpo = s:save_cpo
unlet s:save_cpo

