#!/bin/tcsh -f
	onintr exit_script;
	
	if(! ${?TCSH_RC_SESSION_PATH} ) \
		setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc"
	set scripts_basename="mount:sshfs:uberchick.tcsh";
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

	if( ${?TCSH_RC_DEBUG} ) \
		set debug_set debug;
	
	set dependencies=("${scripts_basename}" "sshfs");# "${scripts_alias}");
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
			printf "<%s>'s %d%s dependency: <%s> couldn't be found.\n\t%s requires: [%s]." "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${scripts_basename}" "${dependencies}" > ${stderr};
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

set ssh_mount_point="/art/www/ssh";
set ssh_user="uberchick";
set ssh_server="aquarius.ocssolutions.com";
set ssh_path="/home/${ssh_user}";

set ssh_mount_point="${ssh_mount_point}/${ssh_user}@${ssh_server}";

if( "`mount | grep "\""${ssh_mount_point}"\""`" != "" ) then
	printf "<%s@%s> is already mounted.\n" "${ssh_user}" "${ssh_server}";
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
	goto sshfs_connect
end
if( ${?TCSH_RC_DEBUG} ) then
	if(!(${#sshfs_mount_test})) then
		printf "[failed]\n";
	else
		printf "[success]\n";
	endif
endif

exit_script:
	if( ${?debug_set} ) \
		unset debug debug_set;
	
	if( ${?program} )\
		unset program;
	if( ${?suffix} )\
		unset suffix;
	if( ${?dependencies} )\
		unset dependencies;
	if( ${?dependencies_index} )\
		unset dependencies_index;
	if( ${?script} )\
		unset script;
	if( ${?scripts_basename} )\
		unset scripts_basename;
	if( ${?scripts_path} )\
		unset scripts_path;
	if( ${?sshfs_exec} )\
		unset sshfs_exec;
	
	unset ssh_user ssh_server ssh_mount_point ssh_path sshfs_mount_count sshfs_mount_test;
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "mount:sshfs:uberchick.tcsh";
	exit;
#goto exit_script;

sshfs_connect:
$sshfs_exec "${ssh_user}@${ssh_server}:${ssh_path}" "${ssh_mount_point}";
sleep 2;

set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`"
if( ${#sshfs_mount_test} == 0 ) \
	goto next_attempt;
endif

