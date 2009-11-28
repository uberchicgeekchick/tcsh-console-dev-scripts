#!/bin/tcsh -f
if(! ${?1} || "${1}" == "" ) goto usage

while ( ${?1} && "${1}" != "" )
	while(! ${?value} )
		set verbose_output="FALSE";
		set attribute = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`";
		set attributes_value = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`";
		
		switch ( "${attribute}" )
		case "title":
		case "xmlUrl":
		case "htmlUrl":
		case "text":
		case "description":
			set value="${attributes_value}";
			shift;
			breaksw
		case "help":
			shift;
			goto usage;
			breaksw
		case "enable":
			switch ( "${attributes_value}" )
			case "verbose":
				shift;
				set verbose_output="TRUE";
				breaksw
			endsw
			breaksw
		case "disable":
			switch( "${attributes_value}" )
			case "verbose":
				shift;
				set verbose_output="FALSE";
				breaksw
			endsw
			breaksw
		case "output":
			switch( "${attributes_value}" )
			case "title":
			case "htmlUrl":
			case "text":
			case "description":
			case "xmlUrl":
				set output="${attributes_value}";
				shift;
				breaksw
			endsw
			breaksw
		endsw
	end
	
	if(!( ${?attribute} && ${?value} )) then
		set attribute="title";
		set value="${1}";
	endif

	if(!(${?output})) set output="xmlUrl";
	
	foreach outline ( "`/usr/bin/grep --line-number -i --perl-regex -e '${attribute}=["\""].*${value}.*["\""]' '${HOME}/.config/gpodder/channels.opml'`" )
		echo "${outline}" | sed "s/.*${output}=["\""]\([^"\""]\+\)["\""].*/\1/" | sed "s/\&amp;/\&/g";
		if( "${verbose_output}" == "TRUE" ) echo "${outline}";
	end
	unset outline attribute attributes_value output value;
	if( ${?verbose_output} ) unset verbose_output;
end

exit

usage:
	printf "Usage| %s [--title|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit
