#!/bin/tcsh -f
if ( "${?1}" == "0" || "${1}" == "" || "${1}" == "--help" ) goto usage

set action = "delete"
while ( "${?1}" != "0" && "${1}" != "" )
	switch ( "${1}" )
	case "--add":
	case "--subscribe":
		shift
		set action = "add"
		continue
		breaksw
	
	case "--del":
	case "--delete":
	case "--unsubscribe":
		shift
		set action = "delete"
		continue
		breaksw
	endsw
			
	set attrib = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`"
	set values_filename = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`"
	shift
	if ( ! -e "${values_filename}" ) continue
	if ( "${attrib}" == "" ) continue
	
	switch ( "${attrib}" )
	case "titles-in":
	case "xmlUrls-in":
	case "htmlUrls-in":
	case "texts-in":
	case "descriptions-in":
		set attrib = `printf "${attrib}" | sed 's/^\(.*\)s\-in$/\1/'`
		breaksw
	default:
		printf "\t%s is not supported.\n\tSupported options are --[titles-in|xmlUrls-in|htmlUrls-in|texts-in|descriptions-in]="\""[file_listing_values (one per line)]"\""\n\tFor more information see %s --help\n" "${attrib}" `basename "${0}"`
		continue
	endsw
	
	foreach value ( "`cat ${values_filename}`" )
		set found_podcast = "FALSE"
		foreach podcast ( "`/usr/bin/grep -i --perl-regex -e '${attrib}=["\""'\''].*${value}.*["\""'\'']' '${HOME}/.config/gpodder/channels.opml' | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/' | sed 's/\(&\)amp;/\1/g'`" )
			if ( "${found_podcast}" == "FALSE" ) set found_podcast = "TRUE"
			if ( "${action}" == "delete" ) then
				printf "Deleting: %s\n" "${podcast}"
				gpodder --del="${podcast}"
			else if ( "${action}" == "add" ) then
				break
			endif
		end
		if ( "${found_podcast}" == "TRUE" || "${action}" == "delete" ) continue

		printf "Adding: %s\n" "${podcast}"
		gpodder --add="${podcast}"
	end
end

exit

usage:
	printf "Usage: %s [--help] [--del|--delete|--unsubscribe(default)] | [--add|--subscribe] --[titles-in|xmlUrls-in|htmlUrls-in|texts-in|descriptions-in]="\""[file_listing_values (one per line)]"\""\n" `basename "${0}"`
	exit
