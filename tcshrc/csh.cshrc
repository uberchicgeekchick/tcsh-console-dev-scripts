#!/bin/tcsh -f

#setenv TCSHRC_DEBUG "csh.cshrc";
source /projects/cli/tcshrc/debug:check csh.cshrc ${argv};
if( ${?TCSHRC_DEBUG} && ${?2} && "${2}" != "" ) shift;

if( ${?echo} ) unset echo;

if( ${?http_proxy} ) unsetenv http_proxy;

set logout=normal;

set highlight
set implicitcd

if(! ${?cdpath} ) set cdpath="/etc:/usr/share";
set cdpath="${cdpath}:/projects/gtk:/projects/cli:/projects/www:/projects/games:/projects/media:/projects/cli/profile.d:/media:/media/library:.";

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
	source /projects/cli/tcshrc/session:source;
	if( ${?TCSHRC_SESSION_SOURCE_SKIPPED} ) unsetenv TCSHRC_SESSION_SOURCE_SKIPPED;
endif

if( ${?http_proxy} ) unsetenv http_proxy;

source /projects/cli/tcshrc/debug:clean-up csh.cshrc;
