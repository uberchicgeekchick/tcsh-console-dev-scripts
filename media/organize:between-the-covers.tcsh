#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" && -d "${1}" )) then
	printf "Usage: %s [directory]", "`basename ${0}`";
	exit -1;
endif

set folder=`echo ${1} | sed 's/\(['\'']\)/\\\1/g'`;
set title=`basename "${1}" | sed 's/\(['\'']\)/\1\\\1\1/g'`;

foreach episode ( "`find "\""${folder}"\"" -iregex '.*.*\.\(mp.\|ogg\|flac\)'`" )
	set chapter = "`printf "\""${episode}"\"" | sed 's/.*\/[^0-9\/]\+\([0-9]\+\)\([^\.]*\)\.\(mp.\|ogg\|flac\)/\1/g' | sed -r 's/^0//'`";
	#echo "-->$chapter.\n";
	if( $chapter < 10 && `printf "${chapter}" | wc -m` == 1 ) set chapter="0${chapter}";
	set extension = "`printf "\""${episode}"\"" | sed 's/.*\.\(mp.\|ogg\|flac\)/\1/g'`";
	mv "${episode}" "${folder}/${title} -.chapter ${chapter}.${extension}";
end

