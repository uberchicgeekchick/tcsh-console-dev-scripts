#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} )	\
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "include-and-lib.paths-and-flags.init.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

if( ${?TCSH_RC_DEBUG} )	\
	printf "Setting up make & linker environment @ %s.\n" `date "+%I:%M:%S%P"`;

#Path to xmkmf, Makefile generator for X Window System
setenv XMKMF "/usr/bin/xmkmf";

#
#C compiler linking flags
#	libraries to pass to the linker.
#		-l<library>, e.g. -lpango-1.0
#	or shared objects directly:
#		-L<library.path.so>, e.g. -L/usr/lib64 or -L/usr/lib64/libpango-1.0.so
#setenv	LDFLAGS		""
#setenv	LIBS		""



#C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#you have headers in a nonstandard directory <include dir>
setenv INCLUDE_AND_LIB_FLAGS_AND_PATHS "-I/usr/local/include -I/usr/include -I. -I..";

set library_paths="";
set lib_dirs=( "/usr/local/lib64"  "/usr/lib64" "/lib64"  );
foreach lib_dir(${lib_dirs})
	if( -d "${lib_dir}" && "`/bin/ls '${lib_dir}'`" != "" )	\
		set library_paths="${library_paths}:${lib_dir}";
end

foreach lib_dir(${lib_dirs})
	set lib_dir="`printf '%s' '${lib_dir}' | sed -r 's/(.*)64${eol}/\1/'`";
	if( -d "${lib_dir}" && "`/bin/ls '${lib_dir}'`" != "" )	\
		set library_paths="${library_paths}:${lib_dir}";
end

if( "${library_paths}" != "" )	then
	setenv	LD_LIBRARY_PATH		"${library_paths}";
	setenv	LD_RUN_PATH		"${library_paths}";
	setenv INCLUDE_AND_LIB_FLAGS_AND_PATHS "${INCLUDE_AND_LIB_FLAGS_AND_PATHS}`printf '%s' '${library_paths}' | sed -r 's/\:/\ \-L/g'`";
endif

unset library_paths;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "include-and-lib.paths-and-flags.init.tcsh";

