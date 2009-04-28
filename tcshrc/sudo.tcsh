#!/bin/tcsh -f

complete sudo "p/1/c/"

set sbin_paths=( "/sbin" "/usr/sbin" )
foreach sbin_path ( ${sbin_paths} )
	foreach command ( ${sbin_path}/* )
		set cmd_alias=`basename ${command}`
		alias "${cmd_alias}" "sudo ${command}"
	end
end
unset sbin_path sbin_paths cmd_alias

foreach command ( `find -L /etc/init.d/ -maxdepth 1 -type f -perm -u=x` )
	alias	"${command}"	"sudo ${command}"
	complete "${command}" "p/1/(start|stop|restart|status)/"
end


set sudo_commands=( "visudo" "chown" "chgrp" "zypper" "neject" "reboot" "poweroff" "halt" "mount" "umount" "init" "/srv/mysql/mysql.init.d" "esound" "eject" "NetworkManager" "yast" );
foreach command ( ${sudo_commands} )
	alias	"${command}"	"sudo ${command}"
end
unset sudo_commands command

set gnomesu="/usr/bin/gnomesu"
set yast_commands=( "/sbin/yast" "yast" );
foreach command ( ${yast_commands} )
	alias	"${command}"	"${gnomesu} ${command}2"
end
unset yast_commands

set gnomesu_commands=( "/sbin/yast2" "yast2" );
set gnomesu="/usr/bin/gnomesu"
foreach command ( ${gnomesu_commands} )
	alias	"${command}"	"${gnomesu} ${command}"
end
unset gnomesu gnomesu_commands command

