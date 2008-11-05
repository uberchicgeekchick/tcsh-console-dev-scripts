#!/bin/tcsh
if ( "${?1}" == "0" || "${1}" == "" || ! -d "${1}" ) then
	printf "Usage add:path.tcsh path_to_recurse"
	exit
endif
set new_path = ""
foreach dir ( `find "${1}" -type d -regex '[^\.]*'` )
	switch( `basename "${dir}"` )
	case ".":
	case "..":
	case "tmp":
	case "reference":
	case "lost+found":
		breaksw
	default:
		set new_path = "${new_path}:${dir}"
		breaksw
	endsw
end
if ( "${new_path}" == "" ) exit
setenv PATH "${PATH}:${new_path}"

exit

#find_dirs:
#foreach cw_dir ( ${start_dir}/* )
#	if ( - "${start_dir}/${cw_dir}" ) then
#		set new_path = "${new_path}:${start_dir}/${cw_dir}"
#		set dir_before = "${start_dir}/${cw_dir}"
#		goto find_dirs
#		set start_dir = "${dir_before}"
#	endif
#end
