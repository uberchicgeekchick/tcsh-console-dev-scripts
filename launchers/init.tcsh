#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/tcshrc";
set source_file="aliases:launchers.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${source_file}" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled source_file;
if( ${?TCSHRC_DEBUG} ) printf "Loading aliases.launchers.tcsh @ %s.\n" `date "+%I:%M:%S%P"`;

if(! ${?eol} ) setenv eol '$';

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
set starting_directory="${cwd}";
cd "${launchers_path}";
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
cd "${starting_directory}";

if( ${?sed_regexp_set} ) then
	unalias sed;
	unset sed_regexp_set;
endif

unsetenv output

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "aliases:launchers.tcsh";
