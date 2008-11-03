#!/usr/bin/tcsh
foreach dir ( `find ./ -type d` )
	if ( `echo "${dir}" | sed ''` )
