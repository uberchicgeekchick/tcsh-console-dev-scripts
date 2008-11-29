#!/bin/tcsh -f
set sshfs_path = "/projects/ssh"
set project_name = "`basename '${cwd}'`"

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
