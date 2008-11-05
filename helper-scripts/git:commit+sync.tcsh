#!/bin/tcsh -f
switch ( "${1}" )
case "":
case "rsync":
case "scp":
case "sshfs":
case "cp":
case "no-sync":
	printf "Usage: %s git_commit_message [rsync scp sshfs cp no-sync]\n" `basename "${0}"`
	exit
	breaksw
endsw

if ( -e "./.sync.default" ) then
	set sync_method = `cat ./.sync.default`
else
	set sync_method = "no-sync"
endif

set project_name = `basename "${PWD}"`

set sshfs_path = "/projects/ssh"

set ssh_user = "dreams"
set ssh_server = "avalon.ocssolutions.com"

git add .

git commit -a -m "${1}"

foreach remote_git ( `git remote` )
	git push "${remote_git}"
end

if ( "${?2}" == "1" && "${2}" != "" ) then
	set sync_method = "${2}"
endif

goto check_sync
exit

run_sync:
switch( "${sync_method}" )
case "rsync":
	rsync -r --verbose ./* "${ssh_user}@${ssh_server}:/home/${ssh_user}/${project_name}"
	exit 0
	breaksw

case "scp":
	scp -rv ./* "${ssh_user}@${ssh_server}:/home/${ssh_user}/${project_name}"
	exit 0
	breaksw

case "sshfs":
	if ( `mount | grep "${sshfs_path}"` == "" ) then
		sshfs "${ssh_user}@${ssh_server}:/home/${ssh_user}" "${sshfs_path}"
	endif
case "cp":
	if ( ! -d "${sshfs_path}/${project_name}" ) then
		printf "I couldn't find your project: '%s' in your sshfs path: '%s'\nEither your project doesn't exist on your sshfs or ssh isn't mounted\n", ${project_name}, ${sshfs_path}
		exit
	endif
	
	cp -r --verbose --update ./* "${sshfs_path}/${project_name}"
	breaksw
endsw

exit

check_sync:
switch ( "${sync_method}" )
case "rsync":
case "scp":
case "sshfs":
case "cp":
	goto run_sync
	breaksw
case "no-sync":
	exit
	breaksw
default:
	printf "%s is not a supported sync method.  Valid options are:\n\trsync, scp, sshfs, cp, no-sync" "${sync_method}"
	exit
	breaksw
endsw
