#!/bin/tcsh -f
if(! ${?0} ) then
	printf "**error:** This script cannot be sourced." > /dev/stderr;
	exit -1;
endif

if(!( ${?1} && "${1}" != "" && "${1}" != "--help")) then
	goto usage
endif
unsetenv GREP_OPTIONS;
	
	set opml_attribute="xmlUrl";
	@ arg=0;
	@ argc=${#argv};

next_option:
	if( "${opml_attribute}" != "xmlUrl" ) \
		set opml_attribute="xmlUrl";
	if( ${?opml} ) \
		unset opml;
	if( ${?opml} ) \
		unset opml;
	if( ${?actions} ) \
		unset actions;
while( ${?1} && "${1}" != "" )
	if( ${?debug} ) \
		printf "Parsing "\$"argv[%d]: [%s]\n" $arg "${1}";
	set option="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)/\1/g'`";
	set equals="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)/\2/g'`";
	set value="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)/\3/g'`";
	
	if( "${value}" == "" && "${equals}" == "" && "${2}" != "" && -e "${2}" ) then
		set value="${2}";
		shift;
	endif
	if( ${?debug} ) \
		printf "Parsed: "\$"argv[%d]: [%s%s%s]\n" $arg "${option}" "${equals}" "${value}";
	
	shift;
	switch ( "${option}" )
		case 'h':
		case "help":
			goto usage;
		
		case "debug":
			set debug;
			breaksw;
		
		case "exec":
		case "command":
			set exec="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/^([^ ]+) (.*)"\$"/\1/'`";
			set actions="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/^([^ ]+) (.*)"\$"/\2/'`";
			breaksw;
		
		case "actions":
		case "options":
		case "arguments":
		case "switchs":
			set actions="--${value} ";
			breaksw;
		
		case "title":
		case "xmlUrl":
		case "type":
		case "text":
		case "htmlUrl":
		case "description":
			set opml_attribute="${option}";
			breaksw;
			
		case "fetch":
			set message="Fetching:";
			if( "`where "\""feed:fetch:enclosures.tcsh"\""`" != "" ) then
				set exec="feed:fetch:enclosures.tcsh";
			else
				set exec="alacast:feed:fetch:enclosures.tcsh";
			endif
			set actions="--disable=logging --xmlUrl=";
			breaksw;
		
		case "del":
		case "delete":
		case "unsubscribe":
			set message="Deleting:";
			set exec="gpodde";
			set actions="--del=";
			breaksw;
		
		case "add":
		case "subscribe":
			set message="Adding:";
			set exec="gpodder";
			set actions="--add=";
			if( -e "${value}" ) \
				set opml="${value}";
			breaksw;
		
		case "opml":
			if( -e "${value}" ) \
				set opml="${value}";
			breaksw;
		
		default:
			printf "%s is not supported\t\t[skipped]\n" `printf "%s" "${option}" | sed -r 's/[e]?$/ing/'`;
			goto exit_script;
	endsw
	
	if(!( ${?opml} && ${?exec} )) then
		continue;
	else if(! ${?outlines_processed} ) then
		@ outlines_processed=0;
	endif
	
	printf "\n\t<%s>s from: <%s> will be passed to: [%s]\n" "$opml_attribute" "$opml" "$exec";
	
	foreach podcast("`grep -P -i '^[\t\ \s]+<outline.*${opml_attribute}=["\""'\''][^"\""'\'']+["\""]' "\""${opml}"\"" | sed --regexp-extended 's/^[\ \s\t]+<outline.*${opml_attribute}=["\""'\'']([^"\""'\'']+)["\""'\''].*/\1/ig'`")
		@ outlines_processed++;
		if( ${?message} ) then
			printf "%s\t <%s>\n\t\t\t" "${message}" "${podcast}";
		endif
		( ${exec} ${actions}"${podcast}" > /dev/tty ) >& /dev/stderr;
		if( "${status}" == "0" ) then
			printf "[succeeded]";
		else
			printf "[failed]";
		endif
		printf "\n";
	end
	unset opml;
end

exit 0;

usage:
	printf "Usage: %s --command|exec='command to run' --[add,subscribe,unsubscribe,delete(implies the use of gpodder-0.11.3-hacked as the command) ( (--title|xmlUrl|type|text|htmlUrl|description(option:  which attribute to pass to the command. default: xmlUrl)] [--opml]=OPML_file" "`basename "\""${0}"\""`";
	if(! ${?actions} ) \
		exit -1;
	goto next_option;
