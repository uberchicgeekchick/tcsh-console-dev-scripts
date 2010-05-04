#!/bin/tcsh -f
if( ${?1} && "${1}" != "" && "${1}" == "--debug" ) then
	shift;
	if(! ${?TCSH_RC_DEBUG} ) \
		setenv TCSH_RC_DEBUG "`basename ${0}`";
endif

if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)"\$"/\1/'`" == ".tox" && -e "${1}" ) ) then
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)"\$"/\1/'`" != ".tox" ) \
		printf "\n\t**ERROR:** %s is not a valid m3u playlist.\n" "${1}";
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

alias	ex	"ex -E -n -X --noplugin";

/bin/cp "${1}" "./.local.playlist.swp";
ex -s '+1,$s/^\tmrl\ =\ \(\/[^\/]\+\/[^\/]\+\/\)\(.*\)\/\([^\/]\+\)\.\([^\.]\+\);$/\1\2\/\3\.\4/' '+wq!' "./.local.playlist.swp";
ex -s '+1,$s/^[^\/].*\n//' '+1,$s/\([\"\$\!]\)/\"\\\1\"/g' '+wq!' "./.local.playlist.swp";

printf '#\!/bin/tcsh -f\nset old_podcast="";\nset echo_style=both;\n' >! "${tcsh_shell_script}";
chmod u+x "${tcsh_shell_script}";
ex -s "+3r ./.local.playlist.swp" '+wq!' "${tcsh_shell_script}";
/bin/rm "./.local.playlist.swp";

ex '+4,$s/\v^(\/[^\/]+\/[^\/]+\/)(.*)\/(.*)(\..*)$/if\(\! -e "\1\2\/\3\4" \) then\r\tif\(\! -e "\1nfs\/\2\/\3\4" \) then\r\t\techo -n "**error coping:** remote file \<\1nfs\/\2\/\3\4\> doesn'\''t exists.\n" \> \/dev\/stderr;\r\telse\r\t\tif\(\!  -d "\1\2" \) mkdir -p "\1\2";\r\t\tif\( "${old_podcast}" \!\=   "\2" \) then\r\t\t\tset old_podcast\="\2";\r\t\t\techo -n "\\nCopying: ${old_podcast}'\''s content(s):";\r\t\tendif\r\t\techo -n "\\n\\tCopying: \3\4";\r\t\tcp "\1nfs\/\2\/\3\4" "\1\2\/\3\4";\r\t\techo -n "\\t[done]\\n";\r\tendif\rendif\r/' '+w' "${tcsh_shell_script}";

printf "\t[done]\n";

if( ${?auto_copy} ) then
	printf "\nCopying nfs files to local directory.\n";
	"${tcsh_shell_script}";
	/bin/rm "${tcsh_shell_script}";
endif

if( ${?TCSH_RC_DEBUG} ) then
	if( "${TCSH_RC_DEBUG}" == "`basename '${0}'`" ) \
		unsetenv TCSH_RC_DEBUG;
endif

