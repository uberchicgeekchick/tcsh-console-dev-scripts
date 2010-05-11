#!/bin/tcsh -f
set seach_path = "/"
if ( ${?1} && -d "${1}" ) set search_path = "${1}"
foreach session_dump ( `sudo find "${search_path}" -name "session_mm*"` )
	sudo rm -f "${session_dump}"
end
