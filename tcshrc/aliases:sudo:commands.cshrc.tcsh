#!/bin/tcsh -f
if( ${uid} == 0 || ${?TCSH_SESSION_COMMANDS_SETUP} ) \
	exit 0;

if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "aliases:sudo:commands.cshrc.tcsh" ${argv};
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

set dirs=( "/sbin" "/usr/sbin" );
foreach dir ( ${dirs} )
	set escaped_dir="`printf "\""%s"\"" "\""${dir}"\"" | sed -r 's/([\/])/\\\//g'`";
	if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:?(${escaped_dir})\:?.*/\1/g'`" != "${dir}" ) \
		setenv "${PATH}:${dir}";
	foreach command ( "`/usr/bin/find -H ${dir} -maxdepth 1 -xtype f -printf '%f\n'`" )
		set alias="`basename '${command}'`";
		set dir="`dirname '${command}'`";
		set escaped_dir="`printf "\""%s"\"" "\""${dir}"\"" | sed -r 's/([\/])/\\\//g'`";
		if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:?(${escaped_dir})\:?.*/\1/g'`" != "${dir}" ) \
			setenv "${PATH}:${dir}";
		if( "`alias "\""${alias}"\""`" != "sudo ${command}" ) then
			if( ${?TCSH_RC_DEBUG} ) \
				printf "Setting sudo command alias for %s @ %s\n" ${alias} `date "+%I:%M:%S%P"`;
			alias "${alias}" "sudo ${command}";
		endif
	unset alias dir escaped_dir;
	end
end
unset dir dirs;

set commands=( "/usr/bin/zypper" "/bin/mount" "/bin/umount" "/srv/mysql/mysql.init.d" "/bin/eject" "/bin/chown" "/bin/chgrp" );
foreach command ( ${commands} )
	set alias="`basename '${command}'`";
	set dir="`dirname '${command}'`";
	set escaped_dir="`printf "\""%s"\"" "\""${dir}"\"" | sed -r 's/([\/])/\\\//g'`";
	if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:?(${escaped_dir})\:?.*/\1/g'`" != "${dir}" ) \
		setenv "${PATH}:${dir}";
	if( "`alias "\""${alias}"\""`" != "sudo ${command}" ) then
		if( ${?TCSH_RC_DEBUG} ) \
			printf "Setting sudo command alias for %s @ %s\n" ${alias} `date "+%I:%M:%S%P"`;
		alias "${alias}" "sudo ${command}";
	endif
	unset alias dir escaped_dir;
end
unset command commands;

set commands=("/sbin/yast" "/sbin/yast2" );
foreach command ( ${commands} )
	set alias="`basename '${command}'`";
	set dir="`dirname '${command}'`";
	set escaped_dir="`printf "\""%s"\"" "\""${dir}"\"" | sed -r 's/([\/])/\\\//g'`";
	if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:?(${escaped_dir})\:?.*/\1/g'`" != "${dir}" ) \
		setenv "${PATH}:${dir}";
	if( "`alias "\""${alias}"\""`" != "sudo ${command}" ) then
		if( ${?TCSH_RC_DEBUG} ) \
			printf "Setting sudo command alias for %s @ %s\n" ${alias} `date "+%I:%M:%S%P"`;
		alias "${alias}" "sudo ${command}";
	endif
	unset alias dir escaped_dir;
end
unset command commands;

set commands=( "/sbin/yast" "/sbin/yast2" );
foreach command ( ${commands} )
	set alias="`basename '${command}'`";
	set dir="`dirname '${command}'`";
	set escaped_dir="`printf "\""%s"\"" "\""${dir}"\"" | sed -r 's/([\/])/\\\//g'`";
	if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:?(${escaped_dir})\:?.*/\1/g'`" != "${dir}" ) \
		setenv "${PATH}:${dir}";
	if( "`alias "\""${alias}"\""`" != "sudo ${command}" ) then
		if( ${?TCSH_RC_DEBUG} ) \
			printf "Setting gnomesu command alias for %s @ %s\n" ${alias} `date "+%I:%M:%S%P"`;
		alias "${alias}" "sudo ${command}";
	endif
	
	if( "`complete ${alias}`" == "" ) then
		complete ${alias} p/1/"(add-on add-on-creator autoyast backup bootloader checkmedia disk dsl firewall ftp-server GenProf host http-server hwinfo image-creator inetd inst_release_notes inst_suse_register irda iscsi-client isdn joystick kerberos-client lan language ldap ldap_browser LogProf mail modem mouse nfs nfs_server nis ntp-client online_update online_update_configuration printer product-creator profile-manager proxy remote repositories restore runlevel samba-client samba-server scanner SD_AddProfile SD_DeleteProfile SD_EditProfile SD_Report security sound subdomain sudo sw_single sysconfig system_settings timezone tv users vendor view_anymsg webpin_package_search xen)"/;
	endif
	unset alias dir escaped_dir;
end
unset command commands;

#set commands=( "chown" "chgrp" )
#foreach command ( ${commands} )
#	set alias="`basename '${command}'`";
#	set dir="`dirname '${command}'`";
#	set escaped_dir="`printf "\""%s"\"" "\""${dir}"\"" | sed -r 's/([\/])/\\\//g'`";
#	if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:?(${escaped_dir})\:?.*/\1/g'`" != "${dir}" ) \
#		setenv "${PATH}:${dir}";
#	if( "`alias "\""${alias}"\""`" != "sudo ${command}" ) then
#		if( ${?TCSH_RC_DEBUG} ) \
#			printf "Setting sudo command alias for %s @ %s\n" ${alias} `date "+%I:%M:%S%P"`;
#		alias "${alias}" "sudo ${command}";
#	endif
#	unset alias dir escaped_dir;
#end
#unset command commands;

setenv TCSH_SESSION_COMMANDS_SETUP;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "aliases:sudo:commands.cshrc.tcsh";

