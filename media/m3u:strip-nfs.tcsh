#!/bin/tcsh -f
if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" == ".m3u" && -e "${1}" ) ) then
	printf "Usage: %s playlist.m3u [m3uine/playlist/filename.m3u]" "`basename '${0}'`";
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" != ".m3u" ) printf "\n\t**ERROR:** %s is not a valid m3u playlist." "${1}";
	exit -1;
endif
if( ! ${?eol} ) setenv eol '$';

if( ! ( ${?2} && "${2}" != "" && "`printf "\""${2}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/g'`" == ".m3u" ) ) then
	set playlist="`printf "\""${1}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.m3u\)${eol}/\1\2\.local\.m3u/'`";
else
	set playlist="${2}";
endif
if( "${1}" == "${playlist}" ) then
	printf "Failed to generate nfs m3u filename.";
	exit -1;
endif

printf "Converting %s to %s" ${1} ${playlist};

printf "" >! "${playlist}";
ex -E -n -s -X "+0r ${1}" '+wq!' "${playlist}";
ex -E -n -s -X '+1,$s/^\(\/.*\)\/nfs\/\(.*\)\/\([^\/]\+\)\.\([^\.]\+\)$/\1\/\2\/\3\.\4/' '+wq!' "${playlist}";

printf "\t[done]\n";

