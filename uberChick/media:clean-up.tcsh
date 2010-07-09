#!/bin/tcsh -f
setup:
	if(! ${?0} ) \
		exit -1;
	
	goto setup_lists;
#goto setup;


setup_lists:
	set to_delete=( \
	"\n" \
	);
	
	set lifestyle_podcasts=( \
	"\n" \
	);
	
	set slashdot=( \
	"\n" \
	);
	
	set videos=( \
	"\n" \
	);
	
	set erotic_podcasts=( \
	"\n" \
	);
	
	set podcasts_to_backup=( \
	"\n" \
	);
	goto setup_podibooks;
#goto setup_lists;


setup_podibooks:
	set latest_podiobooks=( \
	"\n" \
"/media/podcasts/Pseudopod/Pseudopod 202: Eye Spy, released on: Fri, 09 Jul 2010 05:01:55 GMT.mp3" \
	"\n" \
	);
	
	set librivox_podiobooks=( \
	"\n" \
	);
	set librivox_podiobook="Last Days Of Pompeii";
	
	set between_the_covers_podiobooks=( \
	"\n" \
	);
	set between_the_covers_podiobook="DeNiro's Game";
	goto parse_argv;
#goto setup_podibooks;


parse_argv:
	if(! ${?arg} ) then
		@ arg=0;
		@ argc=${#argv};
		if( $argc == 0 ) then
			set confirmation;
			set confirmations=( "r" "r" "r" );
			set playlists_validated;
			goto clean_up;
		endif
	else if ${?callback} then
		goto ${callback};
	endif
	
	while( $arg < $argc )
		@ arg++;
		set option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
		set value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
		switch( "${option}" )
			case "no-validation":
				set option="disable";
				set value="playlist-validation";
				
			case "disable":
				switch("${value}")
					case "playlist-validation":
						set confirmation;
						set confirmations=( "r" "r" "r" );
						set playlists_validated;
						breaksw;
					endsw
				
			case "clean-up":
				goto clean_up;
				breaksw;
				
			case "playlists":
				goto playlists;
				breaksw;
				
			case "move":
				goto move;
				breaksw;
				
			case "videos":
				goto videos;
				breaksw;
				
			case "backup":
			case "back-up":
				goto backup;
				breaksw;
				
			case "delete":
				goto delete;
				breaksw;
				
			case "logs":
				goto logs;
				breaksw;
				
			case "clean-playlists":
				goto alacasts_playlists;
				breaksw;
				
			case "validate-playlists":
				goto validate_playlists;
				breaksw;
				
			default:
				goto clean_up;
				breaksw;
				
		endsw
	end
	
	if(! ${?playlists_validated} ) \
		goto validate_playlists;
			
	goto exit_script;
#goto parse_argv;


exit_script:
	if( ${?validate_playlists} ) \
		unset validate_playlists;
	
	if( ${?playlists_validated} ) \
		unset playlists_validated;
	
	if( ${?action_preformed} ) \
		unset action_preformed;
	exit 0;
#goto exit_script;


clean_up:
	set callback="clean_up";
	if(! ${?goto_index} ) then
		@ goto_index=0;
	else
		@ goto_index++;
		if( ${?action_preformed} ) then
			printf "\n\n";
			unset action_preformed;
		endif
	endif
	
	switch( $goto_index )
		case 0:
			goto delete;
			breaksw;
		
		case 1:
			goto move_lifestyle_podcasts;
			breaksw;
		
		case 2:
			goto move_podiobooks;
			breaksw;
		
		case 3:
			goto move_slashdot;
			breaksw;
		
		case 4:
			goto videos;
			breaksw;
		
		case 5:
			goto move_erotic_podcasts;
			breaksw;
		
		case 6:
			goto backup;
			breaksw;
		
		case 7:
			goto alacasts_playlists;
			breaksw;
		
		case 8:
			goto logs;
			breaksw;
		
		default:
			unset goto_index callback;
			breaksw;
	endsw
	goto parse_argv;
#goto clean_up;


move:
	set callback="move";
	if(! ${?goto_index} ) then
		@ goto_index=1;
	else
		@ goto_index++;
		if( ${?action_preformed} ) then
			printf "\n\n";
			unset action_preformed;
		endif
	endif
	
	switch( $goto_index )
		case 1:
			goto move_lifestyle_podcasts;
			breaksw;
		
		case 2:
			goto move_podiobooks;
			breaksw;
		
		case 3:
			goto move_slashdot;
			breaksw;
		
		case 4:
			goto videos;
			breaksw;
		
		case 5:
			goto move_erotic_podcasts;
			breaksw;
		
		default:
			unset goto_index callback;
			goto backup;
			breaksw;
	endsw
	goto parse_argv;
#goto move;


playlists:
	set callback="playlists";
	if(! ${?goto_index} ) then
		@ goto_index=0;
	else
		@ goto_index++;
		if( ${?action_preformed} ) then
			printf "\n\n";
			unset action_preformed;
		endif
	endif
	
	switch( $goto_index )
		case 0:
			goto alacasts_playlists;
			breaksw;
		
		case 1:
			goto logs;
			breaksw;
		
		default:
			unset goto_index callback;
			breaksw;
	endsw
	goto parse_argv;
#goto playlists;


delete:
	if( ${?to_delete} ) then
		foreach podcast( "`printf "\""${to_delete}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" )) \
				continue;
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			if( -d "${podcast}" ) then
				rm -rv "${podcast}";
				continue;
			endif
			
			rm -v "${podcast}";
			
			set podcast_dir="`dirname "\""${podcast}"\""`";
			if( `/bin/ls -A "${podcast_dir}"` == "" ) \
				rm -rv "${podcast_dir}";
			unset podcast_dir;
			
		end
		unset podcast;
		unset to_delete;
	endif
	
	goto parse_argv;
#goto delete;


move_lifestyle_podcasts:
	if( ${?lifestyle_podcasts} ) then
		foreach podcast( "`printf "\""${lifestyle_podcasts}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" )) then
				unset podcast;
				continue;
			endif
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			if(! -d "/media/podcasts/lifestyle" ) \
				mkdir -p  "/media/podcasts/lifestyle";
			
			set podcast_dir="`dirname "\""${podcast}"\""`";
			set podcast_name="`basename "\""${podcast_dir}"\""`";
			if(! -d "/media/podcasts/lifestyle/${podcast_name}" ) \
				mkdir -v "/media/podcasts/lifestyle/${podcast_name}";
			
			mv -vi \
				"${podcast}" \
			"/media/podcasts/lifestyle/${podcast_name}/";
			
			if( `/bin/ls -A "${podcast_dir}"` == "" ) \
				rm -rv "${podcast_dir}";
			
			unset podcast podcast_dir podcast_name;
		end
		unset lifestyle_podcasts;
	endif
	
	goto parse_argv;
#goto move_lifestyle_podcasts;


move_erotic_podcasts:
	if( ${?erotic_podcasts} ) then
		foreach podcast( "`printf "\""${erotic_podcasts}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" )) then
				unset podcast;
				continue;
			endif
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			if(! -d "/media/podcasts/erotica" ) \
				mkdir -p  "/media/podcasts/erotica";
			
			set podcast_dir="`dirname "\""${podcast}"\""`";
			set podcast_name="`basename "\""${podcast_dir}"\""`";
			if(! -d "/media/podcasts/erotica/${podcast_name}" ) \
				mkdir -v "/media/podcasts/erotica/${podcast_name}";
			
			mv -vi \
				"${podcast}" \
			"/media/podcasts/erotica/${podcast_name}/";
			
			if( `/bin/ls -A "${podcast_dir}"` == "" ) \
				rm -rv "${podcast_dir}";
			
			unset podcast podcast_dir podcast_name;
		end
		unset erotic_podcasts;
	endif
	
	goto parse_argv;
#goto move_erotic_podcasts;


move_lifestyle_podcasts:
	if( ${?lifestyle_podcasts} ) then
		foreach podcast( "`printf "\""${lifestyle_podcasts}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" )) then
				unset podcast;
				continue;
			endif
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			if(! -d "/media/podcasts/lifestyle" ) \
				mkdir -p  "/media/podcasts/lifestyle";
			
			set podcast_dir="`dirname "\""${podcast}"\""`";
			set podcast_name="`basename "\""${podcast_dir}"\""`";
			if(! -d "/media/podcasts/lifestyle/${podcast_name}" ) \
				mkdir -v "/media/podcasts/lifestyle/${podcast_name}";
			
			mv -vi \
				"${podcast}" \
			"/media/podcasts/lifestyle/${podcast_name}/";
			
			if( `/bin/ls -A "${podcast_dir}"` == "" ) \
				rm -rv "${podcast_dir}";
			
			unset podcast podcast_dir podcast_name;
		end
		unset lifestyle_podcasts;
	endif
	
	goto parse_argv;
#goto move_lifestyle_podcasts;


move_podiobooks:
	if( ${?latest_podiobooks} ) then
		set podiobooks="${latest_podiobooks}";
		set podiobooks_target_directory="/media/podiobooks/Latest";
		unset latest_podiobooks;
	else if( ${?librivox_podiobooks} ) then
		set podiobooks="${librivox_podiobooks}";
		set podiobooks_target_directory="/media/podiobooks/LibriVox Audiobooks";
		set current_podiobook="${librivox_podiobook}";
		unset librivox_podiobooks librivox_podiobook;
	else if( ${?between_the_covers_podiobooks} ) then
		set podiobooks="${between_the_covers_podiobooks}";
		set podiobooks_target_directory="/media/podiobooks/Between the Covers from CBC Radio";
		set current_podiobook="${between_the_covers_podiobook}";
		unset between_the_covers_podiobooks between_the_covers_podiobook;
	else
		goto parse_argv;
	endif
	
	foreach podiobook( "`printf "\""${podiobooks}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
		if(!( "${podiobook}" != "" && "${podiobook}" != "/" && -e "${podiobook}" )) then
			unset podiobook;
			continue;
		endif
		
		if(! ${?action_preformed} ) then
			set action_preformed;
		else
			printf "\n\n";
		endif
		
		if(! -d "${podiobooks_target_directory}" ) \
			mkdir -p  "${podiobooks_target_directory}";
		
		set podiobook_dir="`dirname "\""${podiobook}"\""`";
		if(! ${?current_podiobook} ) \
			set current_podiobook_set current_podiobook="`basename "\""${podiobook_dir}"\""`";
		
		if(! -d "${podiobooks_target_directory}/${current_podiobook}/" ) \
			mkdir -pv "${podiobooks_target_directory}/${current_podiobook}/";
		
		mv -vi \
			"${podiobook}" \
		"${podiobooks_target_directory}/${current_podiobook}/";
		
		if( `/bin/ls -A "${podiobook_dir}"` == "" ) \
			rm -rv "${podiobook_dir}";
		
		if( ${?current_podiobook_set} ) \
			unset current_podiobook_set current_podiobook;
		unset podiobook podiobook_dir;
	end
	
	if( ${?current_podiobook} ) \
		unset current_podiobook;
	unset podiobooks podiobooks_target_directory;
	
	goto move_podiobooks;
#goto move_podiobooks;


move_slashdot:
	if( ${?slashdot} ) then
		foreach podcast( "`printf "\""${slashdot}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" )) then
				unset podcast;
				continue;
			endif
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			if(! -d "/media/podcasts/slash." ) \
				mkdir -p  "/media/podcasts/slash.";
			
			mv -vi \
				"${podcast}" \
			"/media/podcasts/slash.";
			
			set podcast_dir="`dirname "\""${podcast}"\""`";
			if( `/bin/ls -A "${podcast_dir}"` == "" ) \
				rm -rv "${podcast_dir}";
			unset podcast_dir podcast;
		end
		unset slashdot;
	endif
	
	if( -d "/media/podcasts/Slashdot" ) then
		if(! ${?action_preformed} ) then
			set action_preformed;
		else
			printf "\n\n";
		endif
		
		rm -rv "/media/podcasts/Slashdot";
	endif
	
	goto parse_argv;
#goto move_slashdot;


videos:
	if( ${?videos} ) then
		foreach video( "`printf "\""${videos}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${video}" != "" && "${video}" != "/" && -e "${video}" )) then
				unset video;
				continue;
			endif
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			if(! -d "/media/videos/podcasts" ) \
				mkdir -p  "/media/videos/podcasts";
			
			set video_dir="`dirname "\""${video}"\""`";
			set video_name="`basename "\""${video_dir}"\""`";
			if(! -d "/media/videos/podcasts/${video_name}" ) \
				mkdir -v "/media/videos/podcasts/${video_name}";
			
			mv -vi \
				"${video}" \
			"/media/videos/podcasts/${video_name}/";
			
			if( `/bin/ls -A "${video_dir}"` == "" ) \
				rm -rv "${video_dir}";
			
			unset video video_dir video_name;
		end
		unset videos;
	endif
	
	goto parse_argv;
#goto videos;


backup:
	if( ${?podcasts_to_backup} ) then
		foreach podcast( "`printf "\""${podcasts_to_backup}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" )) then
				unset podcast;
				continue;
			endif
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			if(! -d "/art/media/resources/stories/Slashdot" ) \
				mkdir -p  "/art/media/resources/stories/Slashdot";
			
			mv -vi \
				"${podcast}" \
			"/art/media/resources/stories/Slashdot";
			
			set podcast_dir="`dirname "\""${podcast}"\""`";
			if( `/bin/ls -A "${podcast_dir}"` == "" ) \
				rm -rv "${podcast_dir}";
			unset podcast_dir podcast;
		end
		unset podcasts_to_backup;
	endif
	
	goto parse_argv;
#goto backup;


alacasts_playlists:
	set playlist_dir="/media/podcasts/playlists/m3u";
	if(! ${?confirmation} ) then
		set return_to="alacasts_playlists";
		goto prompt_for_playlist_validation;
	endif
	
	foreach playlist("`/bin/ls --width=1 -t "\""${playlist_dir}"\""`")
		set playlist_escaped="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/([\/.])/\\\1/g'`";
		if(! ${?playlist_count} ) then
			printf "Cleaning up %s...\n" "${playlist_dir}";
			@ playlist_count=1;
		else
			@ playlist_count++;
		endif
		
		if( "`find "\""${playlist_dir}"\"" -iregex "\"".*\/\.${playlist_escaped}\.sw."\""`" != "" ) then
			printf "<file://%s/%s> is in use and will not be deleted.\n" "${playlist_dir}" "${playlist}" > /dev/stderr;
		else if( "`wc -l "\""${playlist_dir}/${playlist}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" > 1 ) then
			printf "<file://%s/%s> still lists files.\n\tWould you like to remove it:\n" "${playlist_dir}" "${playlist}" > /dev/stderr;
			rm -vi "${playlist_dir}/${playlist}";
			if(! -e "${playlist_dir}/${playlist}" ) then
				if(! ${?action_preformed} ) then
					set action_preformed;
				else
					printf "\n\n";
				endif
			else if( ${?validate_playlists} ) then
				printf "\tWould you like to make sure that all files in <file://%s/%s> still exist? [Yes/No(default)]" "${playlist_dir}" "${playlist}" > /dev/stdout;
				set confirmation="$<";
				#set rconfirmation=$<:q;
				printf "\n";
				
				switch(`printf "%s" "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
					case "y":
						set playlist_check_result="`playlist:find:non-existent:listings.tcsh --clean-up "\""${playlist}"\""`";
						if( "${playlist_check_result}" != "" ) then
							printf "%s" "${playlist_check_result}";
							if(! ${?action_preformed} ) then
								set action_preformed;
							else
								printf "\n\n";
							endif
						endif
						unset playlist_check_result;
					breaksw;
				
				case "n":
				default:
					breaksw;
				endsw
			endif
		else	
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			rm -v "${playlist_dir}/${playlist}";
		endif
		unset playlist_escaped playlist;
	end
	unset playlist_count playlist_dir;
	goto parse_argv;
#goto alacasts_playlists;


logs:
	set current_day=`date "+%d"`
	set current_month=`date "+%m"`
	set current_year=`date "+%Y"`;
	
	set current_hour=`date "+%k"`
	set current_hour=`printf "%d-(%d%%6)\n" "${current_hour}" "${current_hour}" | bc`;
	if( ${current_hour} < 10 ) \
		set current_hour="0${current_hour}";
	
	if( "`find /media/podcasts/ -regextype posix-extended -iregex '.*alacast'\''s log for .*' \! -iregex '.*alacast'\''s log for ${current_year}-${current_month}-${current_day} from ${current_hour}.*'`" != "" ) then
		if(! ${?action_preformed} ) then
			set action_preformed;
		else
			printf "\n\n";
		endif
		
		( rm -v "`find /media/podcasts/ -regextype posix-extended -iregex '.*alacast'\''s log for .*' \! -iregex '.*alacast'\''s log for ${current_year}-${current_month}-${current_day} from ${current_hour}.*'`" > /dev/tty ) >& /dev/null;
	endif
	
	goto parse_argv;
#goto logs;


validate_playlists:
	set return_to="validate_playlists";
	if(! ${?confirmation} ) \
		goto prompt_for_playlist_validation;
	
	if(! ${?playlists_validated} ) then
		set playlists_validated;
	else
		goto parse_arge;
	endif
	
	if(! ${?validate_playlists} ) \
		goto parse_argv;
	
	set playlist_data=( "/media/library/playlists/m3u/artistic.podcasts.m3u" "/media/podcasts" "/media/library/playlists/m3u/local.podiobooks.m3u" "/media/podiobooks/Latest" "/media/library/playlists/m3u/lifestyle.podcasts.m3u" "/media/podcasts/lifestyle" "/media/library/playlists/m3u/science.podcasts.m3u" "/media/podcasts/science" "/media/library/playlists/m3u/culture.podcasts.m3u" "/media/podcasts/culture" );
	
	if(! ${?confirmations} ) \
		set confirmations=( "" "" "" );
	
	@ playlist_index=0;
	while( $playlist_index < ${#playlist_data} )
		@ playlist_index++;
		set playlist=$playlist_data[$playlist_index];
		@ playlist_index++;
		set playlist_dir=$playlist_data[$playlist_index];
		@ playlist_check=0;
		while( $playlist_check < 3 )
			@ playlist_check++;
			if( "$confirmations[$playlist_check]" != "" ) then
				set confirmation="$confirmations[$playlist_check]";
			else
				switch( $playlist_check )
					case 1:
						printf "\tWould you like to remove any files found under <file://%s> which are not listed in <file://%s>:" "${playlist_dir}" "${playlist}" > /dev/stdout;
						breaksw;
					
					case 2:
						printf "\tWould you like to update <file://%s> to include all files found under <file://%s>:" "${playlist}" "${playlist_dir}" > /dev/stdout;
						breaksw;
					
					case 3:
						printf "\tWould you like to make sure that all files in <file://%s> still exist:" "${playlist}" > /dev/stdout;
						breaksw;
				endsw
				printf "\n\t[Always/Yes/No(default)/Reject all]?" > /dev/stdout;
				
				set confirmation="$<";
				#set rconfirmation=$<:q;
				printf "\n";
			endif
			
			switch(`printf "%s" "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
				case "a":
					if( "$confirmations[$playlist_check]" == "" ) then
						set confirmations[$playlist_check]="${confirmation}";
					else
						switch( $playlist_check )
							case 1:
								printf "\tRemoving any files found under <file://%s> which are not listed in <file://%s>" "${playlist_dir}" "${playlist}" > /dev/stdout;
								breaksw;
							
							case 2:
								printf "\tUpdating <file://%s> to include all files found under <file://%s>" "${playlist}" "${playlist_dir}" > /dev/stdout;
								breaksw;
							
							case 3:
								printf "\tEnsuring all files in <file://%s> still exist." "${playlist}" > /dev/stdout;
								breaksw;
						endsw
						printf "\n";
					endif
				case "y":
					set playlist_check_file="`mktemp -u --tmpdir filename_list.XXXXXXXX`";
					switch( $playlist_check )
						case 1:
							playlist:find:missing:listings.tcsh "${playlist}" "${playlist_dir}" --extensions='(mp3|ogg|m4a|wma)' --remove=interactive >! "${playlist_check_file}";
							breaksw;
						
						case 2:
							playlist:find:missing:listings.tcsh "${playlist}" "${playlist_dir}" --extensions='(mp3|ogg|m4a|wma)' --append >! "${playlist_check_file}";
							breaksw;
						
						case 3:
							playlist:find:non-existent:listings.tcsh --clean-up "${playlist}" >! "${playlist_check_file}";
							breaksw;
					endsw
					
					set playlist_check_result="`cat "\""${playlist_check_file}"\""`";
					if( "${playlist_check_result}" != "" ) then
						printf "%s" "${playlist_check_result}";
						if(! ${?action_preformed} ) then
							set action_preformed;
						else
							printf "\n\n";
						endif
					endif
					rm -f "${playlist_check_file}";
					unset playlist_check_file playlist_check_result;
					
					breaksw;
				
				case "r":
					if( "$confirmations[$playlist_check]" == "" ) then
						set confirmations[$playlist_check]="${confirmation}";
					else
						switch( $playlist_check )
							case 1:
								printf "\tSkipping checks to remove any files found under <file://%s> which are not listed in <file://%s>" "${playlist_dir}" "${playlist}" > /dev/stdout;
								breaksw;
							
							case 2:
								printf "\tSkipping checks to update <file://%s> to include all files found under <file://%s>" "${playlist}" "${playlist_dir}" > /dev/stdout;
								breaksw;
							
							case 3:
								printf "\tSkipping checks to make sure that all files in <file://%s> still exist" "${playlist}" > /dev/stdout;
								breaksw;
						endsw
						printf "\n";
					endif
				case "n":
				default:
					breaksw;
			endsw
		end
		unset playlist_check playlist_dir playlist;
	end
	unset playlist_data playlist_index;
	
	goto parse_argv;
#goto validate_playlists;


prompt_for_playlist_validation:
	printf "\n\tWould you like to validate existing playlists? [Yes/Always/No(default)]" > /dev/stdout;
	set confirmation="$<";
	#set rconfirmation=$<:q;
	
	switch(`printf "%s" "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
		case "a":
			set confirmations=( "a" "a" "a" );
		case "y":
			set validate_playlists;
			breaksw;
		case "n":
		default:
			breaksw;
	endsw
	
	goto $return_to;
#goto prompt_for_playlist_validation;


