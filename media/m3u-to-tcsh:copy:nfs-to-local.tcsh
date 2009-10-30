#!/bin/tcsh -f
if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" == ".m3u" && -e "${1}" ) ) then
	printf "Usage: %s playlist.m3u [toxine/playlist/filename.tox]" "`basename '${0}'`";
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" != ".m3u" ) printf "\n\t**ERROR:** %s is not a valid m3u playlist." "${1}";
	exit -1;
endif
if( ! ${?eol} ) setenv eol '$';

if( ! ( ${?2} && "${2}" != "" && "`printf "\""${2}"\"" | sed 's/.*\(\.tox\)${eol}/\1/g'`" == ".tcsh" ) ) then
	set playlist="`printf "\""${1}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.m3u\)${eol}/\1\2\.tcsh/'`";
else
	set playlist="${2}";
endif
if( "${1}" == "${playlist}" ) then
	printf "Failed to generate tox filename.";
	exit -1;
endif

printf "Converting %s to %s" ${1} ${playlist};

set m3u_playlist="`printf '%s' '${1}' | sed 's/\([()\ ]\)/\\\1/g'`";
printf '#\!/bin/tcsh -f\n' >! "${playlist}";
ex -E -n -s -X "+1r ${m3u_playlist}" '+wq!' "${playlist}";
ex -E -n -s -X '+2,$s/^\#.*[\r\n]//' '+2,$s/\(\/media\/podcasts\/\)\([^\/]\+\)\/.*/cp \-\-verbose -r "\1nfs\/\2" "\1\2"/' '+wq!' "${playlist}";

cat "${playlist}" | sort | uniq > "${playlist}.tmp";
mv "${playlist}.tmp" "${playlist}";

chmod u+x "${playlist}";

printf "\t[done]\n";

