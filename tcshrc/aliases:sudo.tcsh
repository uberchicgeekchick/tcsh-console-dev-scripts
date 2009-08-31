#!/bin/tcsh -f
if( ! ${?SSH_CONNECTION} && ! ${?TCSHRC_DEBUG} && ${?1} && "${1}" != "" && "${1}" == "--debug" ) setenv TCSHRC_DEBUG;
complete sudo "p/1/c/";

set sbin_paths=( "/sbin" "/usr/sbin" );
foreach sbin_path ( ${sbin_paths} )
	foreach command ( "`/usr/bin/find -H ${sbin_path} -maxdepth 1 -xtype f -perm -u+x -printf '%f\n'`" )
		set cmd_alias=`basename ${command}`;
		if( ${?TCSHRC_DEBUG} ) printf "Setting sudo alias for %s @ %s\n" ${cmd_alias} `date "+%I:%M:%S%P"`;
		alias "${cmd_alias}" "sudo ${command}";
	end
end
unset sbin_path sbin_paths cmd_alias;

set sudo_commands=( "zypper" "mount" "umount" "/srv/mysql/mysql.init.d" "eject" "chown" "chgrp" );
foreach sudo_command ( ${sudo_commands} )
	if( ${?TCSHRC_DEBUG} ) printf "Setting sudo alias for %s @ %s\n" ${sudo_command} `date "+%I:%M:%S%P"`;
	alias	"${sudo_command}"	"sudo ${sudo_command}";
end
unset sudo_command sudo_commands;

set gnomesu_commands=( "yast" "yast2" "/sbin/yast2" );
foreach gnomesu_command ( ${gnomesu_commands} )
	if( ${?TCSHRC_DEBUG} ) printf "Setting gnomesu alias for %s @ %s\n" ${gnomesu_command} `date "+%I:%M:%S%P"`;
	alias	"${gnomesu_command}"	"/usr/bin/gnomesu ${gnomesu_command}";
end
unset gnomesu_command gnomesu_commands;

#set recursive_sudo_commands=( "chown" "chgrp" )
#foreach recursive_sudo_command ( ${recursive_sudo_commands} )
#	if( ${?TCSHRC_DEBUG} ) printf "Setting recursive sudo alias for %s @ %s\n" ${recursive_sudo_command} `date "+%I:%M:%S%P"`;
#	alias	"${recursive_sudo_command}"	"sudo ${recursive_sudo_command} -R";
#end
#unset recursive_sudo_command recursive_sudo_commands;

