#!/bin/tcsh -f
if(!(${?this_program})) set this_program="sshfs";

foreach program ( "`which '${this_program}'`" )
	if( -x "${program}" ) end
endif

if( !( ${?program} && -x "${program}" ) ) then
	printf "Unable to find %s.\n" "${this_program}";
	exit -1;
endif

if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/tcshrc";
set source_file="mount:sshfs:dreams.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${source_file}" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled source_file;

set ssh_user="dreams";
set ssh_server="sky.ocssolutions.com";
set ssh_path="/home/dreams";

set ssh_mount_point="/projects/ssh";
if(! -d ${ssh_mount_point} ) mkdir -p "${ssh_mount_point}";

if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/tcshrc";
alias	"mount:sshfs:${ssh_user}"	"${TCSH_RC_SESSION_PATH}/${0}";

set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`";
@ sshfs_mount_count=0;
if(${?TCSHRC_DEBUG}) printf "Mounting sshfs: [%s:%s]\t\t" ${ssh_server} ${ssh_path};
@ sshfs_max_attempts=10;
next_attempt:
while ( ( $sshfs_mount_count <= $sshfs_max_attempts ) && ${#sshfs_mount_test} == 0 )
	@ sshfs_mount_count++;
	if( $sshfs_mount_count >= $sshfs_max_attempts ) then
		if( ${?TCSHRC_DEBUG} ) printf "Maximum automated SSH attempts reached (%d out of %d connections attemted)." $sshfs_mount_count $sshfs_max_attempts;
		set sshfs_mount_test="`printf 'mounting [%s@%s:%s] to [%s] failed\nexiting\n' '${ssh_user}' '${ssh_server}':'${ssh_path}' '${ssh_mount_point}'`";
	else if( ${?TCSHRC_DEBUG} ) then
		printf "attempt %s out of %s [failed].\n" ${sshfs_mount_count} ${sshfs_max_attempts};
		if( ${sshfs_mount_count} < ${sshfs_max_attempts} ) printf "\nre-attempting connection\n";
	endif
	goto sshfs_connect
end
if( ${?TCSHRC_DEBUG} ) then
	if(!(${#sshfs_mount_test})) then
		printf "[failed]\n";
	else
		printf "[success]\n";
	endif
endif
unset ssh_user ssh_server ssh_mount_point ssh_path sshfs_mount_count sshfs_mount_test;

source /projects/cli/tcshrc/argv:clean-up mount:sshfs:ocs;

exit;

sshfs_connect:
sshfs "${ssh_user}@${ssh_server}:${ssh_path}" "${ssh_mount_point}";
sleep 2;

set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`"
if( ${#sshfs_mount_test} == 0 ) goto next_attempt;
endif

