#!/bin/tcsh -f
set clean_up = "no"
set search_dir = "./"
set my_editor = "`printf '${0}' | sed 's/.*\/\([^:]\+\).*/\1/g'`"

while ( "${?1}" != "0" && "${1}" != "" )
	case -d:
		set search_dir = "${1}"
		breaksw
	
	case "--clean-up":
		set clean_up = "yes"
		breaksw
	
	default:
		set my_editor = "${1}"
		breaksw
	shift
end

set my_editor = `where "${my_editor}" | head -1`
if( ! -e "${my_editor}" ) then
	set my_editor = "${EDITOR}"
endif
set my_editor = `basename "${my_editor}"`

set session_exec = "./${my_editor}.session.tcsh"

set session_started = ""
foreach swp ( "`find ${search_dir} -iregex '\..*\.swp' | sed 's/\/\.\(.*\)\.swp/\/\1/g'`" )
	if ( "${session_started}" == "" ) then
		set session_started = "[done]"
		printf '#\!/bin/tcsh -f\nset my_editor = "`printf "${0}" | sed '\''s/.*\/\([^\.]\+\).*/\\1/g'\''`"\nswitch ( "${my_editor}" )\ncase "gedit":\n\tbreaksw\ncase "vim":\ndefault:\n\tset my_editor = `printf "%%s -p %%s" "vim" '\''+tabdo$-2'\''`\n\tbreaksw\nendsw\n\n${my_editor}' >! "${session_exec}"
	endif
	
	printf " %s${swp}%s" '"' '"' >> "${session_exec}"
	if ( "${clean_up}" == "yes" ) rm "${swp}"
end

if ( "${session_started}" == "[done]" ) then
	printf "\n" >> "${session_exec}"
	chmod +x "${session_exec}"
endif
