#!/bin/tcsh -f
set exec="${1}"
set command="`where ${1} | head -1`"
set arguments=""
shift
while ( ${?1} && "${1}" != "" )
	set arguments="${arguments} ${1}"
	set option="`printf '${1}' | sed 's/^\([^=]*\)=\?\(.*\)$/\1/'`"
	set value="`printf '${1}' | sed 's/^\([^=]*\)=\?\(.*\)$/\2/'`"
	if( "${option}" != "" && "${value}" == "" ) set value="${option}"
	if( `printf "%s" | sed 's/\(\/\)/\1/g'` != "/" "${value}" ) shift ; continue

	set arguments_path="${value}"
	switch ( "${exec}" )
	case "cd":
	case "mkdir":
		breaksw
	case "vi":
	case "vim":
	case "vim-enhanced":
	case "wget":
		set arguments_path=`dirname "${value}"`
		breaksw
	endsw
	
	if( ! -d "${arguments_path}" ) mkdir -p "${arguments_path}"
	shift
end

"${command} ${arguments}"

