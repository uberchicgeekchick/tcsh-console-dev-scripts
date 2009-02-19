#!/bin/tcsh -f
if ( "${?1}" == "0" || "${1}" == "" ) goto usage

set attrib = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`"
set value = ""

switch ( "${attrib}" )
case "title":
case "xmlUrl":
case "htmlUrl":
case "text":
case "description":
	set value = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`"
	breaksw
case "help":
	goto usage
	breaksw
default:
	set attrib = "title"
	set value = "${1}"
	breaksw
endsw

switch ( "${2}" )
case "title":
case "htmlUrl":
case "text":
case "description":
	set search_for = "${2}"
	breaksw
case "help":
	goto usage
	breaksw
case "xmlUrl":
default:
	set search_for = "xmlUrl"
	breaksw
endsw
											
/usr/bin/grep -i --perl-regex -e "${attrib}=["\""'\''].*${value}.*["\""'\'']" "${HOME}/.config/gpodder/channels.opml" | sed "s/.*${search_for}=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/" | sed "s/\&amp;/\&/g"

exit

usage:
	printf "Usage| %s [--title|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit
