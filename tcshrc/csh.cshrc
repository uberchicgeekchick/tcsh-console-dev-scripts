#!/bin/tcsh -f
setenv SUDO_PROMPT "please verify your password:"

setenv PATH "${PATH}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d"

setenv EDITOR "/usr/bin/vim"

if ( ! ${?cd_path} ) set cd_path = "/etc:/usr/share"
set cd_path = "${cd_path}:/projects/gtk:/projects/console:/projects/www:/projects/games:/projects/media:/profile.d:/media:/media/media-library"

set listjobs
set notify

set nobeep
set noclobber

set highlight
set histdup = erase
set histfile = "/profile.d/history"
set history = 1000
set savehist = ( "1000" "merge" )
set histlit

set implicitcd

set correct=cmd
set autolist
set color
set colorcat

alias jobs "jobs -l"

complete ln "p/*/f/"
complete tar "p/*/f/"

complete pidof "p/*/c/"
alias pidof "pidof -x"

complete kill "p/*/c/"
complete killall "p/*/c/"


set rc_path = "/profile.d/tcshrc"
foreach rc_file ( ${rc_path}/*.tcsh )
	if ( -e "${rc_file}" ) source "${rc_file}"
end
unset rc_path
unset rc_file

setenv PATH "${PATH}:."
