#!/bin/tcsh -f

complete sudo "p/1/c/"

set sudo_commands = "visudo gdmsetup chown chgrp zypper neject reboot poweroff halt mount umount init /srv/mysql/mysql.init.d esound eject NetworkManager"


foreach command ( `echo "${sudo_commands}"` )
	alias	"${command}"	"sudo ${command}"
end
unset sudo_commands

set gnomesu_commands = "yast2"
foreach command ( `echo "${gnomesu_commands}"` )
	alias	"${command}"	"gnomesu ${command}"
end
unset gnomesu_commands

foreach command ( `find -L /etc/init.d/ -maxdepth 1 -type f -perm -u=x` )
	alias	"${command}"	"sudo ${command}"
	complete "${command}" "p/1/(start|stop|restart|status)/"
end

unset command
