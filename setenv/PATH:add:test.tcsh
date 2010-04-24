#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script cannot be sourced.\n" > /dev/stderr;
	set status=0;
	exit ${status};
endif

if(! ${?PATH} ) then
	set status=0;
	printf "%d" ${status};
	exit ${status};
endif

if(!( "${1}" != "" && -d "${1}" )) then
	printf "This script must be called with at least one directory as its 1st, or more, arguments.\n" > /dev/stderr;
	set okay_to_add_dir_to_path=-1;
	goto exit_script;
endif

set dir="${1}";
if( "`printf "\""${dir}"\"" | sed -r 's/^(\/).*"\$"/\1/'`" != "/" ) \
	set dir="${cwd}/${dir}";

set dir="`printf '${dir}' | sed -r 's/([\:])/\\\1/g'`";
set escaped_dir="`printf '${dir}' | sed -r 's/\//\\\//g'`";
if( "`printf '${PATH}' | sed 's/.*:\(${escaped_dir}\).*/\1/g'`" == "${dir}" ) then
	set okay_to_add_dir_to_path=-1;
	goto exit_script;
endif

exit_script:
	if(! ${?okay_to_add_dir_to_path} ) \
		set okay_to_add_dir_to_path=0;
	
	printf "%d" ${okay_to_add_dir_to_path};
	exit ${okay_to_add_dir_to_path};
#exit_script:

