#!/bin/tcsh -f
if( ! ${?1} || "${1}" == "" ) then
	printf "Usage:\n\t%s new_word\n" "`basename ${0}`"
	exit
endif

if( ! -e "${HOME}/.aspell.pws" ) touch "${HOME}/.aspell.pws"

while ( ! ${?1} || "${1}" == "" )
	if( `/usr/bin/grep "${1}"  "${HOME}/.aspell.pws"` != "" ) continue
	
	printf "Adding: %s\n" "${1}"
	printf "%s\n" >> "${HOME}/.aspell.pws" "${1}"
	
	shift
end
