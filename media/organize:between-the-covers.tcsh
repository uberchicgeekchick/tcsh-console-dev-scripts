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

set books_title="`basename "\""${cwd}"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/[${eol}]/"\""\\${eol}"\""/g' | sed -r 's/(['\!'])/\\\1/g'`";

foreach episode("`/usr/bin/find -L "\""${cwd}"\"" -regextype posix-extended -iregex '.*, released on.*\.([^\.]*)"\$"' -type f | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/[${eol}]/"\""\\${eol}"\""/g' | sed -r 's/(['\!'])/\\\1/g'`")
	set books_path="`printf "\""${episode}"\"" | sed -r 's/(.*)\/[^0-9\/]+([0-9]+)([^\.]*)\.(^\.]+)/\1/g'`";
	set books_chapter="`printf "\""${episode}"\"" | sed -r 's/(.*)\/[^0-9\/]+([0-9]+)([^\.]*)\.(^\.]+)/\2/g' | sed -r 's/^0//'`";
	#echo "-->$books_chapter.\n";
	if( $books_chapter < 10 && `printf "${books_chapter}" | wc -m` == 1 )	\
		set books_chapter="0${books_chapter}";
	set extension="`printf "\""${episode}"\"" | sed 's/.*\.\([^\.]+)"\$"/\1/g'`";
	mv -v "${episode}" "${books_path}/${books_title} - chapter ${books_chapter}.${extension}";
end

if( ${?old_owd} ) then
	cd "${owd}";
	set owd="${old_owd}";
	unset old_owd;
endif

