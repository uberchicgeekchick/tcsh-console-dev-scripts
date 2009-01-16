#!/bin/tcsh -f
if ( "${?1}" == "0" || "${1}" == "" ) goto usage

set attrib = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`"
set value = ""

switch ( "${attrib}" )
case "title":
case "description":
case "link":
case "url":
case "guid":
case "pubDate":
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
case "description":
case "link":
case "url":
case "guid":
case "pubDate":
	set search_for = "${2}"
	breaksw
case "help":
	goto usage
	breaksw
case "title":
default:
	set search_for = "title"
	breaksw
endsw

set gpodder_dl_dir = "`grep 'download_dir' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d"\"" "\"" -f2`"

foreach index ( "`find '${gpodder_dl_dir}' -name index.xml`" )
	printf "${index}\n"
	/usr/bin/grep --perl-regex -e "${attrib}=["\""'\''].*${value}.*["\""'\'']" "${index}" | sed "s/.*${search_for}=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/"
end

exit

usage:
	printf "Usage| %s [--title|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit

