#!/bin/tcsh -f
set lib_path="/usr/lib"
if( -d "${lib_path}" ) then
	foreach library( "`find ${lib_path}/* -type f -perm /u+x,g+x,o+x -printf '%h\n' | sort | uniq`" )
		set lib_path="${lib_path}:${library}";
	end
	if(! ${?PATH} ) setenv PATH "";
	setenv PATH "${PATH}:${lib_path}";
	unset library
endif
unset lib_path

