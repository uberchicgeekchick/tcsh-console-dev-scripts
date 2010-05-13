#!/bin/tcsh -f
init:
	set scripts_basename="playlist:manager.tcsh";
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
#init:


check_dependencies:
	set dependencies=("${scripts_basename}" "playlist:new:create.tcsh" "playlist:new:save.tcsh" "playlist:convert.tcsh" "playlist:find:missing:listings.tcsh" "playlist:copy:missing:listings.tcsh" "playlist:find:non-existent:listings.tcsh");# "`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)$/\1/'`");
	@ dependencies_index=0;
	foreach dependency(${dependencies})
		@ dependencies_index++;
		unset dependencies[$dependencies_index];
		if( ${?debug} || ${?debug_dependencies} ) \
			printf "\n**${scripts_basename} debug:** looking for dependency: ${dependency}.\n\n"; 
			
		foreach program("`where '${dependency}'`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		if(! ${?program} ) then
			@ errno=-501;
			printf "One or more required dependencies couldn't be found.\n\t[${dependency}] couldn't be found.\n\t${scripts_basename} requires: ${dependencies}\n";
			goto exit_script;
		endif
		
		if( ${?debug} || ${?debug_dependencies} ) then
			switch( "`printf "\""%d"\"" "\""${dependencies_index}"\"" | sed -r 's/^[0-9]*[^1]?([1-3])"\$"/\1/'`" )
				case "1":
					set suffix="st";
					breaksw;
				
				case "2":
					set suffix="nd";
					breaksw;
				
				case "3":
					set suffix="rd";
					breaksw;
				
				default:
					set suffix="th";
					breaksw;
			endsw
			
			printf "**${scripts_basename} debug:** found ${dependencies_index}${suffix} dependency: ${dependency}.\n";
			unset suffix;
		endif
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?scripts_dirname} ) \
					breaksw;
				
				set old_owd="${cwd}";
				cd "`dirname '${program}'`";
				set scripts_dirname="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_dirname}/${scripts_basename}";
				breaksw;
			
			default:
				breaksw;
			
		endsw
		
		unset program;
	end
	
	unset dependency dependencies dependencies_index;
#check_dependencies:

while( "${1}" != "" )
	set option = "`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-{2}([^\=]+)\=?(.*)/\1/g'`";
	set value = "`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-{2}([^\=]+)\=?(.*)/\2/g'`";
	if( "${value}" == "" && "${2}" != "" ) \
		set value="${2}";
	#printf "Checking\n\toption: %s\n\tvalue %s\n" "${option}" "${value}";
	
	switch ( "${option}" )
		case "help"
			goto usage;
			breaksw;
		
		case "debug":
			if(! ${?debug} ) \
				set debug;
			breaksw;
		
		case "clean-up":
			if(! ${?clean_up} ) \
				set clean_up;
			breaksw;
		
		case "auto-copy":
			if(! ${?auto_copy} ) \
				set auto_copy;
			breaksw;
		
		case "verbose":
			if(! ${?be_verbose} ) \
				set be_verbose;
			breaksw;
		
		case "import":
			if( -e "${value}" ) \
				set import="${value}";
			breaksw;
		
		case "export":
		case "export-to":
			set export_to="${value}";
			breaksw;
		
		case "edit-playlist":
			set edit_playlist;
			breaksw;
		
		case "target-directory":
			if( -d "${value}" ) \
				set target_directory="${value}"
			breaksw;
		
		case "recursive":
			set maxdepth="--recursive";
			breaksw;
		
		case "maxdepth":
			if( ${?maxdepth} ) \
				breaksw;
			
			if( ${value} != "" && `printf '%s' "${value}" | sed -r 's/^([\-]).*/\1/'` != "-" ) then
				set value=`printf '%s' "${value}" | sed -r 's/.*([0-9]+).*/\1/'`
				if( ${value} > 2 ) \
					set maxdepth=" --maxdepth=${value} ";
			endif
			if(! ${?maxdepth} ) \
				printf "--maxdepth must be an integer value that is gretter than 2" > /dev/stderr;
			breaksw;
		
		case "playlist":
			set playlist="${value}";
			breaksw;
		
		case "validate":
			set validate;
			breaksw;
		
		default:
			if( ! ${?playlist} && "${2}" == "" && -e "${value}" ) \
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
	if(! -e "${playlist}" )	then
		printf "**error:** an existing playlist must be specified.\n" > /dev/stderr;
		@ errno=-2;
		goto exit_script;
	endif	
endif

if( ${?export_to} && ${?import} ) then
	printf "**error:** you cannot import and export a playlist at the same time.\nPlease choose to either import or export a playlist and than export or import the playlist created by your initial playlist import or export.\n" > /dev/stderr;
	@ errno=-3;
	goto exit_script;
endif

set playlist_type="`printf "\""${playlist}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`";
switch( "${playlist_type}" )
	case "m3u":
	case "tox":
	case "pls":
		breaksw;
	
	default:
		printf "**error:** [%s] is an unsupported playlist type: [%s].\n" "${playlist}" "${playlist_type}" > /dev/stderr;
		unset playlist playlist_type;
		@ errno=-2;
		goto exit_script;
		breaksw;
endsw

import:
if( ${?import} ) then
	if( "${import}" == "${playlist}" ) then
		printf "**error** [%s] and [%s] are the same file.\nImporting playlist:\t\t[failed]\n" "${import}" "${playlist}"
		set status=-4;
		goto exit_script;
	endif
	
	if(! -e "${import}" ) then
		printf "**error:** [%s] does not exist/could not be found.\nImporting <file://%s>:\t\t[failed]\n" "${import}" "${import}" > /dev/stderr;
		@ errno=-3;
		goto exit_script;
	endif
	
	set import_type="`printf "\""${import}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`";
	switch( "${import_type}" )
		case "m3u":
		case "tox":
		case "pls":
			if( "${import_type}" == "${playlist_type}" ) then
				cp -vf "${import}" "${playlist}";
			else
				playlist:convert.tcsh --force "${import}" "${playlist}";
			endif
			if( ${?edit_playlist} ) \
				${EDITOR} "${playlist}";
			breaksw;
		
		default:
			printf "**error:** [%s] cannot by imported. It is an unsupported playlist type: [%s].\n" "${import}" "${import_type}" > /dev/stderr;
			unset import import_type;
			@ errno=-2;
			goto exit_script;
			breaksw;
	endsw
	unset import_type;
endif
#import:

export:
if( ${?export_to} ) then
	if( "${export_to}" == "${playlist}" ) then
		printf "**error** [%s] and [%s] are the same file.\nExporting playlist:\t\t[failed]\n" "${export_to}" "${playlist}"
		set status=-4;
		goto exit_script;
	endif
	
	if(! -e "${playlist}" ) then
		printf "**error:** [%s] does not exist/could not be found.\nCannot export a non-existing playlist.\nExporting playlist:\t\t[failed]\n" "${playlist}" > /dev/stderr;
		@ errno=-3;
		goto exit_script;
	endif
	
	set export_type="`printf "\""${export_to}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`";
	switch( "${export_type}" )
		case "m3u":
		case "tox":
		case "pls":
			if( ${?edit_playlist} ) \
				${EDITOR} "${playlist}";
			if( "${export_type}" == "${playlist_type}" ) then
				cp -vf "${playlist}" "${export_to}";
			else
				playlist:convert.tcsh --force "${playlist}" "${export_to}";
			endif
			breaksw;
		
		default:
			printf "**error:** [%s] cannot by exported. It is an unsupported playlist type: [%s].\n" "${export}" "${export_type}" > /dev/stderr;
			unset export export_type;
			@ errno=-2;
			goto exit_script;
			breaksw;
	endsw
	unset export_type;
endif
#export:

clean_up:
	if(! ${?clean_up} ) \
		goto get_missing;
	
	if(! ${?maxdepth} ) \
		set maxdepth="--search-subdirs-only";
	
	if(! ${?target_directory} ) \
		set target_directory="${cwd}";
	
	printf "Checking for any files found under: [%s] which are not listed in [%s]:\n" "${target_directory}" "${playlist}";
	playlist:find:missing:listings.tcsh "${playlist}" "${target_directory}" ${maxdepth} --skip-subdir=nfs --check-for-duplicates-in-subdir=nfs --extensions='(mp3|ogg|m4a)' --remove=interactive;
#clean_up:

get_missing:
	if( ${?auto_copy} || ${?import} ) \
		playlist:copy:missing:listings.tcsh "${playlist}";
#get_missing:


exit_script:
	if( ${?echo_set} ) then
		unset echo;
		unset echo_set;
	endif
	
	if( ${?debug} ) \
		unset debug;
	
	if( ${?be_verbose} ) \
		unset be_verbose;
	
	if( ${?auto_copy} ) \
		unset auto_copy;
	
	if( ${?import} ) \
		unset import;
	
	if( ${?export_to} ) \
		unset export_to;
	
	if( ${?edit_playlist} ) \
		unset edit_playlist;
	
	if( ${?target_directory} ) \
		unset target_directory;
	
	if( ${?clean_up} ) \
		unset clean_up;
	
	if( ${?maxdepth} ) \
		unset maxdepth;
	
	if( ${?playlist} ) \
		unset playlist;
	
	if( ${?scripts_basename} ) \
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


