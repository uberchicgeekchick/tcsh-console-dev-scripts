#!/bin/tcsh -f
if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)${eol}/\1/'`" == ".tox" && -e "${1}" ) ) then
	printf "Usage: %s playlist.tox [toxine/playlist/filename.m3u]" "`basename '${0}'`";
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)${eol}/\1/'`" != ".tox" ) printf "\n\t**ERROR:** %s is not a valid toxine playlist." "${1}";
	exit -1;
endif
if( ! ${?eol} ) setenv eol '$';

if( ! ( ${?2} && "${2}" != "" && "`printf "\""${2}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/g'`" == ".m3u" ) ) then
	set playlist="`printf "\""${1}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.tox\)${eol}/\1\2\.local\.m3u/'`";
else
	set playlist="${2}";
endif
if( "${1}" == "${playlist}" ) then
	printf "Failed to generate m3u filename.";
	exit -1;
endif

printf "Converting %s to %s" ${1} ${playlist};

printf "" >! "${playlist}";
set tox_playlist="`printf '%s' '${1}' | sed 's/\([()\ ]\)/\\\1/g'`";
ex -E -n -s -X "+1r ${tox_playlist}" '+wq!' "${playlist}";
ex -E -n -s -X '+1,$s/^\#.*[\r\n]//' '+2,$s/^entry\ {[\r\n]\+//' '+2,$s/^};$//' '+2,$s/^\tmrl\ =\ \(\/.*\)\/nfs\/\(.*\)\/\([^\/]\+\)\.\([^\.]\+\);$/\1\/\2\/\3\.\4/' '+2,$s/^\t.*;[\r\n]\+//' '+1,$s/^[\r\n]\+//' '+$d' '+wq!' "${playlist}";

printf "\t[done]\n";

