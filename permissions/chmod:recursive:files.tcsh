#!/usr/bin/tcsh -f
set mode="-x";
set target="./";
if( ${?1} && "${1}" != "" && -d "${1}" ) set target="${1}";
foreach exec ( "`find -L '${target}/' -ignore_readdir_race -type f`" )
	chmod "${mode}" "${exec}";
end
