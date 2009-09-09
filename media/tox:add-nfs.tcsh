#!/bin/tcsh -f
if( ! ( ${?1} && "${1}" != "" && "`printf '${1}' | sed 's/.*\(\.tox\)${eol}/\1/'`" == ".tox" && -e "${1}" ) ) then
	printf "Usage: %s playlist.tox [m3u/playlist/filename.tox]" "`basename '${0}'`";
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)${eol}/\1/'`" != ".tox" ) printf "\n\t**ERROR:** %s is not a valid toxine playlist." "${1}";
	exit -1;
endif
if( ! ${?eol} ) setenv eol '$';

if( ! ( ${?2} && "${2}" != "" && "`printf '${2}' | sed 's/.*\(\.tox\)${eol}/\1/g'`" == ".tox" ) ) then
	set playlist="`printf "\""${1}"\"" | sed 's/\(.*\)\(\.tox\)${eol}/\1.nfs\.tox/'`";
else
	set playlist="${2}";
endif
if( "${1}" == "${playlist}" ) then
	printf "Failed to generate nfs tox filename.";
	exit -1;
endif

printf "Converting %s to %s" ${1} ${playlist};

printf "" >! "${playlist}";
ex -E -n -s -X "+1r ${1}" '+wq!' "${playlist}";
ex -E -n -s -X '+3,$s/^\(\tmrl\ =\ \/media\/podcasts\)\/\(.*\)\/\([^\/]\+\)\.\([^\.]\+\);$/\1\/nfs\/\2\/\3\.\4;/' '+wq!' "${playlist}";

printf "\t[finished]";

