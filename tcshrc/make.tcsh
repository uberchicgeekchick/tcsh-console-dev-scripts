#!/bin/tcsh -f
exit
if ( "${?LDFLAGS}" == "1" ) unsetenv	 "${LDFLAGS}";
if ( "${?LIBS}" == "1" ) unsetenv	 "${LIBS}";
if ( "${?LD_LIBRARY_PATH}" == "1" ) unsetenv	 "${LD_LIBRARY_PATH}";
if ( "${?LD_RUN_PATH}" == "1" ) unsetenv	 "${LD_RUN_PATH}";
if ( "${?CC}" == "1" ) unsetenv	 "${CC}";
if ( "${?CPP}" == "1" ) unsetenv	 "${CPP}";
if ( "${?CPPFLAGS}" == "1" ) unsetenv	 "${CPPFLAGS}";
if ( "${?CFLAGS}" == "1" ) unsetenv	 "${CFLAGS}";
if ( "${?XMKMF}" == "1" ) unsetenv	 "${XMKMF}";


#TODO Make this just agrigate all values into $CFLAGS & $CPPFLAGS

set libraries=( "/lib64" "/usr/lib64" "/usr/lib" "/lib" );
goto setup_libraries

next_libraries:
#set libraries="`find '${1}' -type d`"
goto setup_libraries

set_libraries:
#C compiler flags
setenv	"LDFLAGS"		"${linker_libs}"
#libraries to pass to the linker, e.g. -l<library>
setenv	"LIBS"			"${linker_libs}"

start_includes:
set includes=( "/usr/include" );
setenv	"LD_LIBRARY_PATH"	"/usr/include:${lib_paths}"
setenv	"LD_RUN_PATH"		"/usr/include:${lib_paths}"
goto setup_includes
next_includes:

setup_make:
#C compiler command
setenv	"CC"		"/usr/bin/gcc"

#C preprocessor
setenv "CPP"		"/usr/bin/cpp"

#C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#you have headers in a nonstandard directory <include dir>
setenv "CPPFLAGS"	"${include_dirs}"

setenv	"CFLAGS"	"-Wall ${LDFLAGS} ${CPPFLAGS}"


#Path to xmkmf, Makefile generator for X Window System
setenv "XMKMF"		"/usr/bin/xmkmf"

exit;

setup_libraries:
foreach library ( ${libraries} )
	if ( "${?linker_libs}" == "1" ) then
		set linker_libs="${linker_libs} -L${library}";
	else
		set linker_libs="-L${library}";
	endif
	if ( "${?lib_paths}" == "1" ) then
		set lib_paths="${lib_paths}:${library}";
	else
		set lib_paths="${library}";
	endif
end
if ( - "${?LDFLAGS}" ) then goto next_libraries
goto set_libraries

setup_includes:
foreach include_dir ( ${include_paths} )
	if ( "${?linker_includes}" == "1" ) then
		set linker_libs="${linker_includes} -L${include_dir}";
	else
		set linker_libs="-L${include_dir}";
	endif
	if ( "${?include_paths}" == "1" ) then
		set include_paths="${include_path}:${include_paths}";
	else
		set include_paths="${include_path}";
	endif
end
if ( - "${?LD_LIBRARY_PATH}" ) then goto next_includes
goto setup_make

