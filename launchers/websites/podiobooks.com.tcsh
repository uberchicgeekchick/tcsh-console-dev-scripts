#!/bin/tcsh -f
while( ${?1} && "${1}" != "" )
	switch("${1}")
		case "--firefox":
		case "--links":
		case "--lynx":
			set browser="`printf '%s' '${1}' | sed -r 's/[\-]{2}(.*)/\1/'`";
			shift;
			breaksw;
		default:
			if( ! ${?browser} && "`printf '%s' '${1}' | sed -r 's/[\-]{2}(browser)=(.*)/\1/'`" == "browser" ) then
				set exec_test="`printf '%s' '${1}' | sed -r 's/[\-]{2}browser=(.*)/\1/'`";
				foreach browser("`where '${exec_test}'`")
					if( ${?exec_test} ) unset exec_test;
					if( -x "${browser}" ) then
						shift;
						breaksw;
					endif
				end
				if( ${?browser} ) unset browser;
			endif
			
			if( ${?books_title} ) then
				set books_title="${books_title}%20${1}";
			else
				set books_title="${1}";
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
	if(! ${?books_title} ) set books_title="";
	if( "${books_title}" == "" ) then
		set status=-1;
		goto usage;
	endif
#launchers_main

${program} "http://www.podiobooks.com/title/${books_title}/feed/";

exit_script:
	exit ${status};
#exit_script

usage:
	printf "%s "\""[search phrase]"\" "`basename '${0}'`";
	goto exit_script;
#usage
