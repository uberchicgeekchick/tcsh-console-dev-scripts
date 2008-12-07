#!/usr/bin/tcsh -f
# cleaning up VIM, gedit, GTK-PHP-IDE, & etc swp files.
foreach swp ( "`find . -iregex .\*\.swp`" )
	rm --verbose "${swp}"
end
