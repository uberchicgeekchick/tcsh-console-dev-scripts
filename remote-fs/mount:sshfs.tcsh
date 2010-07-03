#!/bin/tcsh -f
init:
	exit -1;
	set scripts_basename="mount:sshfs.tcsh";
	set ssh_accounts=("uberchick@aquarius.ocssolutions.com" "dreams@sky.ocssolutions.com" );
#goto init;


dependencies_check:
	set dependencies=("${scripts_basename}" "sshfs" "sed" "ex");# "${scripts_alias}");
	@ dependencies_index=0;
	
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		
		if( ${?nodeps} && $dependencies_index > 1 ) \
			break;
		
		set dependency=$dependencies[$dependencies_index];
		
		set which_dependency=`printf "%d" "${dependencies_index}" | sed -r 's/^[0-9]*[^1]?([0-9])$/\1/'`;
		if( $which_dependency == 1 ) then
			set suffix="st";
		else if( $which_dependency == 2 ) then
			set suffix="nd";
		else if( $which_dependency == 3 ) then
			set suffix="rd";
		else
			set suffix="th";
		endif
		unset which_dependency;
		
		if( ${?debug} ) \
			printf "\n**dependencies:** looking for <%s>'s %d%s dependency: %s.\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" > ${stdout};
		
		foreach program("`where "\""${dependency}"\""`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		if(! ${?program} ) then
			printf "**dependencies:** <%s>'s %d%s dependency: <%s> couldn't be found.\n\t%s requires: [%s]." "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${scripts_basename}" "${dependencies}" > ${stderr};
			unset suffix dependency dependencies dependencies_index;
			goto exit_script;
		endif
		
		if( ${?debug} ) \
			printf "**dependencies:** <%s>'s %d%s dependency: %s ( binary: %s )\t[found]\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${program}" > ${stdout};
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?script} ) \
					breaksw;
				
				set old_owd="${cwd}";
				cd "`dirname "\""${program}"\""`";
				set scripts_path="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_path}/${scripts_basename}";
				breaksw;
			
			default:
				if(! ${?execs} ) \
					set execs=()
				set execs=(${execs} "${program}");
				breaksw;
		endsw
		unset program dependency;
	end
	
	if( ${?debug_set} ) \
		unset debug;
	
	unset dependencies dependencies_index;
	
	goto parse_argv;
#goto dependencies_check;


main:
	if(! ${?0} ) then
		# START: special handler for when this file is sourced.
		if(! ${?TCSH_RC_SESSION_PATH} ) \
			setenv TCSH_RC_SESSION_PATH "${scripts_path}/../tcshrc";
		source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
	endif
	
	
	foreach ssh_account( ${ssh_accounts} )
		if( `alias "mount:sshfs:${ssh_account}"` == "" ) then
			set set_alias;
		else if( `alias "mount:sshfs:${ssh_account}"` != "${script} --account='${ssh_account}'" ) then
			set set_alias;
		endif
		
		if( ${?set_alias} ) then
			alias "mount:sshfs:${ssh_account}" "${script} --account='${ssh_account}'";
			#"sshfs '${ssh_user}@${ssh_server}:${ssh_path}' '${ssh_mount_point}'";
		endif
		
		set ssh_user="`printf "\""%s"\"" "\""${ssh_account}"\"" | sed -r 's/^([^@]+)@(.*)"\$"/\1/`";
		set ssh_server="`printf "\""%s"\"" "\""${ssh_account}"\"" | sed -r 's/^([^@]+)@(.*)"\$"/\2/`";
		set ssh_mount_point="/art/www/ssh/${ssh_user}@${ssh_server}";
		
		if( "`mount | grep '$ssh_mount_point'`" != "" ) then
			if(${?TCSH_RC_DEBUG}) \
				printf "%s's is already connected to %s\n" "${ssh_user}" "${ssh_server}";
			set status=-1;
			goto exit_script;
		endif
		
		if(! -d ${ssh_mount_point} ) then
			if(! -e ${ssh_mount_point} ) then
				mkdir -p "${ssh_mount_point}";
			else
				if(${?TCSH_RC_DEBUG}) \
					printf "%s's connection to %s has been terminated.\nAttempting to unmount.\n" "${ssh_user}" "${ssh_server}";
				set use_sudo="";
				if( ${uid} != 0 ) \
					set use_sudo="sudo ";
				${use_sudo}umount -f "${ssh_mount_point}";
			endif
		endif
		
		set status=0;
		ping -c 1 "${ssh_server}" > /dev/null;
		if( ${status} != 0 ) then
			printf "%s could not be reached.  Please check your network connection.\n" "${ssh_server}";
			exit;
		endif
		
		set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`";
		@ sshfs_mount_count=0;
		if(${?TCSH_RC_DEBUG}) \
			printf "Mounting sshfs: [%s:%s]\t\t" ${ssh_server} ${ssh_path};
		@ sshfs_max_attempts=10;
		goto next_attempt;
	end
	goto exit_script;
#goto main;


next_attempt:
	while ( ( $sshfs_mount_count <= $sshfs_max_attempts ) && ${#sshfs_mount_test} == 0 )
		@ sshfs_mount_count++;
		if( $sshfs_mount_count >= $sshfs_max_attempts ) then
			if( ${?TCSH_RC_DEBUG} ) \
				printf "Maximum automated SSH attempts reached (%d out of %d connections attemted)." $sshfs_mount_count $sshfs_max_attempts;
			set sshfs_mount_test="`printf 'mounting [%s@%s:%s] to [%s] failed\nexiting\n' '${ssh_user}' '${ssh_server}':'${ssh_path}' '${ssh_mount_point}'`";
		else if( ${?TCSH_RC_DEBUG} ) then
			printf "attempt %s out of %s [failed].\n" ${sshfs_mount_count} ${sshfs_max_attempts};
			if( ${sshfs_mount_count} < ${sshfs_max_attempts} ) \
				printf "\nre-attempting connection\n";
		endif
		goto sshfs_connect;
	end
	
	if( ${?TCSH_RC_DEBUG} ) then
		if(!(${#sshfs_mount_test})) then
			printf "[failed]\n";
		else
			printf "[success]\n";
		endif
	endif
	goto main;
#goto next_attempt:


exit_script:
	unset debug ssh_user ssh_server ssh_mount_point ssh_path sshfs_mount_count sshfs_mount_test;
	if(! ${?0} ) then
		source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_basename}";
		# FINISH: special handler for when this file is sourced.
	endif
	
	exit;
#goto exit_script;

sshfs_connect:
	sshfs "${ssh_user}@${ssh_server}:${ssh_path}" "${ssh_mount_point}";
	sleep 2;
	
	set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`"
	if( ${#sshfs_mount_test} == 0 ) \
		goto next_attempt;
	goto main;
#goto sshfs_connect;

parse_argv:
	if(!( ${#argv} > 0 )) \
		goto main;
	
	@ argc=${#argv};
	@ arg=0;
	while ( $arg < $argc )
		if(! ${?arg_shifted} ) \
			@ arg++;
		
		if( ${?debug} || ${?diagnostic_mode} ) \
			printf "\t**debug:** parsing "\$"argv[%d] (%s).\n" $arg "$argv[$arg]";
		
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) \
			set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
		if( "${option}" == "$argv[$arg]" ) \
			set option="";
		
		set equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
		if( "${equals}" == "$argv[$arg]" ) \
			set equals="";
		
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
		
		if( "${value}" != "$argv[$arg]" && !( "${dashes}" != "" && "${option}" != "" && "${equals}" != "" && "${value}" != "" )) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				set test_dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
				set test_option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
				set test_equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
				set test_value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
				
				if( "${test_dashes}" == "$argv[$arg]" && "${test_option}" == "$argv[$arg]" && "${test_equals}" == "$argv[$arg]" && "${test_value}" == "$argv[$arg]") then
					set equals=" ";
					set value="$argv[$arg]";
					set arg_shifted;
				endif
				unset test_dashes test_option test_equals test_value;
			endif
		endif
		
		if( ${?debug} || ${?diagnostic_mode} ) \
			printf "\t**debug:** parsed "\$"argv[%d]: %s%s%s%s\n" $arg "${dashes}" "${option}" "${equals}" "${value}";
		
		switch ( "${option}" )
			case "h":
			case "help":
				goto usage;
				breaksw;
			
			case "debug":
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "account":
				if( `printf "%s" "${value}" | sed -r 's/^([^@]+)@(.*)$//` != "" ) then
					printf "**error:** <%s> does not appear to be a valid ssh account/connection.\n" "${value}";
					@ errno=-101;
					goto exit_script;
				endif
				
				set ssh_accounts=( "${value}" );
				breaksw;
		endsw
	end
#goto parse_argv;
