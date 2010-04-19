#!/bin/tcsh -f
if( "${1}" != "" && "${1}" == "--edit-playlist" ) then
	set edit_playlist;
	shift;
endif

if( ! ( ${?1} && "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" == ".m3u" && -e "${1}" ) ) then
	if( "`printf "\""${1}"\"" | sed 's/.*\(\.m3u\)${eol}/\1/'`" != ".m3u" ) printf "\n\t**ERROR:** %s is not a valid m3u playlist." "${1}";
	printf "Usage: %s playlist.m3u [toxine/playlist/filename.tox]" "`basename '${0}'`";
	exit -1;
endif

set m3u_playlist="${1}";
shift;

if( ! ${?eol} ) setenv eol '$';

if( ! ( "${1}" != "" && "`printf "\""${1}"\"" | sed 's/.*\(\.tox\)${eol}/\1/g'`" == ".tox" ) ) then
	set tox_playlist="`printf "\""${m3u_playlist}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.m3u\)${eol}/\1\2\.tox/'`";
else
	set tox_playlist="${1}";
	shift;
endif

set insert_subdir="";
if( "`printf '%s' "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`" == "insert-subdir" ) then
	set insert_subdir="`printf '%s' "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/' | sed -r 's/^\///' | sed -r 's/\/${eol}//' | sed -r 's/\//\\\//'`\/";
	if( "${insert_subdir}" == "" )	\
		unset insert_subdir;
	shift;
endif

if( "`printf '%s' "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`" == "strip-subdir" ) then
	set strip_subdir="`printf '%s' "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/' | sed -r 's/^\///' | sed -r 's/\/${eol}//' | sed -r 's/\//\\\//'`\/";
	if( "${strip_subdir}" == "" ) then
		unset strip_subdir;
	else if( "${strip_subdir}" == "${insert_subdir}" ) then
		set insert_subdir="";
		unset strip_subdir;
	endif
	shift;
endif

if( "${m3u_playlist}" == "${tox_playlist}" ) then
	printf "Failed to generate tox filename.";
	exit -1;
endif

if( ${?edit_playlist} ) ${EDITOR} "${tox_playlist}";

printf "Converting %s to %s" "${m3u_playlist}" "${tox_playlist}";

alias	ex	"ex -E -n -X -s --noplugin";

set m3u_playlist="`printf '%s' '${m3u_playlist}' | sed 's/\([()\ ]\)/\\\1/g'`";
printf '#toxine playlist\n\n' >! "${tox_playlist}";
ex "+2r ${m3u_playlist}" '+wq!' "${tox_playlist}";
ex '+3,$s/^\#.*[\r\n]//' "+3,"\$"s/\v^(\/[^\/]+\/[^\/]+\/)(.*)\/([^\/]+)\.([^\.]+)"\$"/entry \{\r\tidentifier\ =\ \3;\r\tmrl\ =\ \1${insert_subdir}\2\/\3\.\4;\r\tav_offset\ =\ 3600;\r};\r/" '+wq' "${tox_playlist}";

if( ${?strip_subdir} ) then
	ex "+3,"\$"s/\v^(\tmrl\ \=\ \/[^\/]+\/[^\/]+\/)'${strip_subdir}'(.*)\/([^\/]+)\.([^;]+);"\$"/\1\2\/\3\.\4;/" '+wq' "${tox_playlist}";
endif

printf '#END' >> "${tox_playlist}";

printf "\t[done]\n";

