#!/bin/tcsh -f

alias	"./configure"	"./configure --libdir=/usr/lib64"
alias	"./autogen.sh"	"./autogen.sh --libdir=/usr/lib64"

#alias make 'if ( ${?GREP_OPTIONS} ) set grep_options="${GREP_OPTIONS}";\
#	if( ${?GREP_OPTIONS} ) unsetenv $GREP_OPTIONS; make'

#C compiler flags
setenv	LDFLAGS		"-L/lib64 -L/usr/lib64 -L/usr/lib -L/lib"
#libraries to pass to the linker, e.g. -l<library>
setenv	LIBS			"-L/lib64 -L/usr/lib64 -L/usr/lib -L/lib"

setenv	LD_LIBRARY_PATH		"/usr/include"
setenv	LD_RUN_PATH		"/usr/include"


#C compiler command
setenv	CC		"/usr/bin/gcc"

#C preprocessor
setenv	CPP		"/usr/bin/cpp"

#C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#you have headers in a nonstandard directory <include dir>
setenv	CPPFLAGS	"-I${LD_LIBRARY_PATH}"

setenv	MAKEFLAGS	"-Wall -Wextra -Wfatal-errors --combine --sysroot=/ -Wformat=2 -Wswitch-default -Wswitch-enum -pthread -O3"
setenv	CFLAGS		"-std=gnu99 ${MAKEFLAGS} ${LDFLAGS} ${CPPFLAGS}"

setenv	CXXFLAGS	"-std=gnu++0x ${MAKEFLAGS} ${LDFLAGS} ${CPPFLAGS}"

#Path to xmkmf, Makefile generator for X Window System
setenv	XMKMF		"/usr/bin/xmkmf"

