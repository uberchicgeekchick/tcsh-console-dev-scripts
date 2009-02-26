#!/bin/tcsh -f

#C compiler flags
setenv	LDFLAGS		"-L/lib64 -L/usr/lib64 -L/usr/lib -L/lib"
#libraries to pass to the linker, e.g. -l<library>
setenv	LIBS			"-L/lib64 -L/usr/lib64 -L/usr/lib -L/lib"

setenv	LD_LIBRARY_PATH	"/usr/include"
setenv	LD_RUN_PATH		"/usr/include"


#C compiler command
setenv	CC		"/usr/bin/gcc"

#C preprocessor
setenv	CPP		"/usr/bin/cpp"

#C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#you have headers in a nonstandard directory <include dir>
setenv	CPPFLAGS	"-I${LD_LIBRARY_PATH}"

setenv	CFLAGS	"-Wall -Wextra -Wformat=2 -Wswitch-default -Wswitch-enum -O3 ${LDFLAGS} ${CPPFLAGS}"


#Path to xmkmf, Makefile generator for X Window System
setenv	XMKMF		"/usr/bin/xmkmf"

