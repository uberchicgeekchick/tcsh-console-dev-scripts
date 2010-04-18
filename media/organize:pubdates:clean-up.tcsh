#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script cannot be sourced and must be executed.\n" > /dev/stderr;
	set status=-501;
	exit ${status};
endif

if(!( "${1}" != "" && -d "${1}" )) then
	printf "Usage: %s [directory]", "`basename ${0}`";
	set status=-502;
	exit ${status};
endif

if( "${cwd}" != "${1}" ) then
	set old_owd="${owd}";
	cd "${1}";
endif

foreach title("`/usr/bin/find -L "\""${cwd}"\"" -regextype posix-extended -iregex '.*, released on.*\.([^\.]*)"\$"' -type f | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/[${eol}]/"\""\\${eol}"\""/g' | sed -r 's/(['\!'])/\\\1/g'`")
	set file_path="`printf "\""${title}"\"" | sed -r 's/^(.*)\/(.*)(,\ released\ on\:\ )([^\.]+)\.([^\.]+)/\1/g'`";
	set file_name="`printf "\""${title}"\"" | sed -r 's/^(.*)\/(.*)(,\ released\ on\:\ )([^\.]+)\.([^\.]+)/\2/g'`";
	set extension="`printf "\""${title}"\"" | sed -r 's/^(.*)\/(.*)(,\ released\ on\:\ )([^\.]+)\.([^\.]+)/\5/g'`";
	mv -v "${title}" "${file_path}/${file_name}.${extension}";
end

if( ${?old_owd} ) then
	cd "${owd}";
	set owd="${old_owd}";
	unset old_owd;
endif

