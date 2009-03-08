#!/bin/tcsh -f
if ( ! ${?1} || "${1}" == "" ) then
	printf "Usage:\n\t%s new_word\n" "`basename ${0}`"
	exit
endif

if ( ! -e "${HOME}/.aspell.pws" ) touch "${HOME}/.aspell.pws"

while ( ! ${?1} || "${1}" == "" )
	if ( `/usr/bin/grep "${1}"  "${HOME}/.aspell.pws"` != "" ) continue
	
	printf "Adding: ${1}\n"
	printf "${1}\n" >> "${HOME}/.aspell.pws"
	
	shift
end
