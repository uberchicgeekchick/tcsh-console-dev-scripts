#!/usr/bin/tcsh -f
if ( "${?1}" == "0" || "${1}" == "" || ! -d "${1}" ) then
	printf "Usage: add:path.tcsh path_to_recurse"
	exit
endif
set new_path = ""
foreach dir ( "`find '${1}' -regextype posix-extended -regex '[^\.]*' -type d`" )
	switch( `basename "${dir}"` )
	case "tmp": case "reference": case "lost+found":
		breaksw
	default:
		set escaped_dir = "`echo '${dir}' | sed 's/\//\\\//g'`"
		if ( "`echo '${PATH}' | sed 's/:\(${escaped_dir}\)/\1/g'`" == "${dir}" ) continue
		
		set new_path = "${new_path}:${dir}"
		breaksw
	endsw
end
if ( "${new_path}" == "" ) exit
setenv PATH "${PATH}:${new_path}"
