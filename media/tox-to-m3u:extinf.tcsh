#!/bin/tcsh -f
if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)${eol}/\1/'`" == ".tox" && -e "${1}" ) ) then
	printf "Usage: %s playlist.tox [toxine/playlist/filename.m3u]" "`basename '${0}'`";
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)${eol}/\1/'`" != ".tox" ) printf "\n\t**ERROR:** %s is not a valid toxine playlist." "${1}";
	exit -1;
endif
if( ! ${?eol} ) setenv eol '$';

if( ! ( ${?2} && "${2}" != "" && "`printf "\""${2}"\"" | sed 's/.*\(\.tox\)${eol}/\1/'`" == ".tox" ) ) then
	set playlist="`printf "\""${1}"\"" | sed 's/\(.*\)\/\([^\/]\+\)\(\.tox\)${eol}/\1\/\2\.m3u/'`";
else
	set playlist="${2}";
endif
if( "${1}" == "${playlist}" ) then
	printf "Failed to generate m3u filename.";
	exit -1;
endif

printf "Converting %s to %s" ${1} ${playlist};

printf '#EXTM3U\n' >! "${playlist}";
ex -E -n -s "+1r ${1}" '+wq!' "${playlist}";
ex -E -n -s '+2,$s/^\#.*[\r\n]//' '+2,$s/^entry\ {[\r\n]\+//' '+2,$s/^};$//' '+2,$s/^\tmrl\ =\ \(.*\)\/\([^\/]\+\)\.\([^\.]\+\);$/\#EXTINF:,\2\r\1\/\2\.\3/' '+2,$s/^\t.*;[\r\n]\+//' '+2,$s/^[\r\n]\+//' '+$d' '+wq!' "${playlist}";

printf "\t[finished]";

