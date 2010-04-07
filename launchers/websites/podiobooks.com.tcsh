#!/bin/tcsh -f
while( ${?1} && "${1}" != "" )
	set option="`printf '%s' '${1}' | sed -r 's/[\-]{2}(.*)/\1/'`";
	set value="`printf "\""${1}"\"" | sed -r 's/^([\-]{2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\4/'`";
	if( "${value}" == "" && "${2}" != "" )	\
		set value="${2}";
	
	switch("${option}")
		case "firefox":
		case "links":
		case "lynx":
			set browser="${option}";
			breaksw;
		
		case "browser":
			foreach browser("`where '${value}'`")
				if( -x "${browser}" )	\
					break;
				unset browser;
			end
			breaksw;
		
		default:
			if( ${?search_phrase} ) then
				set search_phrase="${search_phrase}+${1}";
			else
				set search_phrase="${1}";
			endif
			shift;
			breaksw;
	endsw
end

if(! ${?browser} ) then
	if( "${TERM}" == "gnome" ) then
		set browser="firefox";
	else
		set browser="links"
	endif
endif

if( -x "${browser}" ) then
	set program="${browser}";
else
	foreach program ( "`which '${browser}'`" )
		if( "${program}" != "${0}" && -x "${program}" ) break;
		unset program;
	end
endif

if(! ${?program} ) goto noexec;
if(! -x "${program}" ) goto noexec;
goto launchers_main;

noexec:
	printf "Unable to find %s.\n" "${browser}";
	if( ${?program} ) unset program;
	unset browser;
	set status=-1;
	goto exit_script;
#noexec


launchers_main:
	set website="http://www.podiobooks.com/";
	curl --location --fail --show-error --silent --output "./.index.html" "${website}/podiobooks/search.php?keyword=${search_phrase}";
	if( -e "./.feed.xml" ) then
		rm ./.feed.xml;
		${program} "${website}title/${search_phrase}/";
	else if( ${?search_phrase} ) then
		${program} "${website}/podiobooks/search.php?keyword=${search_phrase}";
	else
		${program} "${website}";
	endif
#launchers_main:


exit_script:
	exit ${status};
#exit_script

usage:
	printf "%s "\""[search phrase]"\" "`basename '${0}'`";
	goto exit_script;
#usage
