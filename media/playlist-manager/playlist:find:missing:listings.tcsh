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
	if( ${argc} < 2 ) then
		@ errno=-503;
		goto exception_handler;
	endif
	
	goto dependencies_check;
#goto init;


dependencies_check:
	set dependencies=("${scripts_basename}" "playlist:sort:by:pubdate.tcsh");# "`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)$/\1/'`");
	@ dependencies_index=0;
	foreach dependency(${dependencies})
		@ dependencies_index++;
		if( ${?debug} || ${?debug_dependencies} ) \
			printf "\n**%s debug:** looking for dependency: %s.\n\n" "${scripts_basename}" "${dependency}"; 
			
		foreach program("`where "\""${dependency}"\""`")
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
				case 1:
					set suffix="st";
					breaksw;
				
				case 2:
					set suffix="nd";
					breaksw;
				
				case 3:
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
				if(! ${?script} ) then
					set old_owd="${cwd}";
					cd "`dirname '${program}'`";
					set scripts_path="${cwd}";
					cd "${owd}";
					set owd="${old_owd}";
					unset old_owd;
					set script="${scripts_path}/${scripts_basename}";
					breaksw;
				endif
			
			default:
				breaksw;
			
		endsw
		
		unset program;
	end
	
	unset dependency dependencies dependencies_index;
	goto parse_argv;
#goto check_dependencies;


main:
	if(! ${?playlists_filename_list} ) then
		@ errno=-4;
		goto exception_handler;
	endif
	
	if(! ${?target_directories_filename_list} ) then
		@ errno=-5;
		goto exception_handler;
	endif
	
	sort "${playlists_filename_list}" | uniq > "${playlists_filename_list}.swap";
	mv -f "${playlists_filename_list}.swap" "${playlists_filename_list}";
	
	set playlists="`cat "\""${playlists_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	
	set target_directories="`cat "\""${target_directories_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	
	if(! ${?maxdepth} ) \
		set maxdepth=" -maxdepth 2";
	
	if(! ${?mindepth} ) \
		set mindepth=" ";
	
	if(! ${?extensions} ) \
		set extensions;
	
	if(! ${?regextype} ) \
		set regextype="posix-extended";
	
	@ errno=0;
	@ removed_podcasts=0;
	@ missing_podcasts=0;
	@ new_file_count=0;
#goto main;


edit_playlists:
	if( ${?edit_playlist} ) then
		foreach playlist( "`cat "\""${playlists_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
			set playlist="`printf "\""%s"\"" "\""${playlist}"\""`";
			${EDITOR} "${playlist}";
			unset playlist;
		end
	endif
#goto edit_playlists;


setup_playlist_new:
	foreach playlist( "`cat "\""${playlists_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
		set playlist="`printf "\""%s"\"" "\""${playlist}"\""`";
		playlist:new:create.tcsh "${playlist}";
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
	goto find_missing_media;
#create_clean_up_script:


find_missing_media:
	if(! ${?missing_media_filename_list} ) \
		set missing_media_filename_list="`mktemp --tmpdir "\""filename.all.possibly.missing.${scripts_basename}.XXXXXXXX"\""`";
	
	#find -L ${target_directories}${maxdepth}${mindepth}-regextype ${regextype} -iregex ".*${extensions}"\$ -type f | sort | sed -r 's/(\\)/\\\\/g' | sed -r 's/(["$!`])/"\\\1"/g' | sed -r 's/(\[)/\\\[/g' | sed -r 's/([*])/\\\1/g' >! "${missing_media_filename_list}";
	if(! ${?previous_target_directory} ) \
		printf "\nSearching for multimedia files";
	else
		if( "${previous_target_directory}" == "${target_directory}" ) then
			if( ${?debug} ) \
				printf "<%s> == <%s>\n" "${previous_target_directory}" "${target_directory}";
			unset previous_target_directory;
		endif
		printf " .";
		goto find_missing_media;
	endif
	
	foreach target_directory( "`cat "\""${target_directories_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
		set target_directory="`printf "\""%s"\"" "\""${target_directory}"\""`";
		if(! ${?previous_target_directory} ) \
			set previous_target_directory="${target_directory}";
		
		if( ${?debug} ) \
			printf "\nRunning:\n\tfind -L "\""${target_directory}"\""${maxdepth}${mindepth}-regextype ${regextype} -iregex "\"".*${extensions}"\$\""' \! -iregex '.*\/\..*' -type f\n";
		
		printf " .";
		ex -s '+1d' '+wq!' "${target_directories_filename_list}";
		find -L "${target_directory}"${maxdepth}${mindepth}-regextype ${regextype} -iregex ".*${extensions}"\$ \! -iregex '.*\/\..*' -type f >> "${missing_media_filename_list}";
		if( ${?skip_dirs} ) then
			foreach skip_dir("`printf "\""${skip_dirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`")
				set escaped_skip_dir="`printf "\""%s"\"" "\""${skip_dir}"\"" | sed -r 's/(\\|\[|\*|\/)/\\\1/g'`";
				ex -s "+1,"\$"s/^${escaped_skip_dir}.*\n//" '+wq!' "${missing_media_filename_list}";
			end
		endif
		printf " .";
		
		unset target_directory;
		goto find_missing_media;
	end
	sort "${missing_media_filename_list}" | uniq >! "${missing_media_filename_list}.swap";
	mv -f "${missing_media_filename_list}.swap" "${missing_media_filename_list}";
	printf " .";
	while( "`/bin/grep --perl-regex -c '^"\$"' "\""${missing_media_filename_list}"\""`" != 0 )
		set line_numbers=`/bin/grep --perl-regex --line-number '^$' "${missing_media_filename_list}" | sed -r 's/^([0-9]+).*$/\1/' | grep --perl-regexp '^[0-9]+'`;
		set line_numbers=`printf "%s\n" "${line_numbers}" | sed 's/ /,/g'`;
	 	ex -s "+${line_numbers}d" '+1,$s/\v^\n//g' '+wq!' "${missing_media_filename_list}";
		unset line_numbers;
	end
	printf " . [finished]\n";
	
	unset previous_target_directory;
	
	if(!( ${#playlists} > 1 )) then
		printf "\nLooking for any files which aren't listed in the provided playlist...\n";
	else
		printf "\nLooking for any files which aren't listed in any of the provided playlists...\n";
	endif
	
	if(!( `wc -l "${missing_media_filename_list}" | sed -r 's/^([0-9]+).*$/\1/'` > 0 )) then
		printf "\nNo files where found.\n";
		goto exit_script;
	endif
	
	goto process_missing_media;
#goto find_missing_media;


cancel_processing_media:
	onintr exit_script;
	
	if( ${?podcast} ) then
		if( ${?this_podcast} ) then
			printf "[cancelled]\n\t\t<file://%s> has not been processed.\n" "${this_podcast}";
			unset this_podcast;
		endif
		unset podcast;
		printf "\n\tWould you like to stop looking for any unlisted files? [Yes/No(default)] ";
		set exit_value="$<";
		set exit_value=`printf "%s" "${exit_value}" | sed -r 's/^(.).*$/\l\1/'`;
		printf "\n";
		if("${exit_value}" == "y") then
			unset exit_value;
			goto exit_script;
		endif
	endif
	
	goto process_missing_media;
#onintr cancel_processing_media;


process_missing_media:
	onintr cancel_processing_media;
	foreach podcast("`cat "\""${missing_media_filename_list}"\"" | sed -r 's/(\\|\[|\*)/\\\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`")
		ex -s '+1d' '+wq!' "${missing_media_filename_list}";
		#printf "-->%s\n" "${podcast}";
		#continue;
		
		
		set status=0;
		foreach playlist( "`cat "\""${playlists_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
			set playlist="`printf "\""%s"\"" "\""${playlist}"\""`";
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
		
		if( ${?playlist} ) then
			unset playlist podcast;
			continue;
		endif
		
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/\\(\\|\[|\*)/\1/g'`";
		
		if(! -e "${this_podcast}" ) then
			unset this_podcast podcast;
			continue;
		endif
		
		goto handle_missing_media;
	end
	
	if( ${?this_podcast} ) \
		unset this_podcast;
	unset podcast;
	
	printf "\nFinished processing missing multimedia files found in the target ";
	if(!( ${#target_directories} > 1 )) then
		printf "directory";
	else
		printf "directories";
	endif
	printf ".\n\n";
	goto exit_script;
#goto process_missing_media;


check_duplicate_dirs:
	onintr cancel_processing_media;
	
	if(! ${?base_dir} ) \
		set base_dir;
	
	if(! ${?escaped_base_dir} ) \
		set escaped_base_dir;
	
	if(!( "${escaped_base_dir}" != "" && "${base_dir}" != "" && "`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/^(${escaped_base_dir}).*"\$"/\1/'`" == "${base_dir}" )) then
		set old_owd="${owd}";
		set old_cwd="${cwd}";
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/\\(\\|\[|\*)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
		set podcast_dir="`dirname "\""${this_podcast}"\""`";
		while( "${podcast_dir}" != "/" && ! -d "${podcast_dir}" )
			set podcast_dir="`dirname "\""${podcast_dir}"\""`";
		end
		cd "${podcast_dir}";
		unset podcast_dir;
		while( "${cwd}" != "/" )
			if( -d "${cwd}/nfs" ) then
				set base_dir="${cwd}";
				set escaped_base_dir="`printf "\""%s"\"" "\""${cwd}"\"" | sed -r 's/(\\|\[|\*|\/)/\\\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
				break;
			else
				cd "..";
			endif
		end
		cd "${old_cwd}";
		set owd="${old_owd}";
		unset old_owd old_cwd this_podcast;
	endif
	
	foreach duplicate_dir("`printf "\""${duplicates_dirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`")
		if(! ${?previous_duplicate_dir} ) then
			set previous_duplicate_dir="${duplicate_dir}";
		else
			if( "${previous_duplicate_dir}" == "${duplicate_dir}" ) \
				unset previous_duplicate_dir;
			continue;
		endif
		
		set escaped_duplicate_dir="`printf "\""%s"\"" "\""${duplicate_dir}"\"" | sed -r 's/(\\|\[|\*|\/)/\\\1/g'`";
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/\\(\\|\[|\*)/\1/g'`";
		set duplicate_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/^${escaped_base_dir}\//${escaped_duplicate_dir}\//"\"" | sed -r 's/\\(\\|\[|\*)/\1/g'`";
		
		#printf "Looking for: <file://%s>" "${duplicate_podcast}";
		if(!( "${duplicate_podcast}" != "${this_podcast}" && -e "${duplicate_podcast}" )) then
			unset duplicate_podcast escaped_duplicate_dir this_podcast;
			goto check_duplicate_dirs;
		endif
		
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/^${escaped_base_dir}\//${escaped_duplicate_dir}\//"\"" | sed -r 's/\\(\\|\[|\*)/\1/g'`";
		unset duplicate_podcast escaped_duplicate_dir;
		goto handle_missing_media;
	end
	unset previous_duplicate_dir duplicate_dir this_podcast podcast;
	goto process_missing_media;
#goto check_duplicate_dirs;


handle_missing_media:
	@ missing_podcasts++;
	
	if( ${?removal_forced} ) \
		goto remove_missing_media;
	
	goto prompt_for_action_for_missing_media;
#goto handle_missing_media;


prompt_for_action_for_missing_media:
	if( $missing_podcasts > 1 ) \
		printf "\n\n\t\t-----------------------------------------------------\n\n";
	
	onintr -;
	
	if( ${?playlist} ) \
		unset playlist;
	
	if( ${?append_set} ) \
		unset append append_set;
	
	if( ${?append_automatically} ) then
		if( $append_automatically > 0 && $append_automatically <= ${#playlists}  ) then
			set append=$append_automatically;
			set playlist_index=$append_automatically;
		endif
	else
		set prompt_for_playlist;
	endif
	
	while( ${?prompt_for_playlist} )
		if( ${?response} ) then
			printf "\n\n\t\t-----------------------------------------------------";
			printf "\n\t\t**error:** %s is an invalid selection.  Please select again?" "${response}";
			printf "\n\t\t-----------------------------------------------------\n\n";
		endif
		printf "\n\t**";
		if(! ${?duplicate_dir} ) then
			printf "Unlisted";
		else
			printf "Remote/Duplicate";
		endif
		printf " file:**\n\t\t<file://%s>" "${this_podcast}";
		printf "\n\n\tWhat action would you like to take:";
		if(! ${?remove} ) then
			@ playlist_index=0;
			
			printf "\n\n\t\t0) Append to & create a new playlist.\n";
			
			foreach playlist( "`cat "\""${playlists_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
				@ playlist_index++;
				set playlist="`printf "\""%s"\"" "\""${playlist}"\""`";
				printf "\n\t\t%d) Append to <file://%s>" $playlist_index "${playlist}";
			end
			printf "\n";
		endif
		
		if(! ${?append} ) \
			printf "\n\t\tD) Delete this file and resulting empty directories.";
		
		printf "\n\t\tS) Skip this file and do nothing.";
		printf "\n\t\tA) Abort and exit %s." "${scripts_basename}";
		
		printf "\n\n\tPlease select which action you want performed?  ";
		
		if(! ${?remove} ) then
			printf "0 or ";
			if(!( $playlist_index > 1 )) then
				printf "1";
			else
				printf "[1-%d]" $playlist_index;
			endif
			printf " or ";
		endif
		
		printf "[";
		if(! ${?append} ) \
			printf "Delete, ";
		
		printf "Skip, Abort]: ";
		set response="$<";
		printf "\n";
		switch( `printf "%s" "${response}" | sed -r 's/^(.).*$/\l\1/'` )
			case "s":
				printf "\n\t**Skipping:**\n\t\t<file://%s>\n" "${this_podcast}";
				unset prompt_for_playlist;
				breaksw;
			
			case "a":
				printf "\n\t**Aborting:**\n\t\t<file://%s>" "${this_podcast}";
				printf "\n\t\t**Exiting:** %s...\n\n" "${scripts_basename}";
				unset prompt_for_playlist response playlist_index;
				unset this_podcast podcast;
				goto exit_script;
				breaksw;
			
			case "d":
				if( ${?append} ) \
					breaksw;
				
				printf "\n\t**Deleting:**\n\t\t<file://%s>\n\t\tand cleaning up any empty directories.\n" "${this_podcast}";
				unset prompt_for_playlist response playlist_index;
				goto remove_missing_media;
				breaksw;
			
			default:
				if( ${?remove} ) \
					continue;
				
				if( `printf "%s" "${response}" | sed -r 's/^[0-9]+$//'` != "" ) \
					continue;
				
				if(!( $response > -1 && $response <= $playlist_index )) \
					continue;
				
				unset prompt_for_playlist;
				set append=$response;
				set append_set;
				breaksw;
		endsw
		unset response;
	end
	if( ${?append} ) then
		if( `printf "%s" "${append}" | sed -r 's/^[0-9]+$//'` == "" ) then
			if( $append == 0 ) then
				while(! ${?playlist_new_type} )
					printf "\n\t\tPlease enter the full filename of the playlist you would like to create:";
					printf "\n\t\t\tor enter 'cancel' to select a different action: ";
					set playlist_new="$<";
					printf "\n";
					if( `printf "%s" "${playlist_new}" | sed -r 's/^(.*)$/\L\1/'` == "cancel" ) then
						unset playlist_new;
						if( ${?append_set} ) \
							unset append append_set;
						goto prompt_for_action_for_missing_media;
					endif
					set playlist_new_type=`printf "%s" "${playlist_new}" | sed -r 's/^.*\.([^.]+)$/\1/'`;
					switch( "${playlist_new_type}" )
						case "m3u":
						case "tox":
						case "pls":
							@ new_file_count++;
							if(! -e "${playlist_new}" ) then
								printf "\n\t";
								playlist:new:create.tcsh "${playlist_new}";
								printf "\n";
								if(!( -e "${playlist_new}" && -e "${playlist_new}.new" )) then
									printf "\n\t\t\t**error:** %s could not be created. Please enter a valid path for the new playlist.\n\n" "${playlist_new}";
									unset playlist_new playlist_new_type;
									breaksw;
								endif
							endif
							printf "\n\t**Appending:**\n\t\t<file://%s>\n\t\t\tto:\n\t\t<file://%s>\n" "${this_podcast}" "${playlist_new}";
							printf "%s\n" "${this_podcast}" >> "${playlist_new}.new";
							printf "%s\n" "${playlist_new}" >> "${playlists_filename_list}";
							
							sort "${playlists_filename_list}" | uniq > "${playlists_filename_list}.swap";
							mv -f "${playlists_filename_list}.swap" "${playlists_filename_list}";
							set playlists="`cat "\""${playlists_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
							unset playlist_new;
							breaksw;
						
						default:
							printf "%s is an unsupported playlist type.  Only m3u, tox, and pls playlists are supported.\n\n" "${playlist_new}";
							unset playlist_new playlist_new_type;
							breaksw;
					endsw
				end
				unset playlist_new playlist_new_type;
			else if( $append > 0 && $append <= $playlist_index ) then
				@ new_file_count++;
				@ playlist_count=0;
				foreach playlist( "`cat "\""${playlists_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
					@ playlist_count++;
					if( $playlist_count == $append ) then
						set playlist="`printf "\""%s"\"" "\""${playlist}"\""`";
						printf "\n\t**Appending:**\n\t\t<file://%s>\n\t\t\tto:\n\t\t<file://%s>\n" "${this_podcast}" "${playlist}";
						printf "%s\n" "${this_podcast}" >> "${playlist}.new";
					endif
					unset playlist;
				end
				unset playlist_count;
			endif
		endif
		if( ${?append_set} ) \
			unset append append_set;
	endif
	
	unset playlist_index;
	
	onintr cancel_processing_media;
	
	if( ${?duplicates_dirs} ) \
		goto check_duplicate_dirs;
	
	unset this_podcast podcast;
	
	goto process_missing_media;
#goto prompt_for_action_for_missing_media;


remove_missing_media:
	if(! ${?duplicate_dir} ) then
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/\\(\\|\[|\*)/\1/g'`";
	else
		set escaped_duplicate_dir="`printf "\""%s"\"" "\""${duplicate_dir}"\"" | sed -r 's/(\\|\[|\*|\/)/\\\1/g'`";
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/^${escaped_base_dir}\//${escaped_duplicate_dir}\//"\"" | sed -r 's/\\(\\|\[|\*)/\1/g'`";
	endif
	
	if(! -e "${this_podcast}" ) then
		if( ${?duplicate_dir} ) then
			unset escaped_duplicate_dir;
			unset this_podcast podcast;
			goto check_duplicate_dirs;
		endif
		unset this_podcast podcast;
		goto process_missing_media;
	endif
	
	if(! ${?duplicate_dir} ) then
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/\\(\\|\[|\*)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	else
		set this_podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/^${escaped_base_dir}\//${escaped_duplicate_dir}\//"\"" | sed -r 's/\\(\\|\[|\*)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
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
	
	if(! ${?remove} ) \
		set remove remove_set;
	set rm_notification="`rm -v${remove} "\""${this_podcast}"\""`";
	if( ${?remove_set} ) \
		unset remove remove_set;
	if(!( ${status} == 0 && "${rm_notification}" != "" )) then
		unset rm_notification podcast_dir;
		unset this_podcast podcast;
		goto process_missing_media;
	endif
	
	if(! ${?removal_silent} ) \
		printf "\t%s\n" "${rm_notification}";
	
	@ removed_podcasts++;
	if( ${?create_script} ) then
		printf "rm -vf%s "\""%s"\"";\n" "${remove}" "${this_podcast}" >> "${create_script}";
	endif
	
	set podcast_dir_for_ls="`dirname "\""${this_podcast}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	while( "${podcast_dir}" != "/" && "`mount | grep "\""^${podcast_dir_for_ls} "\""`" == "" )
		if( "`/bin/ls -A "\""${podcast_dir_for_ls}"\""`" != "" ) \
			break;
		
		set rm_notification="`rm -rv "\""${podcast_dir_for_ls}"\""`";
		if(! ${?removal_silent} ) \
			printf "\t%s\n" "${rm_notification}"
		unset rm_notification;
		if( ${?create_script} ) then
			printf "rm -rv "\""%s"\"";\n" "${podcast_dir}" >> "${create_script}";
		endif
		
		set podcast_cwd="`printf "\""%s"\"" "\""${podcast_dir_for_ls}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
		set podcast_dir="`dirname "\""${podcast_cwd}"\""`";
		set podcast_dir_for_ls="`dirname "\""${podcast_cwd}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	
	if( ${?podcast_cwd} ) \
		unset podcast_cwd;
	unset rm_notification podcast_dir podcast_dir_for_ls this_podcast;
	
	if( ${?duplicates_dirs} ) \
		goto check_duplicate_dirs;
	
	unset podcast;
	goto process_missing_media;
#goto remove_missing_media


scripts_main_quit:
	onintr -;
	
	if( ${?scripts_basname} ) \
		unset scripts_basname;
	if( ${?scripts_path} ) \
		unset scripts_path;
	if( ${?script} ) \
		unset script;
	
	if( ${?playlists_filename_list} ) then
		if( -e "${playlists_filename_list}" ) then
			foreach playlist( "`cat "\""${playlists_filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
				set playlist="`printf "\""%s"\"" "\""${playlist}"\""`";
				playlist:new:save.tcsh "${playlist}";
				unset playlist;
			end
		endif
		rm -f "${playlists_filename_list}";
		unset playlists_filename_list;
	endif
	
	if( ${?missing_media_filename_list} ) then
		if( -e "${missing_media_filename_list}" ) \
			rm -f "${missing_media_filename_list}";
	endif
	
	if( ${?target_directories_filename_list} ) then
		if( -e "${target_directories_filename_list}" ) \
			rm -f "${target_directories_filename_list}";
		unset target_directories_filename_list;
	endif
	
	if(! ${?removed_podcasts} ) \
		@ removed_podcasts=0;
	if( $removed_podcasts == 0 && ${?create_script} ) then
		if( -e "${create_script}" ) \
			rm -f "${create_script}";
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
	
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
	if( ${?removed_podcasts} )\
		unset removed_podcasts;
	if( ${?missing_podcasts} )\
		unset missing_podcasts;
	if( ${?new_file_count} ) \
		unset new_file_count;
	
	if(! ${?errno} ) \
		@ errno=0;
	
	set status=$errno;
	exit ${status};
#scripts_main_quit:


exit_script:
	onintr -;
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
	goto parse_arg;
#parse_argv:

parse_arg:
	while( $arg < $argc )
		if(! ${?arg_shifted} ) then
			@ arg++;
		else
			unset arg_shifted;
		endif
		
		if( ${?debug} ) \
			printf "Checking "\$"argv[%d] (%s).\n" "${arg}" "$argv[$arg]";
		
		set argument="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
		set dashes="`printf "\""%s"\"" "\""${argument}"\"" | sed -r 's/([\-]{1,2})([^=]+)(=?)(.*)/\1/'`";
		if( "${dashes}" == "${argument}" ) \
			set dashes="";
		
		set option="`printf "\""%s"\"" "\""${argument}"\"" | sed -r 's/([\-]{1,2})([^=]+)(=?)(.*)/\2/'`";
		if( "${option}" == "${argument}" ) \
			set option="";
		
		set equals="`printf "\""%s"\"" "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=?)(.*)"\$"/\3/'`";
		if( "${equals}" == "${argument}" ) \
			set equals="";
		
		set value="`printf "\""%s"\"" "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=?)(.*)"\$"/\4/'`";
		
		if( ${?debug} ) \
			printf "\tparsed "\$"argument: [%s]; "\$"argv[%d] (%s)\n\t\t"\$"dashes: [%s];\n\t\t"\$"option: [%s];\n\t\t"\$"equals: [%s];\n\t\t"\$"value: [%s]\n\n" "${argument}" "${arg}" "$argv[${arg}]" "${dashes}" "${option}" "${equals}" "${value}" > ${stdout};
		
		if( "${dashes}" != "" && "${option}" != "" && "${equals}" == "" && "${value}" == "" ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				if( ${?debug} ) \
					printf "\n\tChecking "\$"argv[%d], (%s), for possible value.\n" "${arg}" "$argv[$arg]";
				set test_argument="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g'`";
				set test_dashes="`printf "\""%s"\"" "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=?)(.*)"\$"/\1/'`";
				if( "${test_dashes}" == "${test_argument}" ) \
					set test_dashes="";
				
				set test_option="`printf "\""%s"\"" "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=?)(.*)"\$"/\2/'`";
				if( "${test_option}" == "${test_argument}" ) \
					set test_option="";
				
				set test_equals="`printf "\""%s"\"" "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=?)(.*)"\$"/\3/'`";
				if( "${test_equals}" == "${test_argument}" ) \
					set test_equals="";
				
				set test_value="`printf "\""%s"\"" "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=?)(.*)"\$"/\4/'`";
				if( ${?debug} ) \
					printf "\n\t\tparsed argument for possible replacement value:\n\t\t\t"\$"test_argument: [%s]; "\$"argv[%d] (%s)\n\t\t\t"\$"test_dashes: [%s];\n\t\t\t"\$"test_option: [%s];\n\t\t\t"\$"test_equals: [%s];\n\t\t\t"\$"test_value: [%s]\n\n" "${test_argument}" "${arg}" "$argv[${arg}]" "${test_dashes}" "${test_option}" "${test_equals}" "${test_value}" > ${stdout};
				
				if(!( "${test_dashes}" == "" && "${test_option}" == "" && "${test_equals}" == "" && "${test_value}" == "${test_argument}" )) then
					@ arg--;
				else
					set arg_shifted;
					set equals=" ";
					set value="${test_value}";
				endif
				unset test_argument test_dashes test_option test_equals test_value;
			endif
		endif
		
		if( -e "${value}" ) then
			if( `printf "%s" "${value}" | sed -r 's/^(\/).*$/\1/'` != "/" ) \
				set value="${cwd}/${value}";
			set value_file="`mktemp --tmpdir .escaped.relative.filename.value.XXXXXXXX`";
			printf "%s" "${value}" >! "${value_file}";
			ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
			set escaped_value="`cat "\""${value_file}"\""`";
			rm -f "${value_file}";
			unset value_file;
			set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/)(\/)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
			while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\/)(.*)"\$"/\2/'`" == "/./" )
				set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/\.\/)/\//' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
			end
			while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\.\/)(.*)"\$"/\2/'`" == "/../" )
				set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(.*)(\/[^.]{2}[^/]+)(\/\.\.\/)(.*)"\$"/\1\/\4/' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
			end
			set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
			unset escaped_value;
		endif
		
		if( ${?debug} ) \
			printf "**debug** parsed "\$"argv[%d] (%s).\n\tParsed option: %s%s%s%s\n" "${arg}" "$argv[$arg]" "${dashes}" "${option}" "${equals}" "${value}";
		
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
					set create_script;
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
				#set value=`printf "%s" ${value}" | sed -r 's/^(.).*$/\1/'`;
				switch("${value}")
					case "forced":
					case "verbose":
					case "interactive":
					case "silent":
						if( "${value}" == "" || "${value}" == "switch" ) \
							set value="null";
						set removal_$value;
						set removal_switch=`printf "%s" "${value}" | sed -r 's/^([ifv]).*$/\1/'`;
						if( "${removal_switch}" != "${value}" ) then
							if( "${remove}" == "" ) then
								set remove="${removal_switch}";
							else if( `printf "%s" "${remove}" | sed -r "s/^.*(${removal_switch}).*"\$"/\1/"` != "${removal_switch}" ) then
								set remove="${remove}${removal_switch}";
							endif
						else
							unset removal_switch;
						endif
						
						if(! ${?remove} ) \
							set remove;
						breaksw;
						
					default:
						if(! ${?remove} ) \
							set remove;
						breaksw;
				endsw
				breaksw;
			
			case "recursive":
				set maxdepth;
				breaksw;
			
			case "append":
				set append;
				switch( "${value}" )
					case "auto":
					case "automatically":
						set append_automatically=-1;
					
					default:
						if( ${value} != "" && `printf "%s" "${value}" | sed -r 's/^([0-9]+)$//'` == "" ) then
							if( ${value} > 0 ) \
								set append_automatically="${value}";
						endif
						breaksw;
				endsw
				breaksw;
			
			case "maxdepth":
				if( ${?maxdepth} ) \
					breaksw;
				
				if( ${value} != "" && `printf "%s" "${value}" | sed -r 's/^([0-9]+)$//'` == "" ) then
					if( ${value} > 0 ) \
						set maxdepth=" -maxdepth ${value} ";
				endif
				
				if(! ${?maxdepth} ) \
					printf "--maxdepth must be an integer value that is gretter than 0." > /dev/stderr;
				breaksw;
			
			case "mindepth":
				if( ${?mindepth} ) \
					breaksw;
				
				if( ${value} != "" && `printf "%s" "${value}" | sed -r 's/^([0-9]+)$//'` == "" ) then
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
				set maxdepth;
				breaksw;
			
			case "search":
			case "target":
			case "directory":
			case "search-directory":
			case "target-directory":
				if( -d "${value}" ) \
					goto append_target_directory;
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
					goto append_target_directory;
				
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
	if(! ${?playlists_filename_list} ) \
		set playlists_filename_list="`mktemp --tmpdir "\""filename.list:playlists.for:${scripts_basename}.XXXXXXXX"\""`";
	
	printf "${value}\n" >> "${playlists_filename_list}";
	goto parse_arg;
#goto append_playlist;


append_target_directory:
	if(! ${?target_directories_filename_list} ) \
		set target_directories_filename_list="`mktemp --tmpdir "\""filename.list:target-directories.for:${scripts_basename}.XXXXXXXX"\""`";
	
	printf "${value}\n" >> "${target_directories_filename_list}";
	goto parse_arg;
#goto append_target_directory;


