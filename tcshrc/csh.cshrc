#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "csh.cshrc" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

if( ${?TCSHRC_DEBUG} ) printf "Loading csh.cshrc @ %s.\n" `date "+%I:%M:%S%P"`;

if(! ${?prompt} ) source "${TCSH_RC_SESSION_PATH}/prompts.cshrc.tcsh";
if( ${?echo} ) unset echo;

if( ${?http_proxy} ) unsetenv http_proxy;

set logout=normal;

set highlight
set implicitcd

set cdpath="/projects/gtk:/projects/cli:/projects/www:/projects/games:/projects/media:/projects/cli/profile.d:/media:/media/library:.";

alias jobs "jobs -l";

#complete tar 'p/*/f/';

complete kill 'p/*/c/';
complete killall 'p/*/c/';

complete ln 'p/*/f/';

if( ${?1} && "${1}" != "" && "${1}" == "--disable=session:source" ) then
	if( ${?TCSRC_DEBUG} ) printf "[csh.cshrc]: by-passing loading of session:source @ %s.\n" `date "+%I:%M:%S%P"`;
	setenv TCSHRC_SESSION_SOURCE_SKIPPED;
	if( ${?2} ) shift;
else
	if( ${?TCSHRC_DEBUG} ) printf "Initalizing tcsh session @ %s.\n" `date "+%I:%M:%S%P"`;
	source "${TCSH_RC_SESSION_PATH}/session:source";
	if( ${?TCSHRC_SESSION_SOURCE_SKIPPED} ) unsetenv TCSHRC_SESSION_SOURCE_SKIPPED;
endif

if( ${?http_proxy} ) unsetenv http_proxy;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "csh.cshrc";
