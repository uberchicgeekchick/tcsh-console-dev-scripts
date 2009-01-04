#!/bin/tcsh -f
set session_exec = "vim.session.tcsh"

set clean_up = "no"
if ( "${?1}" == "1" && "${1}" == "--clean-up" ) then
	set clean_up = "yes"
	shift
endif

set search_dir = "./"
if ( "${?1}" != "0" && "${1}" != "" && -d "${1}" ) set search_dir = "${1}"

set session_started = ""
foreach swp ( "`find . -iregex '\..*\.swp' | sed 's/\/\.\(.*\)\.swp/\/\1/g'`" )
	if ( "${session_started}" == "" ) then
		set session_started = "[done]"
		printf '#\!/bin/tcsh -f\nvim-enhanced -p '\''+tabdo $-2'\' >! "${session_exec}"
	endif

	printf " %s${swp}%s" '"' '"' >> "${session_exec}"
	if ( "${clean_up}" == "yes" ) rm "${swp}"
end

if ( "${session_started}" == "[done]" ) then
	printf "\n" >> "${session_exec}"
	chmod +x "${session_exec}"
endif
