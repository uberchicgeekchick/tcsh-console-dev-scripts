#!/bin/tcsh -f
if( ! ${?SSH_CONNECTION} && ${?1} && "${1}" != "" && "${1}" == "--debug" ) setenv TCSHRC_DEBUG;

if( -x "/usr/bin/ghb" ) then
	alias	handbrake	"/usr/bin/ghb"
	alias	HandBrake	"handbrake"
	alias	HandBrakeGTK	"handbrake"
	alias	HandBrakeGUI	"handbrake"
endif

if( -x "/usr/bin/id3v2" ) alias	mp3info	"id3v2 --list"

if(!(${?DEBUG_EXEC})) then
	setenv output " >& /dev/null &";
else
	setenv output " &";
endif

set launchers_path="/projects/cli/launchers";
foreach launcher ( "`find ${launchers_path} -type f -perm '/u=x' -printf '%f\n'`" )
	if( "${launcher}" == "template" ) continue;
	
	if( "`echo ${launcher} | sed 's/.*\(\.init\)${eol}/\1/g'`" == ".init" ) then
		if( ${?TCSHRC_DEBUG} ) printf "Setting up alias(es) for: %s.\n\tSourcing %s/%s @ %s.\n" ${launcher} ${launchers_path} ${launcher} `date "+%I:%M:%S%P"`;
		source ${launchers_path}/${launcher};
		if( ${?TCSHRC_DEBUG} ) printf "[done]\n";
	else
		if( ${?TCSHRC_DEBUG} ) printf "Aliasing [%s] to [%s/%s] @ %s.\n" $launcher $cwd $launcher `date "+%I:%M:%S%P"`;
		alias "${launcher}" "${launchers_path}/${launcher}";
	endif
end

if( ${?sed_regexp_set} ) then
	unalias sed;
	unset sed_regexp_set;
endif

unsetenv output

