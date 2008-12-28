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

printf "\n\nFinding all remote files to check for stale files and directories.\nPlease be patient as this may take a few moments.\n"
set remove_remote_regexp = "`echo '${sshfs_path}/${project_name}/' | sed 's/\//\\\//g'`"
foreach remote_file ( "`find '${sshfs_path}/${project_name}/'`" )
	# escape special characters to keep them from being expanded by the terminal
	# set remote_file = "`echo '${remote_file}' | sed 's/\([\.\*\[\]()]\)/\\\1/g' | sed 's/\('\''\)/\1\\\1\1/g'`"

	set git_test = `echo "${remote_file}" | sed 's/.*\(\/\.git\).*/\1/g'`
	if ( "${git_test}" == "/.git" ) continue

	set local_file = "`echo "\""${remote_file}"\"" | sed 's/^${remove_remote_regexp}/\.\//'`"

	if ( ! -d "${local_file}" && ! -e "${local_file}" ) then
		printf "Removing stale remote "

		if ( -d "${remote_file}" ) then
			printf "directory & contents"
			rm -r "${remote_file}"
		else if ( -e "${remote_file}" ) then
			printf "file"
			rm "${remote_file}"
		endif
		printf ":\n\t%s\n" "${remote_file}"
	endif
end
printf "\n\nI am now copying new and/or modified files.\nTo update this project's remote location.\nThis may also take several moments.\n\n"

cp -r --verbose --update --no-dereference ./* "${sshfs_path}/${project_name}"

# cleaning up swp files that may have been copied to the remote location
foreach swp ( "`find '${sshfs_path}/${project_name}' -iregex .\*\.swp`" )
	rm --verbose "${swp}"
end

printf "\n\n"
