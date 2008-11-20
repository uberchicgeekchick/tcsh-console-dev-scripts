#!/usr/bin/tcsh -f
set cp_or_mv = `basename "${0}" | sed 's/^\([^:]\+\):.*$/\1/'`
set target_dir = ""
if ( `echo "${argv[${#argv}]}" | sed 's/\(.\)$/\1/'` == "/"  ) then
	set target = "${argv[${#argv}]}"
else
	set target_dir = `dirname "${argv[${#argv}]}"`
endif
if ( ! -d "${target_dir}" ) mkdir -p "${target_dir}"
${cp_or_mv} ${argv}
