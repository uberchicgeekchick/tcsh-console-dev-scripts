#!/bin/tcsh -f
if( -e "${1}" ) then
	set filename = "/tmp/rmNewline."`date +%F@%I:%M:%S-%P`
	ex -s '+1,$s/\v\r\n?\_$//g' '+1,$s/\n//g' '+1,$s/\t\+/ /g' '+1,$s/\/\*[^(*\/)]*\*\///g' "+w! ${filename}" '+q!' "${1}"
	cat "${filename}"
else
	echo "i couldn't read the file that you want to remove the new lines from."
endif
