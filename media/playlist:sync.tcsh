#!/bin/tcsh -f
#if(! ${?1} || "${1}" == "" ) goto usage

set edit_playlist="";
while( "${1}" != "" )
	set option = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\1/g'`";
	set value = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\2/g'`";
	#echo "Checking ${option}\n";
	
	switch ( "${option}" )
		case "convert":
			if( -e "${value}" )	\
				set convert="${value}";
			breaksw;
		
		case "edit-playlist":
			set edit_playlist=" --edit-playlist";
			breaksw;
		
		case "save-to":
		case "target-dir":
		case "target-directory":
			if( -d "${value}" ) \
				set target_directory="${value}"
			breaksw;
		
		case "copy-missing-from-nfs":
		case "auto-copy-missing":
		case "copy-missing":
		case "auto-copy":
			if(! ${?auto_copy} )	\
				set auto_copy;
			breaksw;
		
		case "playlist":
			if(! ${?playlist} )	\
				set playlist="${value}";
			breaksw;
		
		default:
			if(! ${?playlist} )	\
				set playlist="${1}";
			breaksw;
	endsw
	shift;
end

if(! ${?playlist} ) then
	printf "**error:** a valid target playlist must be specified.\n" > /dev/stderr;
	exit -1;
endif

if(! ${?target_directory} )	\
	set target_directory="${cwd}";

if(! ${?eol} )	\
	set eol='$';

switch( "`printf "\""${playlist}"\"" | sed 's/.*\.\([^\.]\+\)${eol}/\1/'`" )
	case "m3u":
		set playlist_type="m3u";
		breaksw;
	
	case "tox":
		set playlist_type="tox";
		breaksw;
	
	default:
		printf "**error:** unknown playlist type: [%s].\n" "`printf "\""${playlist}"\"" | sed 's/.*\.\([^\.]+\)${eol}/\1/'`" > /dev/stderr;
		exit -2;
		breaksw;
endsw

if( ${?convert} ) then
	switch( "`printf "\""${convert}"\"" | sed 's/.*\.\([^\.]\+\)${eol}/\1/'`" )
		case "m3u":
			m3u-to-tox.tcsh${edit_playlist} "${convert}" "${playlist}";
			breaksw;
		
		case "tox":
			tox-to-m3u.tcsh${edit_playlist} "${convert}" "${playlist}";
			breaksw;
	endsw
endif

clean_up:
	pls-tox-m3u:find:missing.tcsh "${playlist}" "${target_directory}" --remove=interactive --search-subdirs-only --skip-subdir=nfs --check-for-duplicates-in-subdir=nfs --extensions='\(mp3\|ogg\)' --remove=interactive;
	
	#if( "${target_directory}" != "/media/podiobooks" && "`/bin/ls /media/podiobooks/`" != 'nfs' )	\
	#	pls-tox-m3u:find:missing.tcsh "${playlist}" /media/podiobooks --search-subdirs-only --maxdepth=5 --skip-subdir=nfs --check-for-duplicates-in-subdir=nfs --extensions='\(mp3\|ogg\)' --remove=interactive;
#clean_up:

if( ${?auto_copy} ) then
	switch( "${playlist_type}" )
		case "m3u":
			m3u:copy-nfs.tcsh "${playlist}" --enable=auto-copy;
			breaksw;
		
		case "tox":
			tox:copy-nfs.tcsh "${playlist}" --enable=auto-copy;
			breaksw;
	endsw
endif

