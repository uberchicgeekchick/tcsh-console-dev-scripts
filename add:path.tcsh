#!/usr/bin/tcsh
set new_path = `dirname "${0}"`
foreach dir ( `find "${new_path}" -type d -regex '[^\.]*'` )
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

setenv PATH "${PATH}:${new_path}"

exit 0

find_dirs:
foreach cw_dir ( ${start_dir}/* )
	if ( - "${start_dir}/${cw_dir}" ) then
		set new_path = "${new_path}:${start_dir}/${cw_dir}"
		set dir_before = "${start_dir}/${cw_dir}"
		goto find_dirs
		set start_dir = "${dir_before}"
	endif
end
