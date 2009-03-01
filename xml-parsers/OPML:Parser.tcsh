#!/bin/tcsh -f
if (! ${?1} && "${1}" != "" && -e "${1}" ) then
	printf "Usage: %s OPML_file"
	exit
endif

set action = ""
switch ( "${1}" )
case '--delete':
case '--unsubscribe':
	shift
	set action = "del"
	breaksw
case '--add':
case '--subscribe':
	shift
	set action = "add"
	breaksw
endsw

/usr/bin/grep --perl-regexp -e '^[\t\ \s]+<outline.*xmlUrl=["\""'\''][^"\""'\'']+["\""'\'']' "${1}" | sed 's/^[\ \s\t]\+<outline.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/g' >! ./.alacast.podcasts.lst

if ( "${action}" == "" ) then
	cat ./.alacast.podcasts.lst
	rm ./.alacast.podcasts.lst
	exit
endif


foreach podcast ( "`cat ./.alacast.podcasts.lst`" )
	printf "Adding:\n\t %s" "${podcast}"
	gpodder --"${action}"="${podcast}"
end
if ( -e "./.alacast.podcasts.lst" ) rm "./.alacast.podcasts.lst"

