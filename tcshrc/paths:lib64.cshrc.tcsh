#!/bin/tcsh -f
set lib_path="/usr/lib";
if( "${1}" != "" && "${1}" == "x86_64" ) \
	set lib_path="${lib_path}64";

if(! -d "${lib_path}" ) \
	exit -1;

foreach library( "`find -L ${lib_path} -ignore_readdir_race -type f -perm /u+x,g+x,o+x -printf '%h\n' | sort | uniq`" )
	if( ${?TCSH_RC_DEBUG} )	\
		printf "Attempting to add: [file://%s] to your PATH:\t\t" "${library}";
	set library="`echo '${library}' | sed -r 's/([\:])/\\\1/g'`";
	set escaped_library="`echo '${library}' | sed -r 's/\//\\\//g'`";
	if( "`echo '${PATH}' | sed 's/.*:\(${escaped_library}\).*/\1/g'`" == "${library}" ) then
		if( ${?TCSH_RC_DEBUG} )	\
			printf "[skipped]\n\t\t\t<file://%s> is already in your PATH\n" "${library}";
		continue;
	endif
	
	if( ${?TCSH_RC_DEBUG} )	\
		printf "[added]\n";
	if(! ${?lib_path} ) then
		set lib_path="${library}";
	else
		set lib_path="${lib_path}:${library}";
	endif
end

if( ${?lib_path} ) then
	if(! ${?PATH} ) then
		setenv PATH "${lib_path}";
	else
		setenv PATH "${PATH}:${lib_path}";
	endif
endif

unset library lib_path;

