#!/bin/tcsh -f
if( ${?1} && "${1}" != "" && "${1}" == "--debug" ) then
	shift;
	if(! ${?TCSH_RC_DEBUG} ) setenv TCSH_RC_DEBUG "`basename ${0}`";
endif

if(! ${?TCSH_RC_DEBUG} ) set TCSH_RC_DEBUG="";

if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)"\$"/\1/'`" == ".tox" && -e "${1}" ) ) then
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)"\$"/\1/'`" != ".tox" ) printf "\n\t**ERROR:** %s is not a valid m3u playlist.\n" "${1}";
	printf "Usage: %s playlist.tox (e.g. ~/media/playlist/toxine.tox)\n" "`basename '${0}'`";
	set status=-1;
	exit ${status};
endif

if(!( ${?2} && "${2}" != "" && ( "`printf "\""${2}"\"" | sed 's/.*\(\.tcsh\)"\$"/\1/g'`" == ".tcsh" || "${2}" == "--enable=auto-copy" ) )) then
	set tcsh_shell_script="`printf "\""${1}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.tox\)"\$"/\1\2\.tcsh/'`";
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

alias	ex	"ex -E -n -s -X --noplugin";

printf '#\!/bin/tcsh -f\nset old_podcast="";\n' >! "${tcsh_shell_script}";
chmod u+x "${tcsh_shell_script}";

/bin/cp "${1}" "./.local.playlist.swp";
ex "+2r ./.local.playlist.swp" '+wq!' "${tcsh_shell_script}";
/bin/rm "./.local.playlist.swp";

ex '+3d'"+2,"\$"s/^entry\ {[\r\n]\+//" "+2,"\$"s/^};"\$"//" "+2,"\$"s/^\tmrl\ =\ \(\/[^\/]\+\/[^\/]\+\/\)\(.*\)\/\([^\/]\+\)\.\([^\.]\+\);"\$"/\1\2\/\3\.\4/" "+2,"\$"s/^\t.*;[\r\n]\+//" "+1,"\$"s/^[\r\n]\+//"  '+wq!' "${tcsh_shell_script}";
ex '+3,$s/^\#.*[\r\n]*//' '+3,$s/^[^\/].*[\r\n]*//' '+3,$s/\([\!]\)/\\\1/g' '+3,$s/"/"\\""/g' '+wq!' "${tcsh_shell_script}";
ex '+3,$s/\(\/[^\/]\+\/[^\/]\+\/\)\(.*\)\([^\/]\+\)\/\(.*\)/if(! -e "\1nfs\/\2\3\/\4" ) then\r\t\tprintf "**error coping:** remote file <%s> doesn'\''t exists." "\1nfs\/\2\3\/\4" > \/dev\/stderr;\r\telse\r\tif(! -d "\1\2\3" ) mkdir -p "\1\2\3";\r\tif(! -e "\1\2\3\/\4" ) then\r\t\tif( "${old_podcast}" != "\2\3" ) then\r\t\t\tprintf "\\nCopying: %s'\''s content(s):" "\2\3";\r\t\t\tset old_podcast="\2\3";\r\tendif\r\t\tprintf "\\n\\tCopying: %s" "\4";\r\t\tcp "\1nfs\/\2\3\/\4" "\1\2\3\/\4"\r\t\tprintf "\\n\\t\\t\\t[done]\\n";\r\tendif\rendif\r/' '+wq' "${tcsh_shell_script}";

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

