#!/bin/tcsh -f

complete sudo "p/1/c/"

set sudo_commands = "visudo\ngdmsetup\nchown\nchgrp\nzypper\nneject\nreboot\npoweroff\nhalt\nmount\numount\n/srv/mysql/mysql.init.d"

set gnomesu_commands = "yast2"

foreach command ( `echo "${sudo_commands}"` )
	alias	"${command}"	"sudo ${command}"
end

foreach command ( `echo "${gnomesu_commands}"` )
	alias	"${command}"	"gnomesu ${command}"
end

foreach command ( `find /etc/init.d/ -maxdepth 1 -type f -perm -u=x` )
	alias	"${command}"	"sudo ${command}"
end

unset sudo_commands
unset gnomesu_commands
