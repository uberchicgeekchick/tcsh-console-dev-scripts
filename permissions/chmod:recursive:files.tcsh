#!/usr/bin/tcsh -f
set mode="-x";
if( ${?1} && "${1}" != "" ) set mode="${1}"
foreach exec ( "`find ./* -mindepth 1 -type f`" )
	chmod "${mode}" "${exec}"
end
