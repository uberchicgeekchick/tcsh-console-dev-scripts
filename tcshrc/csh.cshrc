#!/bin/tcsh -f

#setenv TCSHRC_DEBUG;
if( ! ${?SSH_CONNECTION} && ! ${?TCSHRC_DEBUG} && ${?1} && "${1}" != "" && "${1}" == "--debug" ) then
	printf "[csh.cshrc]: enabling verbose debugging output @ %s.\n" `date "+%I:%M:%S%P"`;
	setenv TCSHRC_DEBUG;
endif

if( ${?SSH_CONNECTION} && ${?TCSHRC_DEBUG} ) unsetenv TCSHRC_DEBUG;

unalias sed;

if( ${?echo} ) unset echo;

if( ${?http_proxy} ) unsetenv http_proxy;
if( ${?PATH} ) unsetenv PATH;

setenv PATH ".:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d";

setenv EDITOR "/usr/bin/vim-enhanced";

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


if( ${?TCSHRC_DEBUG} ) printf "Initalizing tcsh session @ %s.\n" `date "+%I:%M:%S%P"`;

if( ! ${?UBERCHICK_TSCHRC_BYPASS_SESSION} && 
source /projects/cli/tcshrc/session:source;

if( ${?http_proxy} ) unsetenv http_proxy;


