#!/bin/tcsh -f

setenv PATH "${PATH}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d"

setenv EDITOR "/usr/bin/vim-enhanced"

if ( "${?cdpath}" == "0" ) set cdpath="/etc:/usr/share"
set cdpath="${cdpath}:/projects/gtk:/projects/cli:/projects/www:/projects/games:/projects/media:/profile.d:/media:/media/media-library:."

alias jobs "jobs -l"

complete tar 'p/*/f/'

complete pidof 'p/*/c/'
alias pidof "pidof -x"

complete kill 'p/*/c/'
complete killall 'p/*/c/'

complete ln 'p/*/f/'

foreach rc_file ( /profile.d/tcshrc/*.tcsh )
	switch("${rc_file}")
	case "bindkey.tcsh":
	case "complete.tcsh":
		breaksw
	default:
		source "${rc_file}"
		breaksw
	endsw
end
unset rc_file

setenv PATH "${PATH}:."
