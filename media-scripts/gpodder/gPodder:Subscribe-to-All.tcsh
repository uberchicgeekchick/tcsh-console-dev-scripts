#!/bin/tcsh -f
cd "`dirname '${0}'`"/..

set message = "Subscribing"
set action = "add"

switch ( "${1}" )
case 'delete': case 'unsubscribe':
	set message = "Unsubscribing"
	set action = "del"
	breaksw
case 'add': case 'subscribe': default:
	set message = "Subscribing"
	set action = "add"
	breaksw
endsw

/usr/bin/grep  -r -e "^[^\!]\+<outline.*xmlUrl=["\""'][^"\""']\+["\""'].*" "v2/OPML" | sed "s/.*xmlUrl=["\""']\([^"\""']\+\)["\""'].*/\1/g" >! .alacast.opml.dump.lst

foreach podcast ( "`cat .alacast.opml.dump.lst`" )
	set escaped_podcast = "`echo '${podcast}' | sed 's/\([\/\-\?\&\=\+\.]\)/\\\1/g' | sed 's/[\r\n]//g'`"
	if ( `/usr/bin/grep -e "${escaped_podcast}" "${HOME}/.config/gpodder/channels.opml" | sed "s/.*xmlUrl=["\""']\([^"\""']\+\)["\""'].*/\1/g"` == "${podcast}" ) continue

	printf "\n\t${message} to:\n\t\t %s" "${podcast}"
	continue
	set testing_add = `gpodder --"${action}"="${podcast}"`
	printf "\t["
	switch ( `echo ${testing_add} | sed 's/^\([ADE]\)/\1/g'` )
	case "A":
		printf "added"
		breaksw
	case "D":
		printf "deleted"
		breaksw
	case "E":
		printf "error"
		breaksw
	default:
		printf "unknown"
	endsw
	printf "]\n\n"
end

rm .alacast.opml.dump.lst
