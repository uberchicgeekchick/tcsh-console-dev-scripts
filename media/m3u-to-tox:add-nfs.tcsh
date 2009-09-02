#!/bin/tcsh -f
if( ! ( ${?1} && "${1}" != "" && "`printf '${1}' | sed 's/.*\(\.m3u\)${eol}/\1/'`" == ".m3u" && -e "${1}" ) ) then
	printf "Usage: %s playlist.m3u [toxine/playlist/filename.tox]" "`basename '${0}'`";
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" != ".m3u" ) printf "\n\t**ERROR:** %s is not a valid m3u playlist." "${1}";
	exit -1;
endif
if( ! ${?eol} ) setenv eol '$';

if( ! ( ${?2} && "${2}" != "" && "`printf '${2}' | sed 's/.*\(\.tox\)${eol}/\1/g'`" == ".tox" ) ) then
	set playlist="`printf "\""${1}"\"" | sed 's/\(.*\)\/\([^\/]\+\)\(\.m3u\)${eol}/\1\/\2\.nfs\.tox/'`"
else
	set playlist="${2}";
endif
if( "${1}" == "${playlist}" ) then
	printf "Failed to generate tox filename.";
	exit -1;
endif

printf "Converting %s to %s" ${1} ${playlist};

printf '#toxine playlist\n\n' >! "${playlist}";
ex -E -n -s "+2r ${1}" '+wq!' "${playlist}";
ex -E -n -s '+3,$s/^\#.*[\r\n]//' '+3,$s/^\(\/media\/[^\/]\+\)\/\(.\+\)\/\([\/]\+\)$/entry \{\r\tidentifier\ =\ \3;\r\tmrl\ =\ \1\/nfs\/\2\/\3;\r\tav_offset\ =\ 3600;\r};\r/' '+wq!' "${playlist}";

printf "\t[finished]";

