#!/bin/tcsh -f
init:
	set scripts_basename="playlist:manager.tcsh";
	#set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	onintr exit_script;
	
	if(! ${?0} ) then
		@ errno=-502;
		goto exception_handler;
	endif
	
	if( "${1}" == "" ) then
		printf "One or more required options are missing.\n" > /dev/stderr;
		@ errno=-503;
		goto exception_handler;
	endif
#init:


check_dependencies:
	set dependencies=("${scripts_basename}" "playlist:new:create.tcsh" "playlist:new:save.tcsh" "playlist:convert.tcsh" "playlist:find:missing:listings.tcsh" "playlist:copy:missing:listings.tcsh" "playlist:find:non-existent:listings.tcsh" "playlist:sort:by:pubdate.tcsh");# "`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)$/\1/'`");
	@ dependencies_index=0;
	foreach dependency(${dependencies})
		@ dependencies_index++;
		if( ${?debug} || ${?debug_dependencies} ) \
			printf "\n**%s debug:** looking for dependency: %s.\n\n" "${scripts_basename}" "${dependency}"; 
			
		foreach program("`where '${dependency}'`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		switch( `printf "%d" "${dependencies_index}" | sed -r 's/^.*([0-9])$/\1/'` )
			case 1:
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
		
		if(! ${?program} ) then
			@ errno=-501;
			goto exception_handler;
		endif
			
		if( ${?debug} ) \
			printf "**%s debug:** found %s%s dependency: %s.\n" "${scripts_basename}" "${dependencies_index}" "${suffix}" "${dependency}";
		unset suffix;
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?script} ) \
					breaksw;
				
				set old_owd="${cwd}";
				cd "`dirname '${program}'`";
				set scripts_path="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_path}/${scripts_basename}";
				breaksw;
			
			default:
				breaksw;
			
		endsw
		
		unset program;
	end
	
	unset dependency dependencies dependencies_index;
#check_dependencies:


parse_argv:
	@ arg=0;
	@ argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		set option = "`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/\-{2}([^\=]+)\=?(.*)/\1/g'`";
		set value = "`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/\-{2}([^\=]+)\=?(.*)/\2/g'`";
		if( "${option}" != "" && "${value}" == "" ) then
			@ arg++;
			if( $arg < $argc ) then
				set value="$argv[$arg]";
			endif
			@ arg--;
		endif
		
		if( ${?debug} ) \
			printf "Checking:\n\toption: %s\n\tvalue %s\n\t"\$"argv[%d](=%s)\n" "${option}" "${value}" $arg "$argv[$arg]";
	
		switch ( "${option}" )
			case "help"
				goto usage;
				breaksw;
			
			case "nodeps":
				breaksw;
			
			case "debug":
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "remove":
			case "clean-up":
				switch("${value}")
					case "local":
					case "no-remote":
					case "skip:nfs":
						if(! ${?clean_up_local_disk_only} ) \
							set clean_up_local_disk_only
						
						if(! ${?clean_up} ) \
							set clean_up;
						breaksw;
					
					case "forced":
					case "verbose":
					case "interactive":
					case "silent":
					default:
						if(! ${?clean_up} ) \
							set clean_up;
						
						if( "${clean_up}" == "" ) then
							set clean_up="${value}";
						else
							set clean_up="${clean_up} --clean-up=${value}";
						endif
						breaksw;
				endsw
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
				set import="${value}";
				if(! -e "${import}" ) then
					@ errno=-601;
					goto exception_handler;
				endif
				breaksw;
			
			case "export":
			case "export-to":
				set export_to="${value}";
				if(! -d "`dirname "\""${export_to}"\""`" ) then
					@ errno=-602;
					goto exception_handler;
				endif
				breaksw;
			
			case "edit-playlist":
				set edit_playlist;
				breaksw;
			
			case "target-directory":
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
						set maxdepth="--maxdepth=${value}";
				endif
				if(! ${?maxdepth} ) then
					@ errno=-501;
					printf "--maxdepth must be an integer value that is gretter than 2" > /dev/stderr;
					goto exit_script;
				endif
				breaksw;
			
			case "playlist":
				set playlist="${value}";
				breaksw;
			
			case "validate":
				set validate;
				breaksw;
			
			default:
				if( ! ${?playlist} && ( -e "${value}" || ${?import} ) ) then
					set playlist="${value}";
				else if( ${?target_dir} && -d "${value}" ) then
					set target_dir="${value}";
				endif
				breaksw;
		endsw
	end
parse_argv:


main:
	if( ${?debug} && ${?be_verbose} ) then
		if(! ${?echo} ) then
			set echo;
			set echo_set;
		endif
	endif
	
	if(! ${?playlist} ) then
		@ errno=-401;
		goto exception_handler;
	endif
	
	if( ${?export_to} && ${?import} ) then
		@ errno=-402;
		goto exception_handler;
	endif
	
	if( ! -e "${playlist}" && ! ${?import} ) then
		@ errno=-403;
		goto exception_handler;
	endif
	
	set playlist_type="`printf "\""%s"\"" "\""${playlist}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`";
	switch( "${playlist_type}" )
		case "m3u":
		case "tox":
		case "pls":
			breaksw;
		
		default:
			@ errno=-404;
			goto exception_handler;
			breaksw;
	endsw
#main:


import:
	if(! ${?import} ) \
		goto export;
	
	if( "${import}" == "${playlist}" ) then
		@ errno=-405;
		goto exception_handler;
	endif
	
	if(! -e "${import}" ) then
		@ errno=-601;
		goto exception_handler;
	endif
	
	set import_type="`printf "\""%s"\"" "\""${import}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`";
	switch( "${import_type}" )
		case "m3u":
		case "tox":
		case "pls":
			if(! ${?auto_copy} ) \
				set auto_copy;
			
			if( "${import_type}" == "${playlist_type}" ) then
				cp -vf "${import}" "${playlist}";
			else
				playlist:convert.tcsh --force "${import}" "${playlist}";
			endif
			
			if( ${?edit_playlist} && ! ${?playlist_edited} ) then
				${EDITOR} "${playlist}";
				set playlist_edited;
			endif
			
			breaksw;
		
		default:
			@ errno=-406;
			goto exception_handler;
			breaksw;
	endsw
	unset import import_type;
#import:


export:
	if(! ${?export_to} ) \
		goto clean_up;
	
	if( "${export_to}" == "${playlist}" ) then
		@ errno=-407;
		goto exception_handler;
	endif
	
	if(! -e "${playlist}" ) then
		@ errno=-600;
		goto exception_handler;
	endif
	
	if(! -d "`dirname "\""${export_to}"\""`" ) then
		@ errno=-602;
		goto exception_handler;
	endif
	
	set export_type="`printf "\""%s"\"" "\""${export_to}"\"" | sed 's/.*\.\([^\.]\+\)"\$"/\1/'`";
	switch( "${export_type}" )
		case "m3u":
		case "tox":
		case "pls":
			if(! -d "`dirname "\""${export_to}"\""`" ) then
				@ errno=-602;
				goto exception_handler;
			endif
			
			if( ${?edit_playlist} && ! ${?playlist_edited} ) then
				${EDITOR} "${playlist}";
				set playlist_edited;
			endif
			
			if( "${export_type}" == "${playlist_type}" ) then
				cp -vf "${playlist}" "${export_to}";
			else
				playlist:convert.tcsh --force "${playlist}" "${export_to}";
			endif
			breaksw;
		
		default:
			@ errno=-408;
			goto exception_handler;
			breaksw;
	endsw
	unset export_type export;
#export:


clean_up:
	if(! ${?clean_up} ) \
		goto get_missing;
	
	if(! -e "${playlist}" ) then
		@ errno=-600;
		goto exception_handler;
	endif
	
	if(! ${?target_directory} ) then
		@ errno=-409;
		goto exception_handler;
	endif
	
	if(! -d "${target_directory}" ) then
		@ errno=-603;
		goto exception_handler;
	endif
	
	if(! ${?maxdepth} ) \
		set maxdepth="--search-subdirs-only";
	
	if( ${?edit_playlist} && ! ${?playlist_edited} ) then
		${EDITOR} "${playlist}";
		set playlist_edited;
	endif
	
	if( ${?clean_up_local_disk_only} ) then
		set skip_directory;
		set duplicate_directory;
	else
		printf "Checking for any files found under [%s] which are not listed in [%s]:\n" "${target_directory}" "${playlist}";
		set old_owd="${owd}";
		set old_cwd="${cwd}";
		cd "${target_directory}";
		while( "${cwd}" != "/" )
			if(! -d "${cwd}/nfs" ) then
				cd "..";
			else
				set skip_directory=" --skip-dir=${cwd}/nfs";
				set duplicate_directory=" --check-for-duplicates-in-dir=${cwd}/nfs";
				break;
			endif
		end
		cd "${old_cwd}";
		set owd="${old_owd}";
		unset old_owd old_cwd;
	
		if(!( ${?skip_directory} && ${?duplicate_directory} )) then
			@ errno=-410;
			goto exception_handler;
		endif
	endif
		
	playlist:find:missing:listings.tcsh "${playlist}" "${target_directory}" ${maxdepth}${skip_directory}${duplicate_directory} --extensions='(mp3|ogg|m4a)' --remove=${clean_up};
	
	unset skip_directory duplicate_directory target_directory maxdepth clean_up;
#clean_up:


get_missing:
	if(! ${?auto_copy} ) \
		goto validate;
	
	if(! -e "${playlist}" ) then
		@ errno=-600;
		goto exception_handler;
	endif
	
	if( ${?edit_playlist} && ! ${?playlist_edited} ) then
		${EDITOR} "${playlist}";
		set playlist_edited;
	endif
	
	playlist:copy:missing:listings.tcsh "${playlist}";
	unset auto_copy;
#get_missing:


validate:
	if(! ${?validate} ) \
		goto exit_script;
	
	if(! -e "${playlist}" ) then
		@ errno=-600;
		goto exception_handler;
	endif
	
	if( ${?edit_playlist} && ! ${?playlist_edited} ) then
		${EDITOR} "${playlist}";
		set playlist_edited;
	endif
	
	playlist:find:non-existent:listings.tcsh --clean-up "${playlist}";
	usset validate;
#validate:


exit_script:
	if( ${?echo_set} ) then
		unset echo;
		unset echo_set;
	endif
	
	if( ${?debug} ) \
		unset debug;
	
	if( ${?nodeps} ) \
		unset nodeps;
	
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
	if( ${?scripts_alias} ) \
		unset scripts_alias;
	if( ${?scripts_path} ) \
		unset scripts_path;
	if( ${?script} ) \
		unset script;
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
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


exception_handler:
	if(! ${?errno} ) \
		@ errno=-999;
	
	if( $errno < -400 ) then
		if(! ${?exit_on_exception} ) \
			set exit_on_exception;
	else if( $errno > -400 && $errno < -100 ) then
		if( ${?exit_on_exception} ) then
			set exit_on_exception_unset;
			unset exit_on_exception;
		endif
	endif
	
	printf "\n" > ${stderr};
	if( $errno > -400 ) \
		printf "\t" > ${stderr};
	printf "**%s error("\$"errno:%d):**\n\t" "${scripts_basename}" ${errno} > ${stderr};
	switch( $errno )
		case -401:
			printf "a valid target playlist must be specified." > ${stderr};
			breaksw;
		
		case -402:
			printf "you cannot import and export a playlist at the same time.\nPlease choose to either import or export a playlist and than export or import the playlist created by your initial playlist import or export." > ${stderr};
			breaksw;
		
		case -403:
			printf "an existing playlist must be specified." > ${stderr};
			breaksw;
		
		case -404:
			printf "[%s] is an unsupported playlist type: [%s]." "${playlist}" "${playlist_type}" > ${stderr};
			unset playlist playlist_type;
			breaksw;
		
		case -405:
			printf "%s] and [%s] are the same file.\nImporting playlist:\t\t[failed]" "${import}" "${playlist}" > ${stderr};
			breaksw;
		
		case -406:
			printf "[%s] cannot by imported. It is an unsupported playlist type: [%s]." "${import}" "${import_type}" > ${stderr};
			breaksw;
		
		case -407:
			printf "[%s] and [%s] are the same file.\nExporting playlist:\t[failed]." "${export_to}" "${playlist}" > ${stderr};
			breaksw;
		
		case -408:
			printf "[%s] cannot by exported. It is an unsupported playlist type: [%s]." "${export}" "${export_type}" > ${stderr};
			breaksw;
		
		case -409:
			printf "Clean-up requires a target directory to be specified." > ${stderr};
			breaksw;
		
		case -410:
			printf "<file://%s> cannot be cleaned up its remote directory doesn't exists and/or couldn't be found." "${target_directory}" > ${stderr};
			breaksw;
		
		case -501:
			printf "<%s>'s %d%s dependency: <%s> couldn't be found.\n\t%s requires: [%s]." "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${scripts_basename}" "${dependencies}" > ${stderr};
			unset suffix dependency dependencies dependencies_index;
			breaksw;
		
		case -502:
			printf "Sourcing is not supported. %s may only be executed." "${scripts_basename}" > ${stderr};
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided." > ${stderr};
			breaksw;
		
		case -504:
			printf "To many options have been provided." > ${stderr};
			breaksw;
		
		case -505:
			printf "%s%s%s%s is an unsupported option." "${dashes}" "${option}" "${equals}" "${value}" > ${stderr};
			unset dashes option equals value;
			breaksw;
		
		case -600:
			printf "[%s] does not exist/could not be found.\nCannot export a non-existing playlist.\nExporting playlist:\t\t[failed]" "${playlist}" > ${stderr};
			breaksw;
		
		case -601:
			printf "fatal import error:\n\t<file://%s> does not exist." "${import}" > ${stderr};
			breaksw;
		
		case -602:
			printf "fatal export error:\n\t<file://%s> target directory does not exist." "${export_to}" > ${stderr};
			breaksw;
		
		case -603:
			printf "Cannot clean-up: <file://%s> doesn't exist." "${target_directory}" > ${stderr};
			breaksw;
		
		case -604:
			printf "%sing %s is not supported." "`printf "\""%s"\"" "\""${option}"\"" | sed -r 's/^(.*)e"\$"/\1/`" "${value}" "${scripts_basename}" > ${stderr};
			breaksw;
		
		case -999:
		default:
			printf "An internal script error has occured." > ${stderr}
			breaksw;
	endsw
	printf "\n\n";
	@ last_exception_handled=$errno;
	printf "\tPlease see: "\`"${scripts_basename} --help"\`" for more information and supported options.\n" > ${stderr}
	if(! ${?debug} ) \
		printf "\tOr run: "\`"${scripts_basename} --debug"\`" to diagnose where ${scripts_basename} failed.\n" > ${stderr}
	printf "\n" > ${stderr}
	
	if( ! ${?callback} || ${?exit_on_exception} ) \
		set callback="exit_script";
	
	if( ${?exit_on_exception_unset} ) then
		unset exit_on_exception_unset;
		set exit_on_exception;
	endif
	
	goto $callback;
#@ errno=-101;
#set callback="$!";
#goto exception_handler;


