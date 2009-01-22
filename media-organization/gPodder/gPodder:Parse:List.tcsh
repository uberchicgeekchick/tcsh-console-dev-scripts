#!/bin/tcsh -f
if ( "${?1}" != "0" && "${1}" != "" ) then
	switch ( "${1}" )
	case '--del':
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

if ( ! ( "${?1}" == "1" && -e "${1}" ) ) then
	printf "Usage: [--add|--subscribe|--delete|--del|--unsubscribe] %s file_with_list_of_urls(one url per line)" `basename "${0}"`
	exit
endif

foreach podcast ( "`cat '${1}'" )
	printf "Adding:\n\t %s" "${podcast}"
	gpodder --${action}="${podcast}" >& /dev/null &
	wait
	printf "\t\t[done]\n"
end

