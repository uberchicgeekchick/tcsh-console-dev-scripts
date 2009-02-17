#!/bin/tcsh -f

setenv PATH "${PATH}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d"

setenv EDITOR "/usr/bin/vim-enhanced"

if ( ! ${?cd_path} ) set cd_path="/etc:/usr/share"
set cd_path="${cd_path}:/projects/gtk:/projects/console:/projects/www:/projects/games:/projects/media:/profile.d:/media:/media/media-library:."

#print the expanded, completed, & corrected command line after is entered but before its executed.
#set echo
set addsuffix

set correct=all
set autoexpand
set autocorrect
set autolist
set color
set colorcat

set dextract
set dunique

set listjobs=long
set notify

set nobeep
set noclobber

set highlight
set histdup=erase
set histfile="/profile.d/history"
set history=1000
set savehist=( $history "merge" )
set histlit

set killdup=erase

set implicitcd
set rmstar

alias jobs "jobs -l"

complete tar 'p/*/f/'

complete pidof 'p/*/c/'
alias pidof "pidof -x"

complete kill 'p/*/c/'
complete killall 'p/*/c/'

complete ln 'p/*/f/'


set rc_path="/profile.d/tcshrc"
foreach rc_file ( ${rc_path}/*.tcsh )
	if ( -e "${rc_file}" ) source "${rc_file}"
end
unset rc_path
unset rc_file

setenv PATH "${PATH}:."
