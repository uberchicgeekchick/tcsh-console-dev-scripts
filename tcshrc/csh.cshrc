#!/bin/tcsh -f
setenv SUDO_PROMPT "please verify your password:"

setenv PATH "${PATH}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d"

setenv EDITOR "/usr/bin/vim"

if ( ! ${?cd_path} ) set cd_path = "/etc:/usr/share"
set cd_path = "${cd_path}:/projects/gtk:/projects/console:/projects/www:/profile.d:/media"

set listjobs
set notify

#set nobeep
set noclobber

set ellipsis
set prompt = "\n%B%{^[[105m%}(%p on %Y-%W-%D)\n%{^[[35m%}[ %m %n ]\n%{^[[31m%}@%c3/%{^[[35m%}# "

set colorcat

set correct=cmd
alias jobs "jobs -l"

complete ln "p/*/f/"
complete tar "p/*/f/"

complete pidof "p/*/c/"
alias pidof "pidof -x"

complete kill "p/*/c/"
complete killall "p/*/c/"

set rc_path = "/projects/console/tcshrc"

foreach rc_file ( ${rc_path}/*.tcsh )
	if ( -e "${rc_file}" ) source "${rc_file}"
end

unset rc_path
unset rc_file

setenv PATH "${PATH}:."
