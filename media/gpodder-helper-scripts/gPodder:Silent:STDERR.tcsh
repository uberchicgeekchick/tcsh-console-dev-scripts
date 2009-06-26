#!/bin/tcsh -f
if( ! ${?QUIT_EXEC} ) then
	( gpodder "${argv}" > /dev/tty ) >& /dev/null
else
	gpodder "${argv}" >& /dev/null
endif
