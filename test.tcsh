#!/bin/tcsh -f
foreach remote_file ( "`find ./ -maxdepth 1`" )
	set git_test = `echo "${remote_file}" | sed 's/.*\(\/\.git\).*/\1/g'`
	if ( "${git_test}" == "/.git" ) continue
	echo "${git_test}"
end
