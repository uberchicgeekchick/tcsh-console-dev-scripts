#!/bin/tcsh
if ( -e "${1}" ) then
	set filename = "/tmp/rmNewline."`date +%F@%I:%M:%S-%P`
	/usr/bin/ex +'1,$s/[\r\n]//g' +'1,$s/\t\+/ /g' +'1,$s/\/\*[^(*\/)]*\*\///g' +"w! ${filename}" +'q!' "${1}"
	cat "${filename}"
else
	echo "i couldn't read the file that you want to remove the new lines from."
endif
