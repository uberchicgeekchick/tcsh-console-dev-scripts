#!/bin/tcsh -f
init:
	onintr exit_script;
	
	set scripts_basename="playlist:find:missing:listings.tcsh";
	#set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	
	if(! ${?0} ) then
		@ errno=-501;
		goto exception_handler;
	endif
	
	set argc=${#argv};
	if( ${argc} < 1 ) then
		@ errno=-503;
		goto exception_handler;
	endif
	
	set extensions="";
#init:


check_dependencies:
	set dependencies=("${scripts_basename}" "playlist:sort:by:pubdate.tcsh");# "`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)$/\1/'`");
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
		
		if(! ${?program} ) then
			@ errno=-501;
			printf "One or more required dependencies couldn't be found.\n\t[%s] couldn't be found.\n\t%s requires: %s\n" "${dependency}" "${scripts_basename}" "${dependencies}";
			goto exception_handler;
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
			
			printf "**%s debug:** found %s%s dependency: %s.\n" "${scripts_basename}" "${dependencies_index}" "${suffix}" "${dependency}";
			unset suffix;
		endif
		
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
	goto parse_argv;
#check_dependencies:


main:
	if(! ${?playlists} ) then
		@ errno=-4;
		goto exception_handler;
	endif
	
	set playlists_array="`cat "\""${playlists}"\""`";# | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	rm -f "${playlists}";
	set playlists=($playlists_array);
	unset playlists_array;
	
	if(! ${?target_directories} ) then
		@ errno=-5;
		goto exception_handler;
	endif
	
	set target_directories_array="`cat "\""${target_directories}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";# | sed -r 's/(.*)/"\""\1"\""/'`";;
	rm -f "${target_directories}";
	set target_directories=($target_directories_array);
	unset target_directories_array;
	
	if(! ${?remove} ) then
		set removal_verbose;
		set remove;
	endif
	
	if(! ${?maxdepth} ) \
		set maxdepth=" -maxdepth 2";
	
	if(! ${?mindepth} ) \
		set mindepth=" ";
	
	if(! ${?extensions} ) \
		set extensions="";
	
	if(! ${?regextype} ) \
		set regextype="posix-extended";
	
	if( ${?edit_playlist} ) then
		foreach playlist(${playlists})
			${EDITOR} "${playlist}";
		end
		unset playlist;
	endif
#main:


setup_playlist_new:
	foreach playlist(${playlists})
		playlist:new:create.tcsh "$playlist";
		unset playlist;
	end
#setup_playlist_new:


create_clean_up_script:
	if( ${?create_script} ) then
		if( "${create_script}" == "" ) \
			set create_script="script-to:remove:missing:listings:found-on:`date '+%s'`.tcsh";
		if(! -e "${create_script}" ) then
			printf "#\!/bin/tcsh -f\n" > "${create_script}";
			chmod u+x "${create_script}";
		endif
	endif
#create_clean_up_script:


find_missing_media:
	set old_owd="${owd}";
	set old_cwd="${cwd}";
	while( "${cwd}" != "/" )
		if( -d "${cwd}/nfs" ) then
			set base_dir="${cwd}";
			set escaped_base_dir="`printf "\""%s"\"" "\""${cwd}"\"" | sed -r 's/\//\\\//g'`";
			break;
		else
			cd "..";
		endif
	end
	if(! ${?skip_directory} ) \
		set skip_directory;
	if(! ${?duplicate_directory} ) \
		set duplicate_directory;
	cd "${old_cwd}";
	set owd="${old_owd}";
	unset old_owd old_cwd;
	@ errno=0;
	@ removed_podcasts=0;
	
	set missing_media_filename_list="`mktemp --tmpdir "\""filename.all.possibly.missing.${scripts_basename}.XXXXXXXX"\""`";
	
	#find -L ${target_directories}${maxdepth}${mindepth}-regextype ${regextype} -iregex ".*${extensions}"\$ -type f | sort | sed -r 's/(\\)/\\\\/g' | sed -r 's/(["$!`])/"\\\1"/g' | sed -r 's/(\[)/\\\[/g' | sed -r 's/([*])/\\\1/g' >! "${missing_media_filename_list}";
	foreach target_directory(${target_directories})
		if( ${?debug} ) then
			printf "Searching for missing multimedia files using:\n\t";
			printf "find -L "\""${target_directory}"\""${maxdepth}${mindepth}-regextype ${regextype} -iregex "\"".*${extensions}"\$\""' -type f\n";
		endif
		find -L "${target_directory}"${maxdepth}${mindepth}-regextype ${regextype} -iregex ".*${extensions}"\$ -type f | sort >> "${missing_media_filename_list}";
	end
#goto find_missing_media;


process_missing_media:
	foreach podcast("`cat "\""${missing_media_filename_list}"\"" | sed -r 's/(\\)/\\\\/g' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/(\[)/\\\[/g' | sed -r 's/([*])/\\\1/g'`")
		ex -s '+1d' '+wq!' "${missing_media_filename_list}";
		#printf "-->%s\n" "${podcast}";
		#continue;
		if( ${?skip_dirs} ) then
			foreach skip_dir("`printf "\""${skip_dirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`")
				set escaped_skip_dir="`printf "\""%s"\"" "\""${skip_dir}"\"" | sed -r 's/\//\\\//g'`";
				set dir_test="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/^(${escaped_skip_dir})\/.*"\$"/\1/'`";
				if( "${dir_test}" == "${skip_dir}" ) then
					unset dir_test escaped_skip_dir skip_dir;
					set skip_media;
					break;
				endif
				unset dir_test escaped_skip_dir skip_dir;
			end
			
			if( ${?skip_media} ) then
				unset skip_media;
				continue;
			endif
		endif
		
		set status=0;
		foreach playlist(${playlists})
			set grep_test="`/bin/grep "\""${podcast}"\"" "\""${playlist}"\""`";
			#if( ${status} != 0 ) then
				#printf "**error:** searching for: %s\n" "/bin/grep ${podcast} "\""${playlist}"\""";
			#		continue;
			#endif
			if( "${grep_test}" != "" ) then
				if( ${status} != 0 ) \
					printf "**error: %s** searching for: %s\n" "${grep_test}" ${podcast};
				break;
			endif
			unset playlist;
		end
		
		if( ${?playlist} ) \
			continue;
		
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/(\\\\)/\\/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
		if(! -e "${this_podcast}" ) \
			continue;
			
		if( ${?create_script} ) then
			printf "%s\n" "${this_podcast}" >> "${create_script}";
		endif
		
		goto handle_missing_media;
	end
	
	goto finish_finding_missing_media;
#goto process_missing_media;


check_duplicate_dirs:
	if( ${?duplicate_dir} ) then
		set previous_duplicate_dir="${duplicate_dir}";
	endif
	
	foreach duplicate_dir("`printf "\""${duplicates_dirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`")
		if( ${?previous_duplicate_dir} ) then
			if( "${previous_duplicate_dir}" == "${duplicate_dir}" ) \
				unset previous_duplicate_dir;
			continue;
		else
			set previous_duplicate_dir="${duplicate_dir}";
		endif
		
		set escaped_duplicate_dir="`printf "\""%s"\"" "\""${duplicate_dir}"\"" | sed -r 's/\//\\\//g'`";
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/^${escaped_base_dir}\//${escaped_duplicate_dir}\//"\"" | sed -r 's/(\\\\)/\\/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
		
		if(! -e "${this_podcast}" ) \
			continue;
			
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/^${escaped_base_dir}\//${escaped_duplicate_dir}\//"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/(\\\\)/\\/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
	
		unset escaped_duplicate_dir;
		
		goto handle_missing_media;
	end
	unset previous_duplicate_dir duplicate_dir this_podcast podcast;
	goto process_missing_media;
#goto check_diplicate_dirs;


handle_missing_media:
	set prompt_for_playlist;
	while( ${?prompt_for_playlist} )
		printf "\n\t<file://%s> is not listed in any of the provided playlists.\n\tWhat action would you like to take:\n" "${this_podcast}";
		@ playlist_index=0;
		while( $playlist_index < ${#playlists} )
			@ playlist_index++;
			printf "\t\t%d) Append to <file://%s>\n" $playlist_index "$playlists[$playlist_index]";
		end
		printf "\t\tr) Remove, i.e.: delete, this file and clean-up any resulting empty directories.\n\t\tc) Cancel, i.e.: Skip this file and do nothing.\n";
		printf "\n\tPlease select which action you want performed?  ";
		if( $playlist_index > 1 ) then
			printf "[1-%d]" $playlist_index;
		else
			printf "1";
		endif
		printf " , (r), or (c): ";
		set which_playlist="$<";
		printf "\n";
		if( `printf "%s" "${which_playlist}" | sed -r 's/^([cC])$/\l\1/i'` == "c" ) then
			printf "\n\t<file://%s> will not be procced.\n" "${this_podcast}";
			unset prompt_for_playlist;
		else if( `printf "%s" "${which_playlist}" | sed -r 's/^([rR])$/\l\1/i'` == "r" ) then
			printf "\n\t<file://%s> will be removed.\n" "${this_podcast}";
			unset prompt_for_playlist;
			goto remove_missing_media;
		else if( `printf "%s" "${which_playlist}" | sed -r 's/^[0-9]+$//'` != "" ) then
			printf "\n\t%s is an invalid playlist selection.  Please select again?\n" "${which_playlist}";
		else if( $which_playlist < 1 || $which_playlist > $playlist_index ) then
			printf "\n\t%s is an invalid playlist selection.  Please select again?\n" "${which_playlist}";
		else
			if(! ${?new_file_count} ) then
				@ new_file_count=1;
			else
				@ new_file_count++;
			endif
			printf "\n\tAdding <file//%s> to:\n\t\t<file://%s>" "${this_podcast}" "$playlists[$which_playlist]";
			printf "%s\n" "${this_podcast}" >> "$playlists[$which_playlist].new";
			unset prompt_for_playlist;
		endif
		unset which_playlist playlist_index;
	end
	
	if( ${?duplicates_dirs} ) \
		goto check_duplicate_dirs;
	
	goto process_missing_media;
#goto handle_missing_media;


remove_missing_media:
	if(! ${?duplicate_dir} ) then
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/(\\\\)/\\/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
	else
		set escaped_duplicate_dir="`printf "\""%s"\"" "\""${duplicate_dir}"\"" | sed -r 's/\//\\\//g'`";
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/^${escaped_base_dir}\//${escaped_duplicate_dir}\//"\"" | sed -r 's/(\\\\)/\\/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
		unset escaped_duplicate_dir;
	endif
	
	if(! -e "${this_podcast}" ) \
		continue;
	
	if(! ${?duplicate_dir} ) then
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/(\\\\)/\\/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
	else
		set escaped_duplicate_dir="`printf "\""%s"\"" "\""${duplicate_dir}"\"" | sed -r 's/\//\\\//g'`";
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/^${escaped_base_dir}\//${escaped_duplicate_dir}\//"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/(\\\\)/\\/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
		unset escaped_duplicate_dir;
	endif
	
	set status=0;
	
	set podcast_dir="`dirname "\""${this_podcast}"\""`";
	
	if(! ${?last_checked_directory} ) then
		set last_checked_directory="${podcast_dir}";
	else if( "${last_checked_directory}" != "${podcast_dir}" ) then
		set last_checked_directory="${podcast_dir}";
		printf "\n";
	endif
	
	set rm_confirmation="`rm -v${remove} "\""${this_podcast}"\""`";
	if(!( ${status} == 0 && "${rm_confirmation}" != "" )) then
		unset rm_confirmation podcast_dir;
		goto process_missing_media;
	endif
	
	printf "\t%s\n" "${rm_confirmation}";
	
	@ removed_podcasts++;
	if( ${?create_script} ) then
		printf "rm -vf%s "\""%s"\"";\n" "${remove}" "${this_podcast}" >> "${create_script}";
	endif
	
	set podcast_dir_for_ls="`dirname "\""${this_podcast}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
	while( "${podcast_dir}" != "/" )
		if( "`/bin/ls -A "\""${podcast_dir_for_ls}"\""`" != "" ) \
			break;
		
		set rm_notification="`rm -rv "\""${podcast_dir_for_ls}"\""`";
		printf "\t%s\n" "${rm_notification}";
		unset rm_notification;
		if( ${?create_script} ) then
			printf "rm -rv "\""%s"\"";\n" "${podcast_dir_for_ls}" >> "${create_script}";
		endif
		
		set podcast_cwd="`printf "\""%s"\"" "\""${podcast_dir_for_ls}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
		set podcast_dir="`dirname "\""${podcast_cwd}"\""`";
		set podcast_dir_for_ls="`dirname "\""${podcast_cwd}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
	end

	printf "\n\n";
	
	if( ${?podcast_cwd} ) \
		unset podcast_cwd;
	unset rm_confirmation podcast_dir podcast_dir_for_ls this_podcast;
	
	if( ${?duplicates_dirs} ) \
		goto check_duplicate_dirs;
	
	goto process_missing_media;
#goto remove_missing_media:


finish_finding_missing_media:
	#if( ${?new_file_count} ) then
		foreach playlist(${playlists})
			playlist:new:save.tcsh "$playlist";
			unset playlist;
		end
		unset new_file_count;
	#endif
	
	if( -e "${missing_media_filename_list}" ) \
		rm -f "${missing_media_filename_list}";
	
	goto exit_script;
#goto finish_finding_missing_media;



scripts_main_quit:
	if(! ${?removed_podcasts} ) \
		@ removed_podcasts=0;
	if( $removed_podcasts == 0 && ${?create_script} ) then
		rm "${create_script}";
	endif
	
	if( ${?old_owd} ) then
		cd "${owd}";
		set owd="${old_owd}";
		unset old_owd;
	endif
	
	if( ${?edit_playlist} ) \
		unset edit_playlist;
	if( ${?nodeps} ) \
		unset nodeps;
	if( ${?duplicates_subdir} ) \
		unset duplicates_subdir;
	if( ${?this_podcast} ) \
		unset this_podcast;
	if( ${?podcast_dir} ) \
		unset podcast_dir;
	if( ${?podcast} ) \
		unset podcast;
	if( ${?playlists} ) then
		foreach playlist(${playlists})
			if( -e "${playlist}.new" ) \
				rm -f "${playlist}.new";
			if( -e "${playlist}.swp" ) \
				rm -f "${playlist}.swp";
			unset playlist;
		end
		unset playlists;
	endif
	if( ${?new_file_count} ) \
		unset new_file_count;
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
	if(! ${?errno} ) \
		@ errno=0;
	
	@ status=$errno;
	exit ${errno};
#scripts_main_quit:


exit_script:
	if( ${?scripts_basname} ) \
		unset scripts_basname;
	if( ${?scripts_path} ) \
		unset scripts_path;
	if( ${?script} ) \
		unset script;
	if( ! ${?0} && ${?supports_being_sourced} ) then
		@ errno=-501;
		goto exception_handler;
	endif
	
	goto scripts_main_quit;
#exit_script:


usage:
	printf "\nUsage:\n\t%s playlist [directory] [--(extension|extensions)=] [--maxdepth=] [--recursive] [--search-all] [--skip-subdir=<sub-directory>] [--check-for-duplicates-in-dir=<directory>] [--remove[=(interactive|force)]]\n\tfinds any files in [directory], or its sub-directories, up to files of --maxdepth.  If the file is not not found in playlist,\n\tThe [directory] that's searched is [./] by default unless another absolute, or relative, [directory] is specified.\n\t[--(extension|extensions)=] is optional and used to search for files with extension(s) matching the string or escaped, posix-extended, regular expression, e.g. --extensions='(mp3|ogg)' only. Otherwise all files are searched for.\n--remove is also optional.  When this option is given %s will remove podcasts which aren't in the specified playlist.  Unless --remove is set to force you'll be prompted before each file is actually deleted.  If, after the file(s) are deleted, the parent directory is empty it will also be removed.\n" "`basename '${0}'`" "`basename '${0}'`";
	if( ${?no_exit_on_usage} ) \
		goto next_option;
	
	goto exit_script;
#usage:


default_callback:
	printf "handling callback to [%s].\n", "${last_callback}";
	unset last_callback;
	goto exit_script;
#default_callback:


exception_handler:
	if(! ${?errno} ) \
		@ errno=-599;
	printf "\n**%s error("\$"errno:%d):**\n\t" "${scripts_basename}"  $errno;
	if( $errno < 500 && ! ${?exit_on_error} ) \
		set exit_on_error;
	switch( $errno )
		case -2:
			printf "%s is not a valid and existing playlist" "${value}" > /dev/stderr;
			breaksw;
		
		case -3:
			printf "%s is not a valid and existing directory" "${value}" > /dev/stderr;
			breaksw;
		
		case -4:
			printf "A playlist must be specified" > /dev/stderr;
			breaksw;
		
		case -5:
			printf "An existing directory must be specified as the location to search for missing podcasts" > /dev/stderr;
			breaksw;
		
		case -501:
			printf "Sourcing is not supported.  This script may only be executed" > /dev/stderr;
			breaksw;
		
		case -502:
			printf "One or more required dependencies couldn't be found.\n\n[%s] couldn't be found.\n\n%s requires: %s" "${dependency}" "${scripts_basename}" "${dependencies}";
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided" > /dev/stderr;
			breaksw;
		
		case -504:
			printf "[%s%s%s%s] is an unsupported option" "${dashes}" "${option}" "${equals}" "${value}" > /dev/stderr;
			breaksw;
		
		case -599:
		default:
			printf "An unknown error "\$"errno: %s has occured" "${errno}" > /dev/stderr;
			breaksw;
	endsw
	printf ".\n\nPlease see: %s%s --help%s for more information and supported options\n" \` "${scripts_basename}" \` > /dev/stderr;
	
	if( ${?exit_on_error} || ! ${?callback} ) \
		goto exit_script;
	
	if( ${?callback} ) then
		set last_callback=$callback;
		unset callback;
		goto $last_callback;
	endif
	
	goto exit_script;
#exception_handler:


parse_argv:
	@ argc=${#argv};
	
	if( ${argc} == 0 ) \
		goto main;
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		if( "$argv[$arg]" != "--debug" ) \
			continue;
		printf "Enabling debug mode (via "\$"argv[%d])\n" $arg;
		set debug;
		break;
	end
	
	@ arg=0;
	
	if( ${?debug} ) \
		printf "Checking %s's argv options.  %d total.\n" "${scripts_basename}" "${argc}";
#parse_argv:

parse_arg:
	while( $arg < $argc )
		if(! ${?arg_shifted} ) then
			@ arg++;
		else
			unset arg_shifted;
		endif
		
		if( ${?debug} ) \
			printf "Checking argv #%d (%s).\n" "${arg}" "$argv[$arg]";
		
		set argument="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
		set dashes="`printf "\""%s"\"" "\""${argument}"\"" | sed -r 's/([\-]{1,2})([^\=]+)(=?)(.*)/\1/'`";
		if( "${dashes}" == "${argument}" ) \
			set dashes="";
		
		set option="`printf "\""%s"\"" "\""${argument}"\"" | sed -r 's/([\-]{1,2})([^\=]+)(=?)(.*)/\2/'`";
		if( "${option}" == "${argument}" ) \
			set option="";
		
		set equals="`printf "\""%s"\"" "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)(.*)"\$"/\3/'`";
		if( "${equals}" == "${argument}" ) \
			set equals="";
		
		set value="`printf "\""%s"\"" "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)(.*)"\$"/\4/'`";
		
		if( "${dashes}" != "" && "${option}" != "" && "${equals}" == "" && ( "${value}" == "" || "${value}" == "${argument}" ) ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				set test_argument="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g'`";
				set test_dashes="`printf "\""%s"\"" "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)(.*)"\$"/\1/'`";
				if( "${test_dashes}" == "${test_argument}" ) \
					set test_dashes="";
				
				set test_option="`printf "\""%s"\"" "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)(.*)"\$"/\2/'`";
				if( "${test_option}" == "${test_argument}" ) \
					set test_option="";
				
				set test_equals="`printf "\""%s"\"" "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)(.*)"\$"/\3/'`";
				if( "${test_equals}" == "${test_argument}" ) \
					set test_equals="";
				
				set test_value="`printf "\""%s"\"" "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)(.*)"\$"/\4/'`";
				
				if( "${test_dashes}" != "" && "${test_option}" != "" && ( "${test_value}" == "" || "${test_value}" == "${test_argument}" ) ) then
					@ arg--;
				else
					set arg_shifted;
					set equals=" ";
					set value="${test_value}";
				endif
				unset test_argument test_dashes test_option test_equals test_value;
			endif
		endif
		
		#if( "`printf "\""%s"\"" "\""${value}"\"" | sed -r "\""s/^(~)(.*)/\1/"\""`" == "~" ) then
		#	set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r "\""s/^(~)(.*)/${escaped_home_dir}\2/"\"" | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		#endif
		
		#if( "`printf "\""%s"\"" "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/\1/"\""`" == "." ) then
		#	set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/${escaped_starting_cwd}\2/"\"" | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		#endif
		
		#if( "`printf "\""%s"\"" "\""${value}"\"" | sed -r "\""s/^.*(\*)/\1/"\""`" == "*" ) then
		#	set dir="`printf "\""%s"\"" "\""${value}"\"" | sed -r "\""s/^(.*)\*"\$"/\1/"\""`";
		#	set value="`/bin/ls --width=1 "\""${dir}"\""*`";
		#endif
		
		if( ${?debug} ) \
			printf "**debug** parsed %sargv[%d] (%s).\n\tParsed option: %s%s%s%s\n" ""\$"" "${arg}" "$argv[$arg]" "${dashes}" "${option}" "${equals}" "${value}";
		
		switch( "${option}" )
			case "help":
				goto usage;
			breaksw;
			
			case "edit":
			case "edit-playlist":
				if(! ${?edit_playlist} ) \
					set edit_playlist;
				breaksw;
			
			case "check-for-duplicates-in-dir":
			case "skip-files-in-dir":
			case "skip-dir":
			case "dups-dir":
				set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/\/"\$"//'`";
				if( ! -d "${value}" && ! -l "${value}" ) then
					printf "--%s must specify a directory of <file://%s> does not exist.\n" "${option}" "${value}" > /dev/stderr;
					continue;
				endif
				
				switch("${option}")
					case "skip-files-in-dir":
					case "skip-dir":
						if(! ${?skip_dirs} ) then
							set skip_dirs=("${value}");
						else
							set skip_dirs=( "${skip_dirs}" "\n" "${value}" );
						endif
					breaksw;
					
					case "dups-dir":
					case "check-for-duplicates-in-dir":
						if(! ${?duplicates_dirs} ) then
							set duplicates_dirs=("${value}");
						else
							set duplicates_dirs=( "${duplicates_dirs}" "\n" "${value}");
						endif
					breaksw;
				endsw
			breaksw;
			
			case "regextype":
			case "regex-type":
				switch("${value}")
					case "posix-extended":
					case "posix-awk":
					case "posix-basic":
					case "posix-egrep":
					case "emacs":
						set regextype="${value}";
					breaksw;
					
					default:
						printf "Invalid %s specified.  Supported %s values are: posix-extended (this is the default), posix-awk, posix-basic, posix-egrep and emacs.\n" "${option}" "${option}" > /dev/stderr;
					breaksw;
				endsw
			breaksw;
			
			case "enable":
				switch("${value}")
					case "logging":
						breaksw;
					
					default:
						printf "%s cannot be enabled.\n" "${value}" > /dev/stderr;
						shfit;
						continue;
					breaksw;
				endsw
			breaksw;
			
			case "create-script":
			case "mk-script":
				if("${value}" != "" &&  "${value}" != "logging") then
					set create_script="${value}";
				else
					set create_script="";
				endif
			breaksw;
			
			case "extension":
			case "extensions":
				if( "${value}" != "" ) \
					set extensions="${value}";
			breaksw;
			
			case "debug":
				switch("${value}")
					case "grep":
						if( ${?debug_grep} ) \
							breaksw;
						set debug_grep;
					breaksw;
					
					default:
						if( ${?debug} ) \
							breaksw;
						set debug;
					breaksw;
				endsw
			breaksw;
			
			case "remove":
			case "clean-up":
				if(! ${?remove} ) \
					set remove;
				
				switch("${value}")
					case "verbose":
						if( ${?removal_verbose} ) \
							breaksw;
						
						set removal_verbose;
						breaksw;
					
					case "force":
						if( ${?removal_forced} ) \
							breaksw;
						
						set removal_forced;
						set remove="${remove}f";
						breaksw;
					
					case "interactive":
					default:
						if( ${?removal_interactive} ) \
							breaksw;
						
						set removal_interactive;
						set remove="${remove}i";
						breaksw;
				endsw
			breaksw;
			
			case "recursive":
				set maxdepth="";
			breaksw;
			
			case "append":
				set append;
			breaksw;
			
			case "maxdepth":
				if( ${?maxdepth} ) \
					breaksw;
				
				if( ${value} != "" && `printf "%s" "${value}" | sed -r 's/^([\-]).*/\1/'` != "-" ) then
					set value=`printf "%s" "${value}" | sed -r 's/.*([0-9]+).*/\1/'`
					if( ${value} > 0 ) \
						set maxdepth=" -maxdepth ${value}";
				endif
				if(! ${?maxdepth} ) \
					printf "--maxdepth must be an integer value that is gretter than 0." > /dev/stderr;
			breaksw;
			
			case "mindepth":
				if( ${?mindepth} ) \
					breaksw;
				
				if( ${value} != "" && `printf "%s" "${value}" | sed -r 's/^([\-]).*/\1/'` != "-" ) then
					set value=`printf "%s" "${value}" | sed -r 's/.*([0-9]+).*/\1/'`
					if( ${value} > 0 ) \
						set mindepth=" -mindepth ${value} ";
				endif
				
				if(! ${?mindepth} ) \
					printf "--maxdepth must be an integer gretter than 0." > /dev/stderr
			breaksw;
			
			case "search-subdirs-only":
				set mindepth=" -mindepth 2 ";
			breaksw;
			
			case "all":
			case "search-all":
			case "search-all-subdirs":
				set mindepth=" ";
				set maxdepth="";
			breaksw;
			
			case "search":
			case "target":
			case "directory":
			case "search-directory":
			case "target-directory":
				if( -d "${value}" ) \
					goto append_directory;
				breaksw;
			
			case "playlist":
				if(! -f "${value}" ) \
					breaksw;
				
				goto append_playlist;
				breaksw;
			
			case "nodeps":
			case "debug":
			breaksw;
			
			default:
				if( -d "${value}" ) \
					goto append_directory;
				
				if( -f "${value}" ) then
					goto append_playlist;
					breaksw;
				endif
				
				@ errno=-504;
				set callback="parse_arg";
				goto exception_handler;
			breaksw;
		endsw
		
		if( ${?arg_shifted} ) then
			unset arg_shifted;
			@ arg--;
		endif
		unset argument dashes option equals value;
	end
	
	if( ${?argument} )\
		unset argument;
	if( ${?dashes} )\
		unset dashes;
	if( ${?option} )\
		unset option;
	if( ${?equals} )\
		unset equals;
	if( ${?value} )\
		unset value;
	
	goto main;
#parse_arg:


append_playlist:
	if(! -f "${value}" )  then
		if( ${?arg_shifted} ) \
			goto parse_arg;
		
		set callback="parse_arg";
		@ errno=-2;
		goto exception_handler;
	endif
	
	if(! ${?playlists} ) \
		set playlists="`mktemp --tmpdir "\""escaped.playlists.for:${scripts_basename}.XXXXXXXX"\""`";
	
	set filename_list="${playlists}";
	set callback="append_playlist";
	goto append_to_filename_list;
#goto append_playlist;


append_directory:
	if(! -d "${value}" ) then
		if( ${?arg_shifted} ) \
			goto parse_arg;
		
		set callback="parse_arg";
		@ errno=-3;
		goto exception_handler;
	endif
	
	if(! ${?target_directories} ) \
		set target_directories="`mktemp --tmpdir "\""escaped.target-directories.for:${scripts_basename}.XXXXXXXX"\""`";
	
	set filename_list="${target_directories}";
	set callback="append_to_filename_list";
	goto append_to_filename_list;
#goto append_directory;


append_to_filename_list:
	if( ${?debug} ) \
		printf "\nAdding <%s> to:\n\t<%s>\n" "${value}" "${filename_list}";
	printf "${value}\n" >> "${filename_list}";
	while( $arg < $argc )
		@ arg++;
		if(!( $arg < $argc )) then
			@ arg--;
			goto parse_arg;
		endif
		
		set arg_shifted;
		if(! -e "$argv[$arg]" ) then
			goto parse_arg;
		endif
		
		set value="$argv[$arg]";
		goto $callback;
	end
	unset filname_list filename_test;
	goto parse_arg;
#goto append_to_filename_list;


