#!/bin/tcsh -f
if( ${?CSHRC_DEBUG} || "${1}" == "--verbose" ) setenv CSHRC_DEBUG;

if( ${?http_proxy} ) unsetenv http_proxy
if ( ${?PATH} ) unsetenv PATH

setenv PATH "/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d"

setenv EDITOR "/usr/bin/vim-enhanced"

set logout=normal

if (! ${?cdpath} ) set cdpath="/etc:/usr/share"
set cdpath="${cdpath}:/projects/gtk:/projects/cli:/projects/www:/projects/games:/projects/media:/profile.d:/media:/media/library:."

alias jobs "jobs -l"

#complete tar 'p/*/f/'

complete kill 'p/*/c/'
complete killall 'p/*/c/'

complete ln 'p/*/f/'


source /profile.d/tcshrc/source:session

setenv PATH "${PATH}:."

if( ${?http_proxy} ) unsetenv http_proxy
