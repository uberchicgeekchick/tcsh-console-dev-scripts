#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" && -d "${1}" )) then
	printf "Usage: %s [directory]", "`basename ${0}`";
	exit -1;
endif
set folder=`echo ${1} | sed 's/\(['\'']\)/\\\1/g'`;

foreach title ( "`find "\""${folder}"\"" -iregex '.*, released on.*\.\(mp.\|ogg\|flac\)'`" )
	set song = "`printf "\""${title}"\"" | sed 's/\(.*\)\(, released on[^\.]*\)\.\(mp.\|ogg\|flac\)/\1/g'`";
	set extension = "`printf "\""${title}"\"" | sed 's/.*\.\(mp.\|ogg\|flac\)/\1/g'`";
	mv "${title}" "${song}.${extension}";
end

