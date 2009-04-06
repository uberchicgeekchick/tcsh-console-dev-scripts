#!/bin/tcsh -f
if ( ! ( ${?1} && "${1}" != "" ) ) goto usage

set gpodder_dl_dir = "`grep 'download_dir' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`"

if ( "${1}" == "--verbose" ) then
	set be_verbose;
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
	if( "${value}" == "" ) then
		shift;
		set value = "${1}";
	endif
	breaksw
case "help":
	goto usage
	breaksw
default:
	set attrib = "title"
	set value = "${1}"
	breaksw
endsw

if(! ${?2} ) goto find_index_rss

set output = "`printf '${2}' | sed 's/\-\-\([^=]\+\)=["\""'\'']*\(.*\)["\""'\'']*/\2/g'`"
switch ( ${output} )
case "title":
case "description":
case "url":
case "guid":
case "pubDate":
case "link":
	if( ${?3} && "${3}" == "--refetch" ) set refetch
	breaksw
default:
	if( "${2}" == "--refetch" ) set refetch
	set output = "${attrib}"
	breaksw
endsw

find_index_rss:
foreach index ( "`find '${gpodder_dl_dir}' -name index.xml`" )
	set found = "`/usr/bin/grep --ignore-case --perl-regex -e '<${attrib}>.*${value}.*<\/${attrib}>' '${index}' | sed 's/.*<${attrib}>\([^<]\+\)<\/${attrib}>.*/\1/g'`"
	
	if ( "${found}" == "" ) continue
	
	if ( "${attrib}" != "${output}" ) set found = "`/usr/bin/grep --ignore-case --perl-regex -e '<${output}>[^<]*<\/${output}>' '${index}' | sed 's/[\r\n]\+//g' | sed 's/.*<${output}>\([^<]\+\)<\/${output}>.*/\1\r/g'`"

	foreach item ( "${found}" )
		printf "%s:\t%s\n" "${index}" "${item}"
	end
	
	if( ${?be_verbose} ) then
		cat "${index}";
		printf "\n\n";
	endif
	
	if( ${?refetch} ) then
		cp "${index}" "${index}.tmp"
		ex '+1,$s/[\r\n]\+//g' '+wq' "${index}.tmp" >& /dev/null
		rm  "${index}.tmp"
	endif
end

exit

usage:
	printf "Usage| %s [--verbose] [--title(default)|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit

