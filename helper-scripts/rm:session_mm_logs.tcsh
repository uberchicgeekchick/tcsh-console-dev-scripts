#!/bin/tcsh
set search_dir = "./"
if ( "${?1}" != "0" && "${1}" != "" && -d "${1}" ) set search_dir = "${1}"

foreach session ( `find "${search_dir}" -name "session*.sem"` )
	rm -r "${session}"
end
