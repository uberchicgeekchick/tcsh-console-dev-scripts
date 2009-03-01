#!/bin/tcsh
if ( !${?1} || "${1}" == "" ) then
	printf "Usage: %s URI\n"
	exit -1
endif
#httrack http://wiki.blender.org/index.php/Manual/Introduction -O "Blender's Manual" --cookies=1 -a -S -%I +wiki.blender.org/uploads*
set url = "${1}"
shift
set argv = "`printf '${argv}' | sed 's/\(["\""'\'']\)/\1\1\1/g'`"
set tld = "`printf '${url}' | sed 's/^[:]\+:\/\/\([^\/]\+\)\/\(.*\)/\1/g'`"
httrack "${url}" -O "${tld}" --mirror --ext-depth=0 --stay-on-same-address --stay-on-same-dir --can-go-down --include-query-string --search-index --cookies=1 "${argv}"
