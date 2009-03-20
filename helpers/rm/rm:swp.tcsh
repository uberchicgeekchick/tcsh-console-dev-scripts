#!/usr/bin/tcsh -f
# cleaning up VIM, gedit, connectED, & etc swp files.
foreach swp ( "`find . -iregex .\*\.sw.`" )
	rm --verbose "${swp}"
end
