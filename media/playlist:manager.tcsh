#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script does not support being sourced and can only be exectuted.\n" > /dev/stderr;
	@ errno=-501;
	goto exit_script;
endif

if( "${1}" == "" ) then
	printf "One or more required options are missing.\n" > /dev/stderr;
	@ errno=-502;
	goto exit_script;
endif

set edit_playlist="";
while( "${1}" != "" )
	set option = "`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-{2}([^\=]+)\=?(.*)/\1/g'`";
	set value = "`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-{2}([^\=]+)\=?(.*)/\2/g'`";
	if( "${value}" == "" && "${2}" != "" )	\
		set value="${2}";
	#printf "Checking\n\toption: %s\n\tvalue %s\n" "${option}" "${value}";
	
	switch ( "${option}" )
		case "help"
			goto usage;
			breaksw;
		
		case "debug":
			if(! ${?debug} )	\
				set debug;
			breaksw;
		
		case "clean-up":
			if(! ${?clean_up} )	\
				set clean_up;
			breaksw;
		
		case "auto-copy":
			if(! ${?auto_copy} )	\
				set auto_copy;
			breaksw;
		
		case "verbose":
			if(! ${?be_verbose} )	\
				set be_verbose;
			breaksw;
		
		case "import":
			if( -e "${value}" )	\
				set import="${value}";
			breaksw;
		
		case "export":
		case "export-to":
			set export_to="${value}";
			breaksw;
		
		case "edit-playlist":
			set edit_playlist=" --edit-playlist";
			breaksw;
		
		case "target-directory":
			if( -d "${value}" ) \
				set target_directory="${value}"
			breaksw;
		
		case "maxdepth":
			if( ${value} != "" && `printf '%s' "${value}" | sed -r 's/^([\-]).*/\1/'` != "-" ) then
				set value=`printf '%s' "${value}" | sed -r 's/.*([0-9]+).*/\1/'`
				if( ${value} > 2 )	\
					set maxdepth=" --maxdepth=${value} ";
			endif
			if(! ${?maxdepth} )	\
				printf "--maxdepth must be an integer value that is gretter than 2" > /dev/null;
			breaksw;
		
		case "playlist":
			set playlist="${value}";
			breaksw;
	endsw
	shift;
end
	
	if( ${?debug} && ${?be_verbose} ) then
		if(! ${?echo} ) then
			set echo;
			set echo_set;
		endif
	endif

if(! ${?playlist} ) then
	printf "**error:** a valid target playlist must be specified.\n" > /dev/stderr;
	@ errno=-1;
	goto exit_script;
endif

if( ${?export_to} || ! ${?import} ) then
	if( -e "${?playlist}" )	then
		printf "**error:** an existing playlist must be specified.\n" > /dev/stderr;
		@ errno=-2;
		goto exit_script;
	endif	
endif

if(! ${?target_directory} )	\
	set target_directory="${cwd}";

if(! ${?eol} ) then
	set eol_set;
	set eol='$';
endif

switch( "`printf "\""${playlist}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`" )
	case "m3u":
		set playlist_type="m3u";
		breaksw;
	
	case "tox":
		set playlist_type="tox";
		breaksw;
	
	default:
		printf "**error:** unknown playlist type: [%s].\n" "`printf "\""${playlist}"\"" | sed 's/.*\.\([^\.]+\)"\$"/\1/'`" > /dev/stderr;
		exit -2;
		breaksw;
endsw

if( ${?import} ) then
	if(! -e "${import}" ) then
		printf "Cannot import a non-existing playlist.\n" > /dev/null;
		exit -3;
	endif
	
	switch( "`printf "\""${import}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`" )
		case "m3u":
			m3u-to-tox.tcsh${edit_playlist} "${import}" "${playlist}";
			breaksw;
		
		case "tox":
			tox-to-m3u.tcsh${edit_playlist} "${import}" "${playlist}";
			breaksw;
	endsw
endif

if( ${?export_to} ) then
	if(! -e "${playlist}" ) then
		printf "Cannot export a non-existing playlist.\n" > /dev/null;
		exit -3;
	endif
	
	switch( "`printf "\""${playlist}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`" )
		case "m3u":
			m3u-to-tox.tcsh${edit_playlist} "${playlist}" "${export_to}";
			breaksw;
		
		case "tox":
			tox-to-m3u.tcsh${edit_playlist} "${playlist}" "${export_to}";
			breaksw;
	endsw
endif

clean_up:
	if(! ${?clean_up} )	\
		goto get_missing;
	
	if(! ${?maxdepth} ) then
		set maxdepth=" --maxdepth=2";
	endif
	
	pls-tox-m3u:find:missing.tcsh "${playlist}" "${target_directory}" --search-subdirs-only${maxdepth} --skip-subdir=nfs --check-for-duplicates-in-subdir=nfs --extensions='(mp3|ogg|m4a)' --remove=interactive;
	
	#if( "${target_directory}" != "/media/podiobooks" && "`/bin/ls /media/podiobooks/`" != 'nfs' )	\
	#	pls-tox-m3u:find:missing.tcsh "${playlist}" /media/podiobooks --search-subdirs-only --maxdepth=5 --skip-subdir=nfs --check-for-duplicates-in-subdir=nfs --extensions='\(mp3\|ogg\|m4a\)' --remove=interactive;
#clean_up:

get_missing:
	if(!( ${?auto_copy} || ${?import} ))	\
		goto exit_script;
	
	switch( "${playlist_type}" )
		case "m3u":
			m3u:copy-nfs.tcsh "${playlist}" --enable=auto-copy;
			breaksw;
		
		case "tox":
			tox:copy-nfs.tcsh "${playlist}" --enable=auto-copy;
			breaksw;
	endsw
#get_missing:


exit_script:
	if( ${?eol_set} ) then
		unset eol_set;
		unset eol;
	endif
	
	if( ${?echo_set} ) then
		unset echo;
		unset echo_set;
	endif
	
	if( ${?debug} )			\
		unset debug;
	
	if( ${?be_verbose} )		\
		unset be_verbose;
	
	if( ${?auto_copy} )		\
		unset auto_copy;
	
	if( ${?import} )		\
		unset import;
	
	if( ${?export_to} )		\
		unset export_to;
	
	if( ${?edit_playlist} )		\
		unset edit_playlist;
	
	if( ${?target_directory} )	\
		unset target_directory;
	
	if( ${?clean_up} )		\
		unset clean_up;
	
	if( ${?maxdepth} )		\
		unset maxdepth;
	
	if( ${?playlist} )		\
		unset playlist;
	
	if( ${?scripts_basename} )	\
		unset scripts_basename;
	
	if(! ${?errno} ) then
		set status=0;
	else
		printf "See --help for more information.\n" > /dev/stderr;
		set status=$errno;
		unset errno;
	endif
	
	exit ${status};
#exit_script:


usage:
	set scripts_basename="`basename '${0}'`";
	printf "Usage:\n\t%s [options] --playlist=[playlist]\n" "${scripts_basename}";
	printf "Supported options are:							\
		--help				Displays this screen.			\
											\
		--debug				Enables %s internal debug mode.		\
											\
		--verbose			Enables %s verbose output.		\
											\
		--playlist			The playlist to manage.			\
											\
		--edit-playlist			When importing or exporting a playlist	\
						This will cause the playlist to be	\
						opened in your default editor before	\
						its converted and imported or exported	\
											\
		--import			This specifies a playlist to import.	\
						If supplied than [playlist] will be	\
						over-written with the converted copy of	\
						the imported playlist.			\
											\
		--auto-copy			Copies any missing files in the playlist\
						from its nfs share to the local disk.	\
											\
		--export|--export-to		This specifies a file to export the	\
						the specified playlist to.  It will be	\
						over-written by the converted playlist.	\
											\
		--clean-up			Removes any files on the local disk	\
						which are not found inthe playlist	\
											\
		--target-directory		This is the directory to copy podcasts	\
						to and to check for missing podcasts	\
						in.  If not specified than it defaults	\
						to your working current directory.	\
											\
		--maxdepth			By default only one level below		\
						--target-directory is checked for	\
						missing podcasts.  This will have the	\
						clean-up script search up to this many	\
						levels below --target-directory		\
						NOTE: this corisponds directly with	\
						find's -maxdepth option			\
											\
		" "${scripts_basename}" "${scripts_basename}":
	
	goto exit_script;
#usage:


