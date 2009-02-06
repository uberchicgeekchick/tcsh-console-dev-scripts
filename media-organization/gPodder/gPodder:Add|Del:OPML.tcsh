#!/bin/tcsh -f
if ( "${?1}" != "0" && "${1}" != "" ) then
	switch ( "${1}" )
	case '--delete':
	case '--unsubscribe':
		shift
		set message = "Delet"
		set action = "del"
		breaksw
	case '--add':
	case '--subscribe':
		shift
	default:
		set message = "Add"
		set action = "add"
		breaksw
	endsw
endif

if ( "${?1}" == "0" && "${1}" == "" && -e "${1}" ) then
	printf "Usage: %s OPML_file"
	exit
endif

foreach podcast ( "`/usr/bin/grep --perl-regexp -e '^[\t\ \s]+<outline.*xmlUrl=["\""'\''][^"\""'\'']+["\""]' '${1}' | sed 's/^[\ \s\t]\+<outline.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/g'`" )
	printf "Adding:\n\t %s" "${podcast}"
	( gpodder --${action}="${podcast}" > /dev/tty ) >& /dev/null
	printf "\t\t[done]\n"
end

