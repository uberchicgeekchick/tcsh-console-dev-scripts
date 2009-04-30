#!/bin/tcsh -f
complete sudo "p/1/c/";

set sbin_paths=( "/sbin" "/usr/sbin" );
foreach sbin_path ( ${sbin_paths} )
	foreach command ( ${sbin_path}/* )
		set cmd_alias=`basename ${command}`;
		alias "${cmd_alias}" "sudo ${command}";
	end
end
unset sbin_path sbin_paths cmd_alias;

foreach service ( `find -L /etc/init.d/ -maxdepth 1 -type f -perm -u=x` )
	alias	"${service}"	"sudo ${service}";
	complete "${service}" "p/1/(start|stop|restart|status)/";
end
unset service;

set recursive_sudo_commands=( "chown" "chgrp" )
foreach recursive_sudo_command ( ${recursive_sudo_commands} )
	alias	"${recursive_sudo_command}"	"sudo ${recursive_sudo_command} -r";
end
unset recursive_sudo_command recursive_sudo_commands;

set sudo_commands=( "visudo" "zypper" "neject" "reboot" "poweroff" "halt" "mount" "umount" "init" "/srv/mysql/mysql.init.d" "esound" "eject" "NetworkManager" "yast" );
foreach sudo_command ( ${sudo_commands} )
	alias	"${sudo_command}"	"sudo ${sudo_command}";
end
unset sudo_command sudo_commands;

set gnomesu="/usr/bin/gnomesu";
set yast_commands=( "yast" );
foreach yast_command ( ${yast_commands} )
	alias	"${yast_command}"	"${gnomesu} ${yast_command}2";
end
unset yast_command yast_commands;

set gnomesu_commands=( "yast2" );
foreach gnomesu_command ( ${gnomesu_commands} )
	alias	"${gnomesu_command}"	"${gnomesu} ${gnomesu_command}";
end
unset gnomesu gnomesu_commands;

#eof
