#!/bin/tcsh -f
set search_dir = "./"
if( ${?1} && -d "${1}" ) set search_dir = "${1}"

foreach session ( `/usr/bin/find "${search_dir}" -name "session*.sem"` )
	rm -r "${session}"
end
