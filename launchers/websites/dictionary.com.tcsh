#!/bin/tcsh -f
while( ${?1} && "${1}" != "" )
	set option="`printf '%s' '${1}' | sed -r 's/[\-]{2}(.*)/\1/'`";
	set value="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/^([\-]{2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?"\$"/\4/'`";
	if( "${value}" == "" && "${2}" != "" ) \
		set value="${2}";
	
	switch("${option}")
		case "h":
		case "help":
			goto usage;
			breaksw;
		
		case "firefox":
		case "links":
		case "lynx":
			set which_browser=" --${option}";
			breaksw;
		
		case "browser":
			foreach browser("`where '${value}'`")
				if( -x "${browser}" ) \
					break;
				unset browser;
			end
			breaksw;
		
		default:
			if(! ${?search_phrase} ) then
				set search_phrase="${1}";
			else
				set search_phrase="${search_phrase}%20${1}";
			endif
			breaksw;
	endsw
	shift;
end

if(! ${?browser} ) then
	if(! ${?TCSH_LAUNCHER_PATH} ) \
		setenv TCSH_LAUNCHER_PATH "${TCSH_RC_SESSION_PATH}/../launchers";
	
	if(! ${?which_browser} ) \
		set which_browser;
	
	set browser="${TCSH_LAUNCHER_PATH}/browser${which_browser}";
endif

launchers_main:
	set website="http://dictionary.reference.com/";
	if(! ${?search_phrase} ) then
		${browser} "${website}";
	else
		${browser} "${website}browse/${search_phrase}";
	endif
#launchers_main:


exit_script:
	exit ${status};
#exit_script

usage:
	printf "%s "\""[search phrase]"\" "`basename '${0}'`";
	goto exit_script;
#usage
