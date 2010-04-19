#!/bin/tcsh -f
if( "${1}" != "" && "${1}" == "--edit-playlist" ) then
	set edit_playlist;
	shift;
endif

if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)"\$"/\1/'`" == ".tox" && -e "${1}" ) ) then
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)"\$"/\1/'`" != ".tox" ) printf "\n\t**ERROR:** %s is not a valid toxine playlist." "${1}";
	printf "Usage: %s playlist.tox [toxine/playlist/filename.m3u]" "`basename '${0}'`";
	exit -1;
endif

set tox_playlist="${1}";
shift;

if( ! ${?eol} ) setenv eol '$';

if( ! ( "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)"\$"/\1/g'`" == ".m3u" ) ) then
	set m3u_playlist="`printf "\""${tox_playlist}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.tox\)"\$"/\1\2\.m3u/'`";
else
	set m3u_playlist="${1}";
	shift;
endif

set insert_subdir="";
if( "`printf '%s' "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`" == "insert-subdir" ) then
	set insert_subdir="`printf '%s' "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/' | sed -r 's/^\///' | sed -r 's/\/"\$"//' | sed -r 's/\//\\\//'`\/";
	if( "${insert_subdir}" == "" ) unset insert_subdir;
	shift;
endif

if( "`printf '%s' "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`" == "strip-subdir" ) then
	set strip_subdir="`printf '%s' "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/' | sed -r 's/^\///' | sed -r 's/\/"\$"//' | sed -r 's/\//\\\//'`\/";
	if( "${strip_subdir}" == "" ) then
		unset strip_subdir;
	else if( "${strip_subdir}" == "${insert_subdir}" ) then
		set insert_subdir="";
		unset strip_subdir;
	endif
	shift;
endif

if( "${tox_playlist}" == "${m3u_playlist}" ) then
	printf "Failed to generate tox filename.";
	exit -1;
endif

if( ${?edit_playlist} ) ${EDITOR} "${tox_playlist}";

printf "Converting %s to %s" "${tox_playlist}" "${m3u_playlist}";

alias	ex	"ex -E -n -s -X --noplugin";

printf "" >! "${m3u_playlist}";
set tox_playlist="`printf '%s' '${tox_playlist}' | sed 's/\([()\ ]\)/\\\1/g'`";
ex "+1r ${tox_playlist}" '+wq!' "${m3u_playlist}";
ex '+1,$s/^\#.*[\r\n]//' '+2,$s/^entry\ {[\r\n]\+//' '+2,$s/^};$//' "+2,"\$"s/^\tmrl\ =\ \(\/[^\/]\+\/[^\/]\+\/\)\(.*\)\/\([^\/]\+\)\.\([^\.]\+\);"\$"/\1${insert_subdir}\2\/\3\.\4/" '+2,$s/^\t.*;[\r\n]\+//' '+1,$s/^[\r\n]\+//' '+$d' '+wq' "${m3u_playlist}";

if( ${?strip_subdir} ) then
	ex "+3,"\$"s/\v^(\/[^\/]+\/[^\/]+\/)${strip_subdir}\/(.*)\/([^\/]+)\.([^;]+);"\$"/\1\2\/\3\.\4;/" '+wq' "${m3u_playlist}";
endif

printf "\t[done]\n";

