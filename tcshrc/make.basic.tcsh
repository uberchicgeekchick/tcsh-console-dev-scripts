#!/bin/tcsh -f
if ( "${?LDFLAGS}" == "1" ) unsetenv "${LDFLAGS}";
if ( "${?LIBS}" == "1" ) unsetenv "${LIBS}";
if ( "${?LD_LIBRARY_PATH}" == "1" ) unsetenv "${LD_LIBRARY_PATH}";
if ( "${?LD_RUN_PATH}" == "1" ) unsetenv "${LD_RUN_PATH}";
if ( "${?CC}" == "1" ) unsetenv "${CC}";
if ( "${?CPP}" == "1" ) unsetenv "${CPP}";
#if ( "${?CPPFLAGS}" == "1" ) unsetenv "${CPPFLAGS}";
#if ( "${?CFLAGS}" == "1" ) unsetenv "${CFLAGS}";
#if ( "${?XMKMF}" == "1" ) unsetenv "${XMKMF}";


#C compiler flags
setenv	"LDFLAGS"		"-L/lib64 -L/usr/lib64 -L/usr/lib -L/lib"
#libraries to pass to the linker, e.g. -l<library>
setenv	"LIBS"			"-L/lib64 -L/usr/lib64 -L/usr/lib -L/lib"

setenv	"LD_LIBRARY_PATH"	"/usr/include"
setenv	"LD_RUN_PATH"		"/usr/include"


#C compiler command
setenv	"CC"		"/usr/bin/gcc"

#C preprocessor
setenv	"CPP"		"/usr/bin/cpp"

#C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#you have headers in a nonstandard directory <include dir>
setenv	"CPPFLAGS"	"-I${LD_LIBRARY_PATH}"

setenv	"CFLAGS"	"-Wall ${LDFLAGS} ${CPPFLAGS}"


#Path to xmkmf, Makefile generator for X Window System
setenv	"XMKMF"		"/usr/bin/xmkmf"

