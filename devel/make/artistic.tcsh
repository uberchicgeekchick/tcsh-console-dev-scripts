#!/bin/tcsh -f

alias	"configure"	"configure --libdir=/usr/lib64"

#C compiler linking flags
#	libraries to pass to the linker.
#		-l<library>, e.g. -lpango-1.0
#	or shared objects directly:
#		-L<library.path.so>, e.g. -L/usr/lib64/libpango-1.0.so
#setenv	LDFLAGS		"--reduce-memory-overheads"
#setenv	LIBS		""


setenv	LD_LIBRARY_PATH		"/usr/include"
setenv	LD_RUN_PATH		"/usr/include"

#autoconf, automake, & etc settings
setenv	AC_CONFIG_MACRO_DIR	"/usr/share/autoconf/autoconf"

#C compiler command
setenv	CC		"/usr/bin/gcc"

#C preprocessor
setenv	CPP		"/usr/bin/cpp"

#C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#you have headers in a nonstandard directory <include dir>
setenv	CPPFLAGS	"-I${LD_LIBRARY_PATH}"

setenv	MAKEFLAGS	"-O3 -Wall -Wextra -Wstrict-aliasing=3 -Wformat=2 -Werror -Wno-unused-parameter"

setenv	MYFLAGS		"${MAKEFLAGS} -Wfatal-errors -Wswitch-enum -Wno-format-nonliteral -Wno-missing-field-initializers --combine"
setenv	MYCFLAGS	"${MYFLAGS} -Wmissing-prototypes -Wmissing-declarations"
setenv	MYCXXFLAGS	"${MYFLAGS}"


setenv	CFLAGS		"-std=gnu99 ${MYCFLAGS} ${CPPFLAGS}"

setenv	CXXFLAGS	"-std=gnu++0x ${MYCXXFLAGS} ${CPPFLAGS}"

#Path to xmkmf, Makefile generator for X Window System
setenv	XMKMF		"/usr/bin/xmkmf"

