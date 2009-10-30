#!/bin/tcsh -f
set path_to_progies="/projects/cli/media";
set path_to_playlists="/media/library/playlists";

if(!( ${?1} && "${1}" != "" && ( "${1}" == "--import" || "${1}" == "--export" ) )) then
	goto usage
endif

if(!( ${?2} && "${2}" != "" )) then
	goto usage
endif
if(!( "`printf "\""${2}"\"" | sed 's/.*\(tox\)${eol}/\1/g'`" == "tox" )) then
	if(!( "`printf "\""${2}"\"" | sed 's/.*\(m3u\)${eol}/\1/g'`" == "m3u" )) then
		set m3u;
		if( "${1}" == "--import" ) then
			set playlist="${path_to_playlists}/nfs/m3u/podcasts.local.m3u";
		else if( "${1}" == "--export" ) then
			set playlist="${path_to_playlists}/m3u/podcasts.nfs.m3u";
		endif
	else
		set m3u;
		set playlist="${2}";
	endif
	if(! ${?playlist} ) then
		set toxine;
		if( "${1}" == "--import" ) then
			set playlist="${path_to_playlists}/nfs/tox/podcasts.local.tox";
		else if( "${1}" == "--export" ) then
			set playlist="${path_to_playlists}/tox/podcasts.nfs.tox";
		endif
	endif
else
	set toxine;
	set playlist="${2}";
endif
	switch( ${1} )
	case "--export":
			${path_to_progies}/tox:strip-nfs.tcsh  "${path_to_playlists}/nfs/tox/podcasts.local.tox";
		breaksw
	case "--import":
			${path_to_progies}/tox:add-nfs.tcsh  "${path_to_playlists}/tox/podcasts.nfs.tox";
		breaksw
	endsw
	switch( ${1} )
	case "--export":
			${path_to_progies}/m3u:strip-nfs.tcsh "${path_to_playlists}/m3u/podcasts.nfs.m3u" "${path_to_playlists}/nfs/m3u/podcasts.local.m3u";
		breaksw
	case "--import":
			${path_to_progies}/m3u:add-nfs.tcsh "${path_to_playlists}/nfs/m3u/podcasts.local.m3u" "${path_to_playlists}/m3u/podcasts.nfs.m3u";
		breaksw
	endsw
endif


${path_to_progies}/m3u-to-tox.tcsh "${path_to_playlists}/m3u/podcasts.nfs.m3u" "${path_to_playlists}/tox/podcasts.nfs.tox";
${path_to_progies}/tox:strip-nfs.tcsh "${path_to_playlists}/tox/podcasts.nfs.tox" "${path_to_playlists}/nfs/tox/podcasts.local.tox";

exit 0;

usage:
	printf "%s --[import|export] /path/to/playlist";
	exit -1;

