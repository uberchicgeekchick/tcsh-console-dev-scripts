#!/bin/tcsh -f
set ssh_user="dreams"
set ssh_server="avalon.ocssolutions.com"
set ssh_mount_point="/projects/ssh"
set ssh_path="/home/dreams"

alias	"sshfs.${ssh_user}"	"sshfs '${ssh_user}@${ssh_server}:${ssh_path}' '${ssh_mount_point}'"

set sshfs_mount_test=`mount | /usr/bin/grep "${ssh_mount_point}"`
@ sshfs_mount_count=0;
while ( "${sshfs_mount_test}" == "" && "${#sshfs_mount_count}" < 10 )
	"sshfs.${ssh_user}"
	@ sshfs_mount_count++;
	sleep 2
	set sshfs_mount_test=`mount | /usr/bin/grep "${ssh_mount_point}"`
end

unset ssh_user ssh_server ssh_mount_point ssh_path sshfs_mount_count sshfs_mount_test

