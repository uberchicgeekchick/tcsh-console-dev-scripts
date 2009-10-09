#!/bin/tcsh -f
if(! ${?1} || "${1}" == "" ) goto usage

while ( ${?1} && "${1}" != "" )
	set verbose_output="FALSE";
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
	
	if( ${?1} ) then
		switch ( "${1}" )
		case "--enable=verbose":
			shift;
			set verbose_output="TRUE";
			breaksw
		case "--disable=verbose":
			shift;
			set verbose_output="FALSE";
			breaksw
		case "--output=title":
		case "--output=htmlUrl":
		case "--output=text":
		case "--output=description":
		case "--output=xmlUrl":
			set output = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`";
			shift;
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
		set output="xmlUrl";
	endif
	
	if(!(${?output})) set output="xmlUrl";
	
	foreach outline ( "`/usr/bin/grep --line-number -i --perl-regex -e '${attribute}=["\""].*${value}.*["\""]' '${HOME}/.config/gpodder/channels.opml'`" )
		echo "${outline}" | sed "s/.*${output}=["\""]\([^"\""]\+\)["\""].*/\1/" | sed "s/\&amp;/\&/g";
		if( "${verbose_output}" == "TRUE" ) echo "${outline}";
	end
	
end

exit

usage:
	printf "Usage| %s [--title|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit
