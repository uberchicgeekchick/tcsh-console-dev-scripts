#!/bin/tcsh -f
if (! ${?1} || "${1}" == "" ) goto usage

while ( ${?1} && "${1}" != "" )
	set attribute = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`";
	set value = "";

	switch ( "${attribute}" )
	case "title":
	case "xmlUrl":
	case "htmlUrl":
	case "text":
	case "description":
		set value = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`";
		breaksw
	case "help":
		goto usage;
		breaksw
	default:
		set attribute = "title";
		set value = "${1}";
		breaksw
	endsw
	shift;

	if ( ${?1} ) then
		switch ( "${1}" )
		case "--output=title":
		case "--output=htmlUrl":
		case "--output=text":
		case "--output=description":
		case "--output=xmlUrl":
			shift;
			set output = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`";
			breaksw
		case "--help":
			shift;
			goto usage;
			breaksw
		default:
			set output = "xmlUrl";
			breaksw
		endsw
	else
		set output="xmlUrl"
	endif
											
	/usr/bin/grep -i --perl-regex -e "${attribute}=["\""'\''].*${value}.*["\""'\'']" "${HOME}/.config/gpodder/channels.opml" | sed "s/.*${output}=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/" | sed "s/\&amp;/\&/g"
	
end

exit

usage:
	printf "Usage| %s [--title|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit
