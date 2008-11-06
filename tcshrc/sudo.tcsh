#!/bin/tcsh -f

complete sudo "p/1/c/"

set sudo_commands = "visudo\ngdmsetup\nchown\nchgrp\nzypper\nneject\nreboot\npoweroff\nhalt\n/srv/mysql/mysql.init.d"


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
