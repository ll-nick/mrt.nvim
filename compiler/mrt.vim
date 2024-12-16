if exists("current_compiler")
    finish
endif
" Most of the erroformat can simply be taken from the gcc.vim file
runtime compiler/gcc.vim
let current_compiler = "mrt"

let s:save_cpo = &cpo
set cpo&vim

CompilerSet makeprg=TERM=dumb\ mrt\ build\ --no-color
CompilerSet errorformat^=
		\%DErrors%\\s%\\+<<\ %\\w%\\+:%\\w%\\+\ %f/build%.%#.log,
		\%E%f:%l:%c:\ %t%*[^:]:\ %m,
		\%C%.%#|%.%#

" Set errorformat for MRT build
"CompilerSet errorformat=
"            \%DErrors%\\s%\\+<<\ %\\w%\\+:%\\w%\\+\ %f/build%.%#.log,
"            \%E%f:%l:%c:\ %t%*[^:]:\ %m,
"            \%C%.%#|%.%#,
"            \%*[^"]"%f"%*\\D%l:\ %m,
"            \"%f"%*\\D%l:\ %m,
"            \%-Gg%\\?make[%*\\d]:\ ***\ [%f:%l:%m,
"            \%-Gg%\\?make:\ ***\ [%f:%l:%m,
"            \%-G%f:%l:\ (Each\ undeclared\ identifier\ is\ reported\ only\ once,
"            \%-G%f:%l:\ for\ each\ function\ it\ appears\ in.),
"            \%-GIn\ file\ included\ from\ %f:%l:%c:,
"            \%-GIn\ file\ included\ from\ %f:%l:%c\\,,
"            \%-GIn\ file\ included\ from\ %f:%l:%c,
"            \%-GIn\ file\ included\ from\ %f:%l,
"            \%-G%*[ ]from\ %f:%l:%c,
"            \%-G%*[ ]from\ %f:%l:,
"            \%-G%*[ ]from\ %f:%l\\,,
"            \%-G%*[ ]from\ %f:%l,
"            \%f:%l:%c:%m,
"            \%f(%l):%m,
"            \%f:%l:%m,
"            \"%f"\\,\ line\ %l%*\\D%c%*[^\ ]\ %m,
"            \%D%*\\a[%*\\d]:\ Entering\ directory\ %*[`']%f',
"            \%X%*\\a[%*\\d]:\ Leaving\ directory\ %*[`']%f',
"            \%D%*\\a:\ Entering\ directory\ %*[`']%f',
"            \%X%*\\a:\ Leaving\ directory\ %*[`']%f',
"            \%DMaking\ %*\\a\ in\ %f,
"            \%f|%l|\ %m


let &cpo = s:save_cpo
unlet s:save_cpo

