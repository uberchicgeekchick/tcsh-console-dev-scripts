#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" && -d "${1}" )) then
	printf "Usage: %s [directory]", "`basename '${0}'`";
	exit -1;
endif

foreach file ( "`find ${1} -iregex '.*, released on.*'`" )
	set filename = "`printf "\""${file}"\"" | sed 's/\(.*\)\(, released on[^\.]\+\)\.\([^\.]\+\)/\1.\3/g'`";
	mv "${file}" "${filename}";
end

