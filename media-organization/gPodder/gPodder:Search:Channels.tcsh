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

/usr/bin/grep --perl-regex -e "${attrib}=["\""'\''].*${value}.*["\""'\'']" "${HOME}/.config/gpodder/channels.opml" | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/'

exit

usage:
	printf "Usage| %s --[title|xmlUrl|htmlUrl|text|description]='[search_term]'\n" `basename "${0}"`
	exit
