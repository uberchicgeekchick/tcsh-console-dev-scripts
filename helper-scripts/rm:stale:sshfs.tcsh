#!/bin/tcsh -f
set project_name = "`basename '${cwd}'`"

set sshfs_path = "/projects/ssh"

set ssh_user = "dreams"
set ssh_server = "avalon.ocssolutions.com"

if ( -e "./.sync.default" ) then
	set sync_method = `cat ./.sync.default`
else
	set sync_method = "sshfs"
endif


switch( "${sync_method}" )
case "rsync":
case "scp":
case "no-sync":
	exit
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
	breaksw
endsw

printf "Finding all remote files to check for stale files and directories.\nPlease be patient as this may take a few moments.\n"
set clean_up_regexp = "`echo '${sshfs_path}/${project_name}/' | sed 's/\//\\\//g'`"
foreach remote_file ( "`find '${sshfs_path}/${project_name}'`" )
	set local_file = `echo "${remote_file}" | sed "s/'/'\\''/g"`
	set local_file = "`echo '${remote_file}' | sed 's/^${clean_up_regexp}/\.\//'`"
	if ( ! -d "${local_file}" && ! -e "${local_file}" ) then
		printf "Removing stale remote "

		if ( -d "${remote_file}" ) then
			printf "directory"
			rmdir "${remote_file}"
		else if ( -e "${remote_file}" ) then
			printf "file"
			rm "${remote_file}"
		endif
		printf ":\n\t%s\n" "${remote_file}"
	endif
end
printf "\n\n"
