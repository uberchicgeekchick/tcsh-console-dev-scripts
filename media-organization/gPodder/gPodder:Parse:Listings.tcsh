#!/bin/tcsh -f
if ( "${?1}" == "0" || "${1}" == "" || "${1}" == "--help" ) goto usage;
unsetenv GREP_OPTIONS;

set action = "display";
while ( "${?1}" != "0" && "${1}" != "" )
	printf "\n";
	switch ( "${1}" )
	case "--add":
	case "--subscribe":
		shift;
		set action="add";
		breaksw
	case "--del":
	case "--delete":
	case "--unsubscribe":
		shift;
		set action="delete";
		breaksw
	case "--display":
		set action="display";
		shift;
		breaksw
	default:
		set action="display";
		breaksw
	endsw
	
	set attrib = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`";
	set value = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`";
	shift;
	if ( "${attrib}" == "" ) continue;
	
	set values;
	switch ( "${attrib}" )
	case "title":
	case "htmlUrl":
	case "text":
	case "description":
		if ( "${action}" == "add" ) then
			printf "Only xmlUrl(s) can be added/subscribed to.";
			continue;
		endif
	case "xmlUrl":
		if ( ! -e "${value}" ) then
			set values = ( "${value}" );
		else
			foreach value ( "`cat '${value}'`" )
				set values = ( ${values}"${value}\n" );
			end
		breaksw
	default:
		printf "\t%s is not supported.\n\tSupported options are --[title|xmlUrl|htmlUrl|text|description]="\""[a regex, or file containing regexes, one per line, to search for]"\""\n\tFor more information see %s --help\n" "${attrib}" `basename "${0}"`
		continue;
		breaksw
	endsw
	
	foreach value ( "`printf '${values}\n'`" )
		printf "\n";
		printf "\nSearching for %s: %s\n\t\t\t" "${attrib}" "${value}";
		set found_podcast = "FALSE";
		foreach podcast ( "`/usr/bin/grep -i --perl-regex -e '${attrib}=["\""'\''].*${value}.*["\""'\'']' '${HOME}/.config/gpodder/channels.opml'| sed 's/\(["\""'\'']\)/\1\\\1\1/g'`" )
			set title = "`printf '${podcast}' | sed 's/[\\"\""]\+/"\""/g' | sed 's/.*title=["\""]\([^"\""]\+\)["\""].*/\1/' | sed 's/\(&\)amp;/\1/g'`";
			set text = "`printf '${podcast}' | sed 's/[\\"\""'\'']\+/"\""/g' | sed 's/.*text=["\""]\([^"\""]\+\)["\""].*/\1/' | sed 's/\(&\)amp;/\1/g'`";
			set xmlUrl = "`printf '${podcast}' | sed 's/[\\"\""]\+/"\""/g' | sed 's/.*xmlUrl=["\""]\([^"\""]\+\)["\""].*/\1/' | sed 's/\(&\)amp;/\1/g'`";
			if ( "${title}" != "" && "${text}" != "" && "${xmlUrl}" != "" ) then
				#printf "\t%s: %s ( %s )\t[found]\n" "${title}" "${xmlUrl}" "${text}";
				if ( "${found_podcast}" == "FALSE" ) set found_podcast = "TRUE";
			endif
			
			switch( "${action}" )
			case "delete":
				printf "[unsubscribing from this podcast]\n";
				#gpodder --del="${xmlUrl}";
				breaksw
			default:
				printf "[you're subscribed to this podcast]\n";
			endsw
		end
		
		if ( "${found_podcast}" == "TRUE" ) continue;
		
		switch( "${action}" )
		case "add":
			printf "[subscribing to this podcast]\n";
			#gpodder --add="${value}";
			breaksw
		case "display":
		default:
			printf "[you're not subscrided to this podcast]\n";
			breaksw
		endsw
	end
end

exit;

usage:
	printf "Usage: %s [--help] [\n\t-f, --find, --search(default)\t\t search to see if you are subscribed to any podcasts matching the term.\n\t-d --del,--delete,--unsubscribe\t\t---add, --subscribe]\tonly valid if your using xmlUrl(s), this will subscribe you to the specified xmlUrl\n\t\t--[title|xmlUrl|htmlUrl|text|description]="\""[a regex, or file containing regexes, one per line, to search for, add, or delete]"\""\n" "`basename '${0}'`";
	exit;
