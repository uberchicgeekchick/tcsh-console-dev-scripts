#!/bin/tcsh -f
if( ${?GREP_OPTIONS} )	unsetenv	GREP_OPTIONS
unalias grep

alias	"configure"	"/projects/cli/devel/make/my:configure"
alias	"autogen.sh"	"/projects/cli/devel/make/my:autogen.sh"

#
#C compiler linking flags
#	libraries to pass to the linker.
#		-l<library>, e.g. -lpango-1.0
#	or shared objects directly:
#		-L<library.path.so>, e.g. -L/usr/lib64/libpango-1.0.so
#setenv	LDFLAGS		""
#setenv	LIBS		""

setenv	LD_LIBRARY_PATH		"/usr/include"
setenv	LD_RUN_PATH		"/usr/include"


#C compiler command
setenv	CC		"/usr/bin/gcc"

#C preprocessor
setenv	CPP		"/usr/bin/cpp"

#C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#you have headers in a nonstandard directory <include dir>
if( ${?CPPFLAGS} )	unsetenv		CPPFLAGS

if ( ${?MAKEFLAGS} )	unsetenv		MAKEFLAGS

if ( ${?CFLAGS} )	unsetenv		CFLAGS

if ( ${?CXXFLAGS} )	unsetenv		CXXFLAGS

#Path to xmkmf, Makefile generator for X Window System
setenv	XMKMF		"/usr/bin/xmkmf"

