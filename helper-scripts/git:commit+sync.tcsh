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

set project_name = "`basename '${cwd}'`"

set sshfs_path = "/projects/ssh"

set ssh_user = "dreams"
set ssh_server = "avalon.ocssolutions.com"

git add .

# Remove any vim, GTK-PHP-IDE, gedit, or etc 'swp' files
foreach swp ( "`find . -iregex .\*\.swp`" )
	set swp = "`echo '${swp}' | sed 's/^\.\///'`"
	git rm --cached --quiet "${swp}"
end

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

	# compare "${sshfs_path}/${project_name}/" against ./
	# and remove remote files that no longer exist locally.
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
	# TODO:
	# make copying use a find search result that skips swp files.
	cp -r --verbose --update ./* "${sshfs_path}/${project_name}"

	# cleaning up swp files that may have been copied to the remote location
	foreach swp ( "`find . -iregex .\*\.swp`" )
		set swp = "`echo '${swp}' | sed 's/^\.\///'`"
		rm --verbose "${sshfs_path}/${project_name}/${swp}"
	end

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
