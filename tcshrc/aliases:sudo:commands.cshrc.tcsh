#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
set source_file="aliases:sudo:commands.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${source_file}" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

complete sudo "p/1/c/";

if(! ${?TCSH_SESSION_SBIN_PATH_SET} ) then
	set sbin_paths=( "/sbin" "/usr/sbin" );
	foreach sbin_path ( ${sbin_paths} )
		setenv PATH "${PATH}:${sbin_path}";
		foreach command ( "`/usr/bin/find -H ${sbin_path} -maxdepth 1 -xtype f -perm -u+x -printf '%f\n'`" )
			set sudo_alias="`basename '${command}'`";
			#if( ${?TCSH_RC_DEBUG} ) printf "Setting sudo command alias for %s @ %s\n" ${sudo_alias} `date "+%I:%M:%S%P"`;
			alias "${sudo_alias}" "sudo ${sbin_path}/${command}";
		end
	end
	if(! ${?TCSH_SESSION_SBIN_PATH_SET} ) setenv TCSH_SESSION_SBIN_PATH_SET;
	unset sbin_path sbin_paths;
endif

set sudo_commands=( "/usr/bin/zypper" "/bin/mount" "/bin/umount" "/srv/mysql/mysql.init.d" "/bin/eject" "/bin/chown" "/bin/chgrp" "/sbin/yast" "/sbin/yast2" );
foreach sudo_command ( ${sudo_commands} )
	set sudo_alias="`basename '${sudo_command}'`";
	#if( ${?TCSH_RC_DEBUG} ) printf "Setting sudo command alias for %s @ %s\n" ${sudo_alias} `date "+%I:%M:%S%P"`;
	alias	"${sudo_alias}"	"sudo ${sudo_command}";
end
unset sudo_command sudo_commands;

#set gnomesu_commands=( "/sbin/yast" "/sbin/yast2" );
#foreach gnomesu_command ( ${gnomesu_commands} )
#	set sudo_alias="`basename '${gnomesu_command}'`";
#	if( ${?TCSH_RC_DEBUG} ) printf "Setting gnomesu command alias for %s @ %s\n" ${sudo_alias} `date "+%I:%M:%S%P"`;
#	alias	"${sudo_alias}"	"/usr/bin/gnomesu ${gnomesu_command}";
#end
#unset gnomesu_command gnomesu_commands;

#set recursive_sudo_commands=( "chown" "chgrp" )
#foreach recursive_sudo_command ( ${recursive_sudo_commands} )
#	if( ${?TCSH_RC_DEBUG} ) printf "Setting recursive sudo command alias for %s @ %s\n" ${recursive_sudo_command} `date "+%I:%M:%S%P"`;
#	alias	"${recursive_sudo_command}"	"sudo ${recursive_sudo_command} -R";
#end
#unset recursive_sudo_command recursive_sudo_commands;

unset sudo_alias;

if(! ${?source_file} ) set source_file="aliases:sudo:commands.cshrc.tcsh";
if( "${source_file}" != "aliases:sudo:commands.cshrc.tcsh" ) set source_file="aliases:sudo:commands.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";
