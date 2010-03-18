#!/bin/tcsh -f
# cleaning up VIM, gedit, connectED, & etc swp files.
set interactive="";
if( "${1}" != "" && "${1}" == "--interactive" )	\
	set interactive=" -i";

foreach swp ( "`/usr/bin/find -L . -iregex '.*\.\(sw.\|~\)'`" )
	rm"${interactive}" --verbose "${swp}"
end
