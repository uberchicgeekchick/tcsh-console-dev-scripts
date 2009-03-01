#!/bin/tcsh -f

setenv PATH "${PATH}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d"

setenv EDITOR "/usr/bin/vim-enhanced"

if (! ${?cdpath} ) set cdpath="/etc:/usr/share"
set cdpath="${cdpath}:/projects/gtk:/projects/cli:/projects/www:/projects/games:/projects/media:/profile.d:/media:/media/media-library:."

alias jobs "jobs -l"

#complete tar 'p/*/f/'

complete kill 'p/*/c/'
complete killall 'p/*/c/'

complete ln 'p/*/f/'

source /profile.d/tcshrc/sudo.tcsh
foreach rc_file ( /profile.d/tcshrc/*.tcsh )
	switch("${rc_file}")
	case "bindkey.tcsh":
	case "complete.tcsh":
	case "sudo.tcsh":
		breaksw
	default:
		source "${rc_file}"
		breaksw
	endsw
end
unset rc_file

setenv PATH "${PATH}:."
