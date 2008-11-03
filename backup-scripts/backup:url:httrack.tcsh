#!/bin/tcsh
if ( "${1}" == "0" ) then
	printf "Usage: %s URI\n"
	exit -1
endif
httrack http://wiki.blender.org/index.php/Manual/Introduction -O "Blender's Manual" --cookies=1 -a -S -%I +wiki.blender.org/uploads*
httrack "${1}" --mirror --ext-depth=0 --stay-on-same-address --can-go-down --include-query-string
