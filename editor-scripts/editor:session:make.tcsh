#!/bin/tcsh -f
set my_editor = ""
if ( "${?1}" == "1" ) then
	set my_editor = "${1}"
	shift
else
	set my_editor = "`printf '${0}' | sed 's/.*\/\([^:]\+\).*/\1/g'`"
endif
set my_editor = `where "${my_editor}" | head -1`

if( ! -e "${my_editor}" ) then
	set my_editor = "${EDITOR}"
endif
set my_editor = `basename "${my_editor}"`
set session_exec = "./${my_editor}.session.tcsh"

set clean_up = "no"
if ( "${?1}" == "1" && "${1}" == "--clean-up" ) then
	set clean_up = "yes"
	shift
endif

set search_dir = "./"
if ( "${?1}" != "0" && "${1}" != "" && -d "${1}" ) set search_dir = "${1}"

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
