#!/bin/tcsh
if ( "${?1}" == "0" || "${1}" == "" || "${1}" == "rsync" || "${1}" == "no-sync" ) then
	printf "Usage: %s git_commit_message [rsync scp no-sync cp fuse]\n" `basename "${0}"`
	exit -1
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

switch( "${2}" )
case "rsync":
	rsync -r --verbose ./* "${ssh_user}@${ssh_server}:/home/${ssh_user}/${project_name}"
	exit 0
	breaksw

case "scp":
	scp -rv ./* "${ssh_user}@${ssh_server}:/home/${ssh_user}/${project_name}"
	exit 0
	breaksw

case "cp":
case "fuse":
	breaksw

case "no-sync":
	exit 0
	breaksw
endsw

if ( ! -d "${sshfs_path}/${project_name}" ) then
	printf "I couldn't find your project: '%s' in your sshfs path: '%s'\nEither your project doesn't exist on your sshfs or ssh isn't mounted\n", ${project_name}, ${sshfs_path}
	exit -1
endif

cp -r --verbose --update ./* "${sshfs_path}/${project_name}"

