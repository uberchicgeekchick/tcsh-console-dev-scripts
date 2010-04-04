#!/bin/tcsh -f
#if(! ${?1} || "${1}" == "" ) goto usage

set edit_playlist="";
while( "${1}" != "" )
	set option = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\1/g'`";
	set value = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\2/g'`";
	if( "${value}" == "" )	\
		set value="${2}";
	#echo "Checking\n\toption: ${option}\n\tvalue ${value}\n";
	
	switch ( "${option}" )
		case "import":
			if( -e "${value}" )	\
				set import="${value}";
			breaksw;
		
		case "export":
			set export="${value}";
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
			if( -e "${value}" && ! ${?playlist} )	\
				set playlist="${value}";
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

if( ${?import} ) then
	if(! -e "${import}" ) then
		printf "Cannot export a non-existing playlist.\n" > /dev/null;
		exit -3;
	endif
	
	switch( "`printf "\""${import}"\"" | sed 's/.*\.\([^\.]\+\)${eol}/\1/'`" )
		case "m3u":
			m3u-to-tox.tcsh${edit_playlist} "${import}" "${playlist}";
			breaksw;
		
		case "tox":
			tox-to-m3u.tcsh${edit_playlist} "${import}" "${playlist}";
			breaksw;
	endsw
endif

if( ${?export} ) then
	if(! -e "${playlist}" ) then
		printf "Cannot export a non-existing playlist.\n" > /dev/null;
		exit -3;
	endif
	
	switch( "`printf "\""${playlist}"\"" | sed 's/.*\.\([^\.]\+\)${eol}/\1/'`" )
		case "m3u":
			m3u-to-tox.tcsh${edit_playlist} "${playlist}" "${export}";
			breaksw;
		
		case "tox":
			tox-to-m3u.tcsh${edit_playlist} "${playlist}" "${export}";
			breaksw;
	endsw
endif

clean_up:
	pls-tox-m3u:find:missing.tcsh "${playlist}" "${target_directory}" --search-subdirs-only --skip-subdir=nfs --check-for-duplicates-in-subdir=nfs --extensions='\(mp3\|ogg\)' --remove=interactive;
	
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

