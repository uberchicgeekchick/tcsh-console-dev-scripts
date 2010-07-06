#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc"
source "${TCSH_RC_SESSION_PATH}/argv:check" "mount:sshfs:uberchick.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

set this_program="sshfs";
foreach program ( "`which "\""${this_program}"\""`" )
	if( -x "${program}" ) \
		break
	unset program;
end

if(! ${?program} ) then
	if( ${?TCSH_OUTPUT_ENABLED} ) \
		printf "Unable to find %s.\n" "${this_program}";
	set status=-1;
	goto exit_script;
endif

set ssh_user="uberchick";
set ssh_server="aquarius.ocssolutions.com";
set ssh_path="/home/${ssh_user}";

set ssh_mount_point="/art/www/ssh/${ssh_user}@${ssh_server}";

alias "mount:sshfs:${ssh_user}@${ssh_server}" "sshfs '${ssh_user}@${ssh_server}:${ssh_path}' '${ssh_mount_point}'";

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
	unset ssh_user ssh_server ssh_mount_point ssh_path sshfs_mount_count sshfs_mount_test;
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "mount:sshfs:uberchick.tcsh";
	exit;
#goto exit_script;

sshfs_connect:
sshfs "${ssh_user}@${ssh_server}:${ssh_path}" "${ssh_mount_point}";
sleep 2;

set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`"
if( ${#sshfs_mount_test} == 0 ) \
	goto next_attempt;
endif

