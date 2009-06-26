#!/bin/tcsh -f

alias	"./configure"	"./configure --libdir=/usr/lib64"
alias	"./autogen.sh"	"./autogen.sh --libdir=/usr/lib64"

#alias make 'if ( ${?GREP_OPTIONS} ) set grep_options="${GREP_OPTIONS}";\
#	if( ${?GREP_OPTIONS} ) unsetenv $GREP_OPTIONS; make'
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
setenv	CPPFLAGS	"-I${LD_LIBRARY_PATH}"

setenv	MAKEFLAGS	"-O3 -Wall -Wextra -Wformat=2 -Wno-unused-parameter"

setenv	MYFLAGS		"${MAKEFLAGS} -Wswitch-enum -Wno-missing-field-initializers --combine"
setenv	MYCFLAGS	"${MYFLAGS} -Wmissing-prototypes"
setenv	MYCXXFLAGS	"${MYFLAGS}"


setenv	CFLAGS		"-std=gnu99 ${MYCFLAGS} ${CPPFLAGS}"

setenv	CXXFLAGS	"-std=gnu++0x ${MYCXXFLAGS} ${CPPFLAGS}"

#Path to xmkmf, Makefile generator for X Window System
setenv	XMKMF		"/usr/bin/xmkmf"

