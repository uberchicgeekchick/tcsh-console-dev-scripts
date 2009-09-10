#!/bin/tcsh -f
if(!(${?this_program})) set this_program="sshfs";

foreach program ( "`which '${this_program}'`" )
	if( -x "${program}" ) end
endif

if( !( ${?program} && -x "${program}" ) ) then
	printf "Unable to find %s.\n" "${this_program}";
	exit -1;
endif

source /projects/cli/tcshrc/debug:check csh.cshrc ${argv};

set ssh_user="dreams";
set ssh_server="avalon.ocssolutions.com";
set ssh_path="/home/dreams";

set ssh_mount_point="/projects/ssh";
if( ! -d "${ssh_mount_point}" ) mkdir -p "${ssh_mount_point}";

alias	"sshfs:mount:${ssh_user}"	"sshfs '${ssh_user}@${ssh_server}:${ssh_path}' '${ssh_mount_point}'";

set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`";
@ sshfs_mount_count=0;
if(${?TCSHRC_DEBUG}) printf "Mounting sshfs: [%s:%s]\t\t" ${ssh_server} ${ssh_path};
@ sshfs_max_attempts=10;
next_attempt:
while ( ( ${sshfs_mount_count} < ${sshfs_max_attempts} ) && (! ${#sshfs_mount_test} ) )
	goto sshfs_connect
	@ sshfs_mount_count++;
	if( $sshfs_mount_count >= $sshfs_max_attempts ) then
		printf "Maximum automated SSH attempts reached (%d out of %d connections attemted)." $sshfs_mount_count $sshfs_max_attempts;
		exit
	endif
	if(${?TCSHRC_DEBUG}) then
		printf "attempt %s out of %s [failed].\n" ${sshfs_mount_count} ${sshfs_max_attempts};
		if( ${sshfs_mount_count} < ${sshfs_max_attempts} ) printf "\nre-attempting connection\n";
	endif
end
if( ${?TCSHRC_DEBUG} ) then
	if(!(${#sshfs_mount_test})) then
		printf "[failed]\n";
	else
		printf "[success]\n";
	endif
endif
unset ssh_user ssh_server ssh_mount_point ssh_path sshfs_mount_count sshfs_mount_test;


exit;

sshfs_connect:
sshfs "${ssh_user}@${ssh_server}:${ssh_path}" "${ssh_mount_point}";
sleep 2;

set sshfs_mount_test="`/bin/mount | grep '${ssh_mount_point}'`"
if(!(${#sshfs_mount_test})) goto next_attempt;

