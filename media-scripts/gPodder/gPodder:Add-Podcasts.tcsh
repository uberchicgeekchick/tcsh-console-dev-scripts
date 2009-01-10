#!/bin/tcsh -f
set add_or_del = "add"
set message = "Add"
set podcast_list = "${1}"

if ( "${1}" == "del" ) then
	set message = "Delet"
	set add_or_del = "del"
endif

if ( "${podcast_list}" == "" || ! -e "${podcast_list}" ) then
	printf "Usage: %s [add|del] (wordlist of podcasts)" `basename "${0}"`
	exit
endif

foreach podcast ( "`cat ${podcast_list}`" )
	printf "%sing:\n\t%s\n" "${message}" "${podcast}"
	gpodder --${add_or_del}="${podcast}"
end

