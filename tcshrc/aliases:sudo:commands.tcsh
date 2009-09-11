#!/bin/tcsh -f
source /projects/cli/tcshrc/debug:check aliases:sudo:commands.tcsh ${argv};

complete sudo "p/1/c/";

set sbin_paths=( "/sbin" "/usr/sbin" );
foreach sbin_path ( ${sbin_paths} )
	foreach command ( "`/usr/bin/find -H ${sbin_path} -maxdepth 1 -xtype f -perm -u+x -printf '%f\n'`" )
		set sudo_alias="`basename '${command}'`";
		if( ${?TCSHRC_DEBUG} ) printf "Setting sudo command alias for %s @ %s\n" ${sudo_alias} `date "+%I:%M:%S%P"`;
		alias "${sudo_alias}" "sudo ${sbin_path}/${command}";
	end
end
unset sbin_path sbin_paths;

set sudo_commands=( "/usr/bin/zypper" "/bin/mount" "/bin/umount" "/srv/mysql/mysql.init.d" "/bin/eject" "/bin/chown" "/bin/chgrp" );
foreach sudo_command ( ${sudo_commands} )
	set sudo_alias="`basename '${sudo_command}'`";
	if( ${?TCSHRC_DEBUG} ) printf "Setting sudo command alias for %s @ %s\n" ${sudo_alias} `date "+%I:%M:%S%P"`;
	alias	"${sudo_alias}"	"sudo ${sudo_command}";
end
unset sudo_command sudo_commands;

set gnomesu_commands=( "/sbin/yast" "/sbin/yast2" );
foreach gnomesu_command ( ${gnomesu_commands} )
	set sudo_alias="`basename '${gnomesu_command}'`";
	if( ${?TCSHRC_DEBUG} ) printf "Setting gnomesu command alias for %s @ %s\n" ${sudo_alias} `date "+%I:%M:%S%P"`;
	alias	"${sudo_alias}"	"/usr/bin/gnomesu ${gnomesu_command}";
end
unset gnomesu_command gnomesu_commands;

#set recursive_sudo_commands=( "chown" "chgrp" )
#foreach recursive_sudo_command ( ${recursive_sudo_commands} )
#	if( ${?TCSHRC_DEBUG} ) printf "Setting recursive sudo command alias for %s @ %s\n" ${recursive_sudo_command} `date "+%I:%M:%S%P"`;
#	alias	"${recursive_sudo_command}"	"sudo ${recursive_sudo_command} -R";
#end
#unset recursive_sudo_command recursive_sudo_commands;

unset sudo_alias;

source /projects/cli/tcshrc/debug:clean-up aliases:sudo:commands.tcsh;
