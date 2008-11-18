#!/usr/bin/tcsh -f
foreach exec ( "`find ./* -mindepth 1 -type f -executable`" )
	chmod -x "${exec}"
end
