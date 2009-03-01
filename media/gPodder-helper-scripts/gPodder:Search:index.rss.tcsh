#!/bin/tcsh -f
if ( ! ( ${?1} && "${1}" != "" ) ) goto usage

set be_verbose = ""
if ( "${1}" == "--verbose" ) then
	set be_verbose = "TRUE"
	shift
endif

set attrib = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`"
set value = ""

switch ( "${attrib}" )
case "title":
case "description":
case "link":
case "url":
case "guid":
case 'link':
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
case "--output=title":
case "--output=description":
case "--output=url":
case "--output=guid":
case "--output=pubDate":
case "--output=link":
	set output = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`"
	breaksw
case "--help":
	goto usage
	breaksw
default:
	set output = "${attrib}"
	breaksw
endsw

set gpodder_dl_dir = "`grep 'download_dir' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`"

foreach index ( "`find '${gpodder_dl_dir}' -name index.xml`" )
	set found = "`/usr/bin/grep --ignore-case --perl-regex -e '<${attrib}>.*${value}.*<\/${attrib}>' '${index}' | sed 's/[\r\n]\+//g' | sed 's/.*<${attrib}>\([^<]\+\)<\/${attrib}>.*/\1/g'`"
	
	if ( "${found}" == "" ) continue;
	
	if ( "${attrib}" != "${output}" ) set found = "`/usr/bin/grep --ignore-case --perl-regex -e '<${output}>[^<]*<\/${output}>' '${index}' | sed 's/[\r\n]\+//g' | sed 's/.*<${output}>\([^<]\+\)<\/${output}>.*/\1\r/g'`"

	foreach item ( "${found}" )
		printf "%s:\t%s\n" "${index}" "${item}"
	end
	
	if ( "${be_verbose}" == "TRUE" ) then
		cat "${index}"
		printf "\n\n"
	endif
end

exit

usage:
	printf "Usage| %s [--verbose] [--title(default)|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit

