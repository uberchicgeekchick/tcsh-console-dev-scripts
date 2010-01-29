#!/bin/tcsh -f
if( ${?1} && "${1}" != "" && "${1}" == "--debug" ) then
	shift;
	if(! ${?TCSH_RC_DEBUG} ) setenv TCSH_RC_DEBUG "`basename ${0}`";
endif

if(! ${?TCSH_RC_DEBUG} ) set TCSH_RC_DEBUG="";

if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" == ".m3u" && -e "${1}" ) ) then
	printf "Usage: %s playlist.m3u [toxine/playlist/filename.tox]" "`basename '${0}'`";
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" != ".m3u" ) printf "\n\t**ERROR:** %s is not a valid m3u playlist." "${1}";
	exit -1;
endif
if(! ${?eol} ) setenv eol '$';

if(!( ${?2} && "${2}" != "" && ( "`printf "\""${2}"\"" | sed 's/.*\(\.tcsh\)${eol}/\1/g'`" == ".tcsh" || "${2}" == "--enable=auto-copy" ) )) then
	set tcsh_shell_script="`printf "\""${1}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.m3u\)${eol}/\1\2\.tcsh/'`";
else if( "${2}" == "--enable=auto-copy" ) then
	set auto_copy;
	set tcsh_shell_script=".copy-local-@-`date '+%s'`";
else
	set tcsh_shell_script="${2}";
endif
if( "${1}" == "${tcsh_shell_script}" ) then
	printf "Failed to generate tcsh script filename.";
	exit -1;
endif

if(! ${?auto_copy} ) then
	printf "Converting %s to %s" "${1}" "${tcsh_shell_script}";
else
	printf "Preparing to copy contents of %s" "${1}";
endif

/bin/cp "${1}" "./.local.playlist.swp";

printf '#\!/bin/tcsh -f\nset old_podcast="";\n' >! "${tcsh_shell_script}";
chmod u+x "${tcsh_shell_script}";
ex -E -n -s -X "+2r ./.local.playlist.swp" '+wq!' "${tcsh_shell_script}";
ex -E -n -s -X '+3,$s/^\#.*[\r\n]*//' '+3,$s/^[^\/].*[\r\n]*//' '+3,$s/\([\!]\)/\\\1/g' '+3,$s/"/"\\""/g' '+wq!' "${tcsh_shell_script}";
ex -E -n -s -X '+3,$s/\(\/[^\/]\+\/[^\/]\+\/\)\(.*\)\([^\/]\+\)\/\(.*\)/if( -e "\1nfs\/\2\3\/\4" ) then\r\tif( ! -d "\1\2\3" ) mkdir -p "\1\2\3";\r\tif( ! -e "\1\2\3\/\4" ) then\r\t\tif( "${old_podcast}" != "\2\3" ) then\r\t\t\tprintf "\\nCopying: %s'\''s content(s):" "\2\3";\r\t\t\tset old_podcast="\2\3";\r\tendif\r\t\tprintf "\\n\\tCopying: %s" "\4";\r\t\tcp "\1nfs\/\2\3\/\4" "\1\2\3\/\4"\r\t\tprintf "\\n\\t\\t\\t[done]\\n";\r\tendif\rendif\r/' '+wq' "${tcsh_shell_script}";

printf "\t[done]\n";

if( ${?auto_copy} ) then
	printf "\nCopying nfs files to local directory.\n";
	./"${tcsh_shell_script}";
endif

if( "${TCSH_RC_DEBUG}" != "`basename '${0}'`" ) then
	unset TCSH_RC_DEBUG;
	/bin/rm ./"${tcsh_shell_script}";
else
	unsetenv TCSH_RC_DEBUG;
endif

