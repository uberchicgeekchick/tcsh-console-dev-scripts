#!/bin/tcsh -f
init:
	onintr exit_script;
	
	set scripts_basename="mount:sshfs.tcsh";
	set ssh_accounts=("uberchick@aquarius.ocssolutions.com" "dreams@sky.ocssolutions.com" );
	
	if(! ${?0} ) then
		set being_sourced;
	else if( `basename "${0}"` != "${scripts_basename}" ) then
		set being_sourced;
	endif
	
	set use_sudo="";
	if( ${uid} != 0 ) \
		set use_sudo="sudo ";
	
	if( ${?being_sourced} ) then
		if(! ${?TCSH_RC_SESSION_PATH} ) \
			setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc"
		source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
		if( $args_handled > 0 ) then
			@ args_shifted=0;
			while( $args_shifted < $args_handled )
				@ args_shifted++;
				shift;
			end
			unset args_shifted;
		endif
		unset args_handled;
	endif
		
	#if( ${?TCSH_RC_DEBUG} && ! ${?debug} ) \
	#	set debug_set debug;
#goto init;


dependencies_check:
	set dependencies=("${scripts_basename}" "sshfs" "ping");# "${scripts_alias}");
	@ dependencies_index=0;
	
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		
		set dependency="$dependencies[$dependencies_index]";
		
		switch( "`printf "\""%d"\"" "\""${dependencies_index}"\"" | sed -r 's/^[0-9]*([0-9])"\$"/\1/'`" )
			case 1:
				set suffix="st";
				breaksw;
			
			case 2:
				set suffix="nd";
				breaksw;
			
			case 3:
				set suffix="rd";
				breaksw;
			
			default:
				set suffix="th";
				breaksw;
		endsw
		
		if( ${?debug} ) \
			printf "\n**dependencies:** looking for <%s>'s %d%s dependency: %s.\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}";
		
		foreach program("`where "\""${dependency}"\""`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		if(! ${?program} ) then
			printf "<%s>'s %d%s dependency: <%s> couldn't be found.\n\t%s requires: [%s].\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${scripts_basename}" "${dependencies}" > ${stderr};
			unset suffix dependency dependencies dependencies_index;
			@ errno=-501;
			goto exit_script;
		endif
		
		if( ${?debug} ) \
			printf "\n**dependencies:** <%s>'s %d%s dependency: %s ( binary: %s )\t[found]\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${program}";
		
		unset suffix;
		
		switch("${dependency}")
			case "${scripts_basename}":
				set old_owd="${cwd}";
				cd "`dirname "\""${program}"\""`";
				set scripts_path="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_path}/${scripts_basename}";
				breaksw;
			
			case "sshfs":
				set sshfs_exec="${program}";
				breaksw;
		endsw
		
		unset program dependency;
	end
	
	unset dependencies dependencies_index;
	goto parse_argv;
#goto dependencies_check;


main:
	onintr main;
	
	if( ${?ssh_account} ) then
		#if( ${?debug} ) \
			printf "\t\t[cancelled]\n";
	endif
	
	if( ${?debug} ) \
		printf "Executing: [%s]->main:\n" "${scripts_basename}";
	if(! ${?being_sourced} ) then
		if( ${#ssh_accounts} > 1 ) then
			@ errno=-1;
			goto usage;
		endif
	endif
	
	foreach ssh_account( ${ssh_accounts} )
		if( ${?being_sourced} ) then
			if( `alias "mount:sshfs:${ssh_account}"` == "" ) then
				set set_alias;
			else if( `alias "mount:sshfs.${ssh_account}"` != "${script} ${ssh_account}" ) then
				set set_alias;
			endif
		endif
		
		if( ${?account_to_mount} ) then
			if( "${account_to_mount}" == "${ssh_account}" ) then
				unset account_to_mount;
			endif
			unset ssh_account;
			continue;
		endif
		
		set ssh_user="`printf "\""%s"\"" "\""${ssh_account}"\"" | sed -r 's/^([^@]+)@(.*)"\$"/\1/'`";
		set ssh_server="`printf "\""%s"\"" "\""${ssh_account}"\"" | sed -r 's/^([^@]+)@(.*)"\$"/\2/'`";
		set ssh_mount_point="/art/www/ssh/${ssh_user}@${ssh_server}";
		set ssh_path="/home/${ssh_user}";
		if( ${?debug} ) \
			printf "ssh_account: [%s]; ssh_user: [%s]; ssh_server: [%s]; ssh_mount_point: [%s]; ssh_path: [%s].\n" "${ssh_account}" "${ssh_user}" "${ssh_server}" "${ssh_mount_point}" "${ssh_path}";
		
		if(! ${?account_to_mount} ) then
			set account_to_mount="${ssh_account}";
			
			if( ${?set_alias} ) then
				alias "mount:sshfs.${ssh_account}" "${script} ${ssh_account}";
				#alias "mount:sshfs.${ssh_account}" "sshfs '${ssh_user}@${ssh_server}:${ssh_path}' '${ssh_mount_point}'";
				unset set_alias;
			endif
		endif
		
		#if( ${?debug} ) then
		#	unset ssh_account ssh_user ssh_server ssh_mount_point ssh_path;
		#	goto main;
		#endif
		
		goto ssh_mount;
	end
	goto exit_script;
#goto main;

ssh_mount:
	if( "`mount | grep '$ssh_mount_point'`" != "" ) then
		if( ${?TCSH_OUTPUT_ENABLED} && ! ${?being_sourced} ) \
			printf "%s is already connected to %s\n" "${ssh_user}" "${ssh_server}";
		set status=-1;
		unset ssh_account ssh_user ssh_server ssh_mount_point ssh_path;
		goto main;
	endif
	
	if(! -d ${ssh_mount_point} ) then
		if(! -e ${ssh_mount_point} ) then
			mkdir -p "${ssh_mount_point}";
		else
			if( ${?TCSH_OUTPUT_ENABLED} && ! ${?being_sourced} ) \
				printf "%s's connection to %s has been terminated.\nAttempting to unmount.\n" "${ssh_user}" "${ssh_server}";
			${use_sudo}umount -f "${ssh_mount_point}";
		endif
	endif
	
	set status=0;
	ping -c 1 "${ssh_server}" > /dev/null;
	if( ${status} != 0 ) then
		printf "%s could not be reached.  Please check your network connection.\n" "${ssh_server}";
		unset ssh_account ssh_user ssh_server ssh_mount_point ssh_path;
		goto main;
	endif
	
	set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`";
	@ sshfs_mount_count=0;
	if( ${?TCSH_OUTPUT_ENABLED} && ! ${?being_sourced} ) \
		printf "Mounting sshfs: [%s:%s]\t\t" ${ssh_server} ${ssh_path};
	@ sshfs_max_attempts=10;
	goto next_attempt;
#goto ssh_mount;

next_attempt:
	onintr next_attempt;
	
	while ( ( $sshfs_mount_count <= $sshfs_max_attempts ) && ${#sshfs_mount_test} == 0 )
		@ sshfs_mount_count++;
		if( $sshfs_mount_count >= $sshfs_max_attempts ) then
			if( ${?TCSH_OUTPUT_ENABLED} && ! ${?being_sourced} ) \
				printf "Maximum automated SSH attempts reached (%d out of %d connections attemted)." $sshfs_mount_count $sshfs_max_attempts;
			set sshfs_mount_test="`printf 'mounting [%s@%s:%s] to [%s] failed\nexiting\n' '${ssh_user}' '${ssh_server}':'${ssh_path}' '${ssh_mount_point}'`";
		else if( ${?TCSH_OUTPUT_ENABLED} && ! ${?being_sourced} ) then
			printf "attempt %s out of %s [failed].\n" ${sshfs_mount_count} ${sshfs_max_attempts};
			if( ${sshfs_mount_count} < ${sshfs_max_attempts} ) \
				printf "\nre-attempting connection\n";
		endif
		goto sshfs_connect;
	end
	
	if( ${?TCSH_OUTPUT_ENABLED} && ! ${?being_sourced} ) then
		if(!(${#sshfs_mount_test})) then
			printf "[failed]\n";
		else
			printf "[success]\n";
		endif
	endif
	unset ssh_account ssh_user ssh_server ssh_mount_point ssh_path;
	goto main;
#goto next_attempt;


sshfs_connect:
	sshfs "${ssh_user}@${ssh_server}:${ssh_path}" "${ssh_mount_point}";
	sleep 2;
	
	set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`"
	if( ${#sshfs_mount_test} == 0 ) \
		goto next_attempt;
	unset ssh_account ssh_user ssh_server ssh_mount_point ssh_path;
	goto main;
#goto sshfs_connect;


env_unset:
	if( ${?debug_set} ) \
		unset debug_set debug;
	if( ${?arg} ) \
		unset arg;
	if( ${?argc} ) \
		unset argc;
	if( ${?arg_shifted} ) \
		unset arg_shifted;
	if( ${?args_shifted} ) \
		unset args_shifted;
	if( ${?dashes} ) \
		unset dashes;
	if( ${?debug} ) \
		unset debug;
	if( ${?dependencies} ) \
		unset dependencies;
	if( ${?dependencies_index} ) \
		unset dependencies_index;
	if( ${?dependency} ) \
		unset dependency;
	if( ${?equals} ) \
		unset equals;
	if( ${?old_owd} ) \
		unset old_owd;
	if( ${?option} ) \
		unset option;
	if( ${?program} ) \
		unset program;
	if( ${?script} ) \
		unset script;
	if( ${?scripts_basename} ) \
		unset scripts_basename;
	if( ${?scripts_path} ) \
		unset scripts_path;
	if( ${?set_alias} ) \
		unset set_alias;
	if( ${?ssh_account} ) \
		unset ssh_account;
	if( ${?ssh_accounts} ) \
		unset ssh_accounts;
	if( ${?sshfs_exec} ) \
		unset sshfs_exec;
	if( ${?sshfs_max_attempts} ) \
		unset sshfs_max_attempts;
	if( ${?sshfs_mount_count} ) \
		unset sshfs_mount_count;
	if( ${?sshfs_mount_test} ) \
		unset sshfs_mount_test;
	if( ${?ssh_mount_point} ) \
		unset ssh_mount_point;
	if( ${?ssh_server} ) \
		unset ssh_server;
	if( ${?ssh_user} ) \
		unset ssh_user;
	if( ${?suffix} ) \
		unset suffix;
	if( ${?test_dashes} ) \
		unset test_dashes;
	if( ${?test_equals} ) \
		unset test_equals;
	if( ${?test_option} ) \
		unset test_option;
	if( ${?test_value} ) \
		unset test_value;
	if( ${?use_sudo} ) \
		unset use_sudo;
	if( ${?value} ) \
		unset value;
	set env_unset;
	goto exit_script;
#goto env_unset;

usage:
	printf "Usage: %s user@ssh_server\n" "${scripts_basename}";
	goto exit_script;
#goto usage;

exit_script:
	if( ${?being_sourced} ) then
		set scripts_basename="mount:sshfs.tcsh";
		source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_basename}";
		unset being_sourced;
		# FINISH: special handler for when this file is sourced.
	endif
	
	if(! ${?env_unset} ) then
		goto env_unset;
	else
		unset env_unset;
	endif
	
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $errno;
#goto exit_script;

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
		
		if( "${dashes}" != "" && "${option}" != "" && "${equals}" == "" && "${value}" == "" ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				set test_dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
				if( "${test_dashes}" == "$argv[$arg]" ) \
					set test_dashes="";
				set test_option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
				if( "${test_option}" == "$argv[$arg]" ) \
					set test_option="";
				set test_equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
				if( "${test_equals}" == "$argv[$arg]" ) \
					set test_equals="";
				set test_value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
				
				if(!( "${test_dashes}" == "" && "${test_option}" == "" && "${test_equals}" == "" && "${test_value}" == "$argv[$arg]" )) then
					@ arg--;
				else
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
			default:
				foreach ssh_account( ${ssh_accounts} )
					if( "${value}" == "${ssh_account}" ) then
						set ssh_accounts=( "${value}" );
						unset ssh_account;
						breaksw;
					endif
					unset ssh_account;
				end
				if( `printf "%s" "${value}" | sed -r 's/^([^@]+)@(.+)$//'` == "" ) then
					set ssh_accounts=( "${value}" );
					breaksw;
				endif
				
				printf "**error:** <%s> does not appear to be a valid ssh account/connection.\n" "${value}";
				@ errno=-101;
				goto usage;
				breaksw;
		endsw
	end
	goto main;
#goto parse_argv;


