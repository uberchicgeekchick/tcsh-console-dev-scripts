#!/usr/bin/tcsh -f
set mode="-x";
set target="./";
if( ${?1} && "${1}" != "" && -d "${1}" ) set target="${1}";
foreach exec ( "`find '${target}/' -type f`" )
	chmod "${mode}" "${exec}";
end
