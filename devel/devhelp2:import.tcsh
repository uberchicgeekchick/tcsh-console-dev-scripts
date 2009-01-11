#!/bin/tcsh -f
if ( ! ( "${?1}" == "1" && -d "${1}" && -e "${1}/funcref.html" ) ) goto usage_error

usage_error:
printf "Usage: %s path manual toc index\
	path		the location of manual to create a devhelp entry for.\
		-\
			--\
				-\
					--\
						-\
							\n" "`basename '${0}'`"
