#!/bin/tcsh -f
setup:
	if(! ${?0} ) \
		exit -1;
	
	alias ls "ls-F -N --color=always -T 0 --human-readable --quoting-style=c --classify  --group-directories-first --format=vertical --time-style='+%Y-%m-%d %H:%m:%S %Z(%:z)'";
	goto setup_lists;
#goto setup;


#regex to escape double quotes within a filename:
#	s/"/&\\&\\\\\\&\\&&/g
#-or-
#	s/\v(["])/\1\\\1\\\\\\\1\\\1\1/g
#will, for example, turn:
#	/media/podcasts/testing doule "quote".ogg
#into:
#	/media/podcasts/testing doule "\"\\\"\""quote"\"\\\"\"".ogg
#
setup_lists:
	set to_delete=( \
	"\n" \
	);
	
	set videos=( \
	"\n" \
	);
	
	set to_archive=( \
	"\n" \
	);
	
	goto setup_podcasts;
#goto setup_lists;


setup_podcasts:
	set lifestyle_podcasts=( \
	"\n" \
	);
	
	set erotica_podcasts=( \
	"\n" \
	);
	
	set slashdot_podcasts=( \
	"\n" \
"/media/podcasts/Slashdot/Crytek Dev On Fun vs. Realism In Game Guns, released on: Thu, 22 Jul 2010 09:04:00 GMT.mp3" \
	"\n" \
	);
	
	goto setup_podibooks;
#goto setup_podcasts;


setup_podibooks:
	set latest_podiobooks=( \
	"\n" \
"/media/podcasts/A Dance With Demons/37. ADWD 37 - A Dance With Demons, released on: Thu, 22 Jul 2010 09:22:22 GMT.mp3" \
	"\n" \
"/media/podcasts/Conjuring Raine/15. ConjuringRaine15 - Conjuring Raine, released on: Thu, 22 Jul 2010 09:23:03 GMT.mp3" \
	"\n" \
	);
	
	set between_the_covers_podiobooks=( \
	"\n" \
	);
	
	set podiobooks_dot_com_podiobooks=( \
	"\n" \
"/media/podcasts/No Doorway Wide Enough/10. NoDoorway 10 - No Doorway Wide Enough, released on: Thu, 22 Jul 2010 09:25:30 GMT.mp3" \
	"\n" \
	);
	
	set librivox_podiobook="Last Days Of Pompeii";
	set librivox_podiobooks=( \
	"\n" \
	);
	
	goto finalize_lists;
#goto setup_podibooks;


finalize_lists:
	set podcasts_to_restore=( \
	"\n" \
	);
	
	goto parse_argv;
#goto finalize_lists;


parse_argv:
	if(! ${?arg} ) then
		@ arg=0;
		@ argc=${#argv};
		if( $argc == 0 ) then
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
			case "no-validation":
			case "dont-validate-playlists":
				set dont_validate_playlists;
			
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
				
			case "archive":
				goto archive;
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
				
			default:
				goto clean_up;
				breaksw;
				
		endsw
	end
	
	goto exit_script;
#goto parse_argv;


exit_script:
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
			goto move_podcasts;
			breaksw;
		
		case 2:
			goto move_podiobooks;
			breaksw;
		
		case 3:
			goto videos;
			breaksw;
		
		case 4:
			goto archive;
			breaksw;
		
		case 5:
			goto alacasts_playlists;
			breaksw;
		
		default:
			unset goto_index callback;
			goto logs;
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
			goto move_podcasts;
			breaksw;
		
		case 2:
			goto move_podiobooks;
			breaksw;
		
		case 3:
			goto videos;
			breaksw;
		
		default:
			unset goto_index callback;
			goto archive;
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


move_podcasts:
	if( ${?lifestyle_podcasts} ) then
		set podcasts="${lifestyle_podcasts}";
		set podcasts_target_directory="/media/podcasts/lifestyle";
		unset lifestyle_podcasts;
	else if( ${?erotica_podcasts} ) then
		set podcasts="${erotica_podcasts}";
		set podcasts_target_directory="/media/podcasts/erotica";
		unset erotica_podcasts;
	else if( ${?slashdot_podcasts} ) then
		set podcasts="${slashdot_podcasts}";
		set podcasts_target_directory="/media/podcasts/slash.";
		unset slashdot_podcasts;
	else if( ${?podcasts_to_restore} ) then
		set podcasts="${podcasts_to_restore}";
		set podcasts_target_directory="/media/podcasts";
		unset podcasts_to_restore;
	else
		if( -d "/media/podcasts/Slashdot" ) then
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			rm -rv "/media/podcasts/Slashdot";
		endif
		
		if( ${?lifestyle_podcasts} ) \
			unset lifestyle_podcasts;
		
		if( ${?erotica_podcasts} ) \
			unset erotica_podcasts;
		
		if( ${?podcasts_to_restore} ) \
			unset podcasts_to_restore;
		
		if( ${?slashdot_podcasts} ) \
			unset slashdot_podcasts;
		
		unset podcasts podcasts_target_directory;
		goto parse_argv;
	endif
	
	foreach podcast( "`printf "\""${podcasts}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
		if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" )) then
			unset podcast;
			continue;
		endif
		
		if(! ${?action_preformed} ) then
			set action_preformed;
		else
			printf "\n\n";
		endif
		
		if(! -d "${podcasts_target_directory}" ) \
			mkdir -p  "${podcasts_target_directory}";
		
		set podcast_dir="`dirname "\""${podcast}"\""`";
		set podcast_name="`basename "\""${podcast_dir}"\""`";
		if( "${podcast_name}" != "Slashdot" ) then
			set podcast_name="/${podcast_name}";
		else
			set podcast_name="";
		endif
		
		if(! -d "${podcasts_target_directory}/${podcast_name}" ) \
			mkdir -v "${podcasts_target_directory}${podcast_name}";
		
		mv -vi \
			"${podcast}" \
		"${podcasts_target_directory}${podcast_name}/";
		
		if( `/bin/ls -A "${podcast_dir}"` == "" ) \
			rm -rv "${podcast_dir}";
		
		unset podcast podcast_dir podcast_name;
	end
	unset podcasts;
	
	goto move_podcasts;
#goto move_podcasts;


move_podiobooks:
	if( ${?latest_podiobooks} ) then
		set podiobooks="${latest_podiobooks}";
		set podiobooks_target_directory="/media/podiobooks/Latest";
		unset latest_podiobooks;
	else if( ${?podiobooks_dot_com_podiobooks} ) then
		set podiobooks="${podiobooks_dot_com_podiobooks}";
		set podiobooks_target_directory="/media/podiobooks/podiobooks.com";
		unset podiobooks_dot_com_podiobooks;
	else if( ${?librivox_podiobooks} ) then
		set podiobooks="${librivox_podiobooks}";
		set podiobooks_target_directory="/media/podiobooks/LibriVox Audiobooks";
		if( ${#librivox_podiobooks} > 1 ) then
			set current_podiobook="$librivox_podiobook";
		endif
		unset librivox_podiobooks librivox_podiobook;
	else if( ${?between_the_covers_podiobooks} ) then
		set podiobooks="${between_the_covers_podiobooks}";
		set podiobooks_target_directory="/media/podiobooks/Between the Covers from CBC Radio";
		if( ${#between_the_covers_podiobooks} > 1 ) then
			set current_podiobook="`printf "\""%s"\"" "\""$between_the_covers_podiobooks[2]"\"" | sed -r 's/(.*\/)(.*)( [0-9]+)(,.*)"\$"/\2/'`";
		endif
		unset between_the_covers_podiobooks;
	else
		if( ${?librivox_podiobook} ) \
			unset librivox_podiobook;
		if( ${?librivox_podiobooks} ) \
			unset librivox_podiobooks;
		if( ${?between_the_covers_podiobooks} ) \
			unset between_the_covers_podiobooks;
		if( ${?podiobooks_dot_com_podiobooks} ) \
			unset podiobooks_dot_com_podiobooks;
		if( ${?current_podiobook} ) \
			unset current_podiobook;
		unset podiobooks podiobooks_target_directory;
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


archive:
	if( ${?to_archive} ) then
		foreach podcast( "`printf "\""${to_archive}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" )) then
				unset podcast;
				continue;
			endif
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
			
			set podcast_dir="`dirname "\""${podcast}"\""`";
			set podcast_dir="`basename "\""${podcast_dir}"\""`";
			switch( "${podcast_dir}" )
				case "slash.":
					set podcast_dir="Slashdot";
					breaksw;
			endsw
			
			if(! -d "/art/media/resources/archived-podcasts/${podcast_dir}" ) \
				mkdir -p "/art/media/resources/archived-podcasts/${podcast_dir}";
			
			mv -vi \
				"${podcast}" \
			"/art/media/resources/archived-podcasts/${podcast_dir}";
			
			set podcast_dir="`dirname "\""${podcast}"\""`";
			if( `/bin/ls -A "${podcast_dir}"` == "" ) \
				rm -rv "${podcast_dir}";
			unset podcast_dir podcast;
		end
		unset to_archive;
	endif
	
	goto parse_argv;
#goto archive;


alacasts_playlists:
	set playlist_dir="/media/podcasts/playlists/m3u";
	
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
			printf "<file://%s/%s> still lists files.\n" "${playlist_dir}" "${playlist}" > /dev/stderr;
			
			if(! ${?dont_validate_playlists} ) then
				printf "\tWould you like to remove it:\n" > /dev/stderr;
				rm -vi "${playlist_dir}/${playlist}";
				if(! -e "${playlist_dir}/${playlist}" ) then
					if(! ${?action_preformed} ) then
						set action_preformed;
					else
						printf "\n\n";
					endif
				endif
			endif
		else	
			rm -v "${playlist_dir}/${playlist}";
			
			if(! ${?action_preformed} ) then
				set action_preformed;
			else
				printf "\n\n";
			endif
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


