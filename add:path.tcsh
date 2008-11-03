#!/usr/bin/tcsh
set new_path = "${PWD}"
foreach dir ( `find "${PWD}" -type d -regex '[^\.]*'` )
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

if ( "${new_path}" == "" ) exit 0
setenv PATH "${PATH}:${new_path}"
