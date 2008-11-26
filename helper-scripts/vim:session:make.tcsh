#!/bin/tcsh -f
set session_exec = "vim.session.tcsh"
set search_dir = "./"
if ( "${?1}" != "0" && "${1}" != "" && -d "${1}" ) set search_dir = "${1}"

set session_started = ""
foreach swp ( "`find ${search_dir} -iregex .\*\.swp`" )
	if ( "${session_started}" == "" ) then
		set session_started = "[done]"
		printf '#\!/bin/tcsh -f\nvim-enhanced -p ' >! "${session_exec}"
	endif
	printf "%s" "${swp}" | sed 's/\(.*\)\/\.\(.*\.opml\).swp/"\1\/\2"\ /g' >> "${session_exec}"
	rm "${swp}"
end

if ( "${session_started}" == "[done]" ) then
	printf "\n" >> "${session_exec}"
	chmod +x "${session_exec}"
endif
