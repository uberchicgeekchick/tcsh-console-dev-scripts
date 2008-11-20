#!/usr/bin/tcsh -f
set target_dir = `dirname "${argv[${#argv}]}"`
set cp_or_mv = `basename "${0}" | sed 's/^\([^:]\+\):.*$/\1/'`
if ( ! -d "${target_dir}" ) mkdir -p "${target_dir}"
${cp_or_mv} ${argv}
