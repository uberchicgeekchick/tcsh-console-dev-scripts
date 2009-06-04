#!/bin/tcsh -f
set ssh_user="dreams";
set ssh_server="avalon.ocssolutions.com";
set ssh_path="/home/dreams";

set ssh_mount_point="/projects/ssh";

alias	"sshfs:mount:${ssh_user}"	"sshfs '${ssh_user}@${ssh_server}:${ssh_path}' '${ssh_mount_point}'";

set old_cwd = ${cwd};
set sshfs_mount_test=`mount | /usr/bin/grep "${ssh_mount_point}"`
@ sshfs_mount_count=0;
while ( ${sshfs_mount_count} < 10 && "${sshfs_mount_test}" == "" )
	sshfs "${ssh_user}@${ssh_server}:${ssh_path}" "${ssh_mount_point}";
	set sshfs_mount_test=`mount | /usr/bin/grep "${ssh_mount_point}"`
	@ sshfs_mount_count++
	if ( "${sshfs_mount_test}" == "" ) sleep 2
end
if ( "${sshfs_mount_test}" == "" ) sshfs:mount:${ssh_user}
cd ${old_cwd}
unset ssh_user ssh_server ssh_mount_point ssh_path sshfs_mount_count old_cwd sshfs_mount_test
