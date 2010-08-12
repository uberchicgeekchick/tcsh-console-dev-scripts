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
	);
	
	goto setup_podibooks;
#goto setup_podcasts;


setup_podibooks:
	set latest_podiobooks=( \
	"\n" \
	);
	
	set between_the_covers_podiobooks=( \
	"\n" \
	);
	
	set podiobooks_dot_com_podiobooks=( \
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
			goto move;
			breaksw;
		
		case 2:
			goto archive;
			breaksw;
		
		case 3:
			goto alacasts_playlists;
			breaksw;
		
		default:
			unset goto_index callback;
			goto logs;
			breaksw;
	endsw
	goto parse_argv;
#goto clean_up;


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


move:
	if( ${?lifestyle_podcasts} ) then
		set podcasts="${lifestyle_podcasts}";
		set podcasts_target_directory="/media/podcasts/lifestyle";
		unset lifestyle_podcasts;
	else if( ${?erotica_podcasts} ) then
		set podcasts="${erotica_podcasts}";
		set podcasts_target_directory="/media/podiobooks/erotica";
		unset erotica_podcasts;
	else if( ${?slashdot_podcasts} ) then
		set podcasts="${slashdot_podcasts}";
		set podcasts_target_directory="/media/podcasts/slash.";
		unset slashdot_podcasts;
	else if( ${?podcasts_to_restore} ) then
		set podcasts="${podcasts_to_restore}";
		set podcasts_target_directory="/media/podcasts";
		unset podcasts_to_restore;
	else if( ${?videos} ) then
		set podcasts="${videos}";
		set podcasts_target_directory="/media/videos/podcasts";
		unset videos;
	else if( ${?latest_podiobooks} ) then
		set podcasts="${latest_podiobooks}";
		set podcasts_target_directory="/media/podiobooks/Latest";
		unset latest_podiobooks;
	else if( ${?podiobooks_dot_com_podiobooks} ) then
		set podcasts="${podiobooks_dot_com_podiobooks}";
		set podcasts_target_directory="/media/podiobooks/podiobooks.com";
		unset podiobooks_dot_com_podiobooks;
	else if( ${?librivox_podiobooks} ) then
		set podcasts="${librivox_podiobooks}";
		set podcasts_target_directory="/media/podiobooks/LibriVox Audiobooks";
		if( ${#librivox_podiobooks} > 1 ) then
			set podcast_name="${librivox_podiobook}";
		endif
		unset librivox_podiobooks librivox_podiobook;
	else if( ${?between_the_covers_podiobooks} ) then
		set podcasts="${between_the_covers_podiobooks}";
		set podcasts_target_directory="/media/podiobooks/Between the Covers from CBC Radio";
		unset between_the_covers_podiobooks;
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
		
		if( ${?librivox_podiobook} ) \
			unset librivox_podiobook;
		if( ${?librivox_podiobooks} ) \
			unset librivox_podiobooks;
		if( ${?between_the_covers_podiobooks} ) \
			unset between_the_covers_podiobooks;
		if( ${?podiobooks_dot_com_podiobooks} ) \
			unset podiobooks_dot_com_podiobooks;
		if( ${?videos} ) \
			unset videos;
		if( ${?podcast_name} ) \
			unset podcast_name;
		
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
		
		if(! -d "${podcast}" ) then
			set podcast_dir="`dirname "\""${podcast}"\""`";
			if(! ${?podcast_name} ) \
				set podcast_name_set podcast_name="`basename "\""${podcast_dir}"\""`";
			
			switch("${podcast_name}")
				case "Slashdot":
					set podcast_name="";
					breaksw;
				
				case "Between the Covers from CBC Radio":
					set podcast_name="`printf "\""%s"\"" "\""${podcast_name}"\"" | sed -r 's/(.*\/)(.*)( [-0-9]+)(.*)"\$"/\2/'`";
					breaksw;
			endsw
		else
			if(! ${?podcast_name} ) \
				set podcast_name_set podcast_name="`basename "\""${podcast}"\""`";
			set podcast_dir="${podcast}";
		endif
		
		if(! -d "${podcasts_target_directory}/${podcast_name}" ) \
			mkdir -v "${podcasts_target_directory}/${podcast_name}";
		
		mv -vi \
			"${podcast}" \
		"${podcasts_target_directory}/${podcast_name}/";
		
		if( `/bin/ls -A "${podcast_dir}"` == "" ) \
			rm -rv "${podcast_dir}";
		
		if( ${?podcast_name_set} ) \
			unset podcast_set_name podcast_name;
		unset podcast podcast_dir;
	end
	unset podcasts;
	
	goto move;
#goto move;


archive:
	if( ${?to_archive} ) then
		foreach podcast( "`printf "\""${to_archive}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if(!( "${podcast}" != "" && "${podcast}" != "/" && -e "${podcast}" && "`printf "\""%s"\"" "\""${podcast}"\"" | sed '^.*\/(archive)\/.*"\$"/\1`" != "archive" )) then
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
				
				default:
					if( "`printf "\""%s"\"" "\""${podcast}"\"" | sed '^\/media\/(podiobooks)\/.*"\$"/\1`" == "podiobooks" ) then
						set podcast_dir="`printf "\""%s"\"" "\""${podcast}"\"" | sed '^(\/media\/podiobooks)\/[^/]+\/([^/]+\/.*"\$"/\1\/archived\/\2/'`";
						breaksw;
					endif
					
					set podcast_top_dir="`dirname "\""${podcast}"\""`";
					set podcast_top_dir="`dirname "\""${podcast_top_dir}"\""`";
					set podcast_top_dir="`basename "\""${podcast_top_dir}"\""`";
					switch("${podcast_top_dir}")
						case "lifestyle":
						case "erotica":
							set podcast_dir="${podcast_top_dir}/${podcast_dir}";
							breaksw;
						default:
							breaksw;
					endsw
					unset podcast_top_dir;
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
	set playlist_dir="/media/podcasts/playlists/tox";
	set playlist_type="`basename "\""${playlist_dir}"\""`";
	
	foreach playlist("`/bin/ls --width=1 -t "\""${playlist_dir}"\""`")
		switch("${playlist}")
			case "alacast's latest ${playlist_type} playlist.${playlist_type}":
			case "lastest.${playlist_type}":
				unset playlist;
				continue;
				breaksw;
		endsw
		
		set playlist_escaped="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/([/.])/\\\1/g'`";
		if(! ${?playlist_count} ) then
			printf "Cleaning up %s...\n" "${playlist_dir}";
			@ playlist_count=1;
		else
			@ playlist_count++;
		endif
		
		if( "`find "\""${playlist_dir}"\"" -iregex "\"".*\/\.${playlist_escaped}\.sw."\""`" != "" ) then
			printf "<file://%s/%s> is in use and will not be deleted.\n" "${playlist_dir}" "${playlist}" > /dev/stderr;
		else if( "`wc -l "\""${playlist_dir}/${playlist}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" > 3 ) then
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


