#!/bin/tcsh -f
if( ${?1} && "${1}" != "" && "${1}" == "--debug" ) then
	shift;
	if(! ${?TCSH_RC_DEBUG} ) setenv TCSH_RC_DEBUG "`basename ${0}`";
endif

if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" == ".m3u" && -e "${1}" ) ) then
	printf "Usage: %s playlist.m3u [toxine/playlist/filename.tox]" "`basename '${0}'`";
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" != ".m3u" ) printf "\n\t**ERROR:** %s is not a valid m3u playlist." "${1}";
	exit -1;
endif
if( ! ${?eol} ) setenv eol '$';

if( ! ( ${?2} && "${2}" != "" && "`printf "\""${2}"\"" | sed 's/.*\(\.tcsh\)${eol}/\1/g'`" == ".tcsh" ) ) then
	set tcsh_shell_script="`printf "\""${1}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.m3u\)${eol}/\1\2\.tcsh/'`";
else
	set tcsh_shell_script="${2}";
endif
if( "${1}" == "${tcsh_shell_script}" ) then
	printf "Failed to generate tcsh script filename.";
	exit -1;
endif

printf "Converting %s to %s" ${1} ${tcsh_shell_script};
cp "${1}" "./.local.playlist.swp";

printf '#\!/bin/tcsh -f\nset old_podcast="";\n' >! "${tcsh_shell_script}";
ex -E -n -s -X "+2r ./.local.playlist.swp" '+wq!' "${tcsh_shell_script}";
ex -E -n -s -X '+3,$s/^\#.*[\r\n]//' '+3,$s/\(\/[^\/]\+\/[^\/]\+\/\)\(.*\)\([^\/]\+\)\/\(.*\)/if( ! -d "\1\2\3" ) mkdir "\1\2\3";\rif( ! -e "\1\2\3\/\4" ) then\r\tif( "${old_podcast}" != "\2\3" ) printf "\\nCopying %s'\''s:\\n\\t%s" "\2\3" "\4";\r\tif( "${old_podcast}" == "\2\3" ) printf "\\tCopying: %s" "\4";\r\tset old_podcast="\2\3";\r\tcp "\1nfs\/\2\3\/\4" "\1\2\3\/\4"\rprintf "\\n\\t\\t\\t[done]\\n";\rendif/' '+wq' "${tcsh_shell_script}";
#while( "`grep --binary-files=without-match --color --with-filename --line-number --initial-tab --perl-regexp ' "\""[^"\""]+"\""[^"\""]+"\"" ' '${tcsh_shell_script}'`" != "" )
#	set line_to_escape="`grep --binary-files=without-match --color --with-filename --line-number --initial-tab --perl-regexp ' "\""[^"\""]+"\""[^"\""]+"\"" ' '${tcsh_shell_script}' | sed --regexp-extended 's/[^:]+:[\ \t]*([0-9]+).*/\1/g'`";
#	if( ${?TCSH_RC_DEBUG} ) printf "\nescaping inner-quotes on line name: %d.\n" "${line_to_escape}";
#	ex -E -n -s -X  "+${line_to_escape}"'s/\( "[^"]\+\)"\([^"]\+" \)/\1"\\""\2/g' "+${line_to_escape}"'s/\( \"[^\\\"]\+\\\"[^"]\+\)\"\([^"]\+" \)/\1"\\""\2/g' '+wq' "${tcsh_shell_script}";
#end

rm "./.local.playlist.swp";
chmod u+x "${tcsh_shell_script}";

printf "\t[done]\n";
if( ${?TCSH_RC_DEBUG} ) then
	if( "${TCSH_RC_DEBUG}" == "`basename '${0}'`" ) unsetenv TCSH_RC_DEBUG;
endif

