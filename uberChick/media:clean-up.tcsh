#!/bin/tcsh -f

parse_argv:
	if(! ${?arg} ) then
		@ arg=0;
		@ argc=${#argv};
		if( $argc == 0 ) \
			goto clean_up;
	else if ${?callback} then
		goto $callback;
	endif
	
	while( $arg < $argc )
		switch( "$argv[${arg}]" )
			case "--clean-up":
				goto clean_up;
			case "--move":
				goto move;
			case "--back-up":
				goto back_up;
			case "--delete":
				goto delete;
			case "--playlists":
				goto playlists;
			case "--logs":
				goto logs;
			default:
				goto clean_up;
		endsw
	end
	goto exit_script;
#goto parse_argv;


exit_script:
	exit 0;
#goto exit_script;


clean_up:
	set callback="clean_up";
	if(! ${?goto_index} ) then
		@ goto_index=0;
	else
		@ goto_index++;
	endif
	switch( $goto_index )
		case 0:
			goto move;
			breaksw;
			
		case 1:
			goto back_up;
			breaksw;
			
		case 2:
			goto delete;
			breaksw;
			
		case 3:
			goto playlists;
			breaksw;
			
		case 4:
			goto logs;
			breaksw;
			
		default:
			unset goto_index callback;
			breaksw;
	endsw
	goto parse_argv;
#goto clean_up;


move:
	set podiobooks=( \
	"\n" \
"/media/podiobooks/Latest/Prince of Hazel and Oak, The/06. Hazelandoak 06 - The Prince of Hazel and Oak, released on: Thu, 03 Jun 2010 07:01:23 GMT.ogg" \
	"\n" \
"/media/podiobooks/Latest/Time Crystal 02/17. TimeCrystalVol2-17 - Time Crystal 02, released on: Wed, 02 Jun 2010 07:01:40 GMT.ogg" \
	"\n" \
	);
	
	if( ${?podiobooks} ) then
		foreach podiobook_episode( "`printf "\""${podiobooks}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			set podiobook="`dirname "\""${podiobook_episode}"\""`";
			set podiobook="`basename "\""${podiobook}"\""`";
			set podiobook_episode="/media/podcasts/${podiobook}";
			if( "${podiobook_episode}" != "" && -e "${podiobook_episode}" ) then
				if(! -d "/media/podiobooks/Latest" ) \
					mkdir -p  "/media/podiobooks/Latest";
				
				mv -v \
					"${podiobook_episode}" \
				"/media/podiobooks/Latest";
			endif
			unset podiobook podiobook_episode;
		end
		unset podiobooks;
	endif
	
	set slashdot=( \
	"\n" \
"/media/podcasts/Slashdot/Smokescreen, a JavaScript-Based Flash Player, released on: Tue, 01 Jun 2010 18:17:00 GMT.mp3" \
	"\n" \
	);
	
	if( ${?slashdot} ) then
		foreach podcast( "`printf "\""${slashdot}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if( "${podcast}" != "" && -e "${podcast}" ) then
				if(! -d "/media/podcasts/slash." ) \
					mkdir -p  "/media/podcasts/slash.";
				
				mv -v \
					"${podcast}" \
				"/media/podcasts/slash.";
			endif
			unset podcast;
		end
		unset slashdot;
	endif
	
	goto parse_argv;
#goto move;


back_up:
	set slashdot=( \
	"\n" \
	"\n" \
	);
	
	if( ${?slashdot} ) then
		foreach podcast( "`printf "\""${slashdot}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if( "${podcast}" != "" && -e "${podcast}" ) then
				if(! -d "/art/media/resources/stories/Slashdot" ) \
					mkdir -p  "/art/media/resources/stories/Slashdot";
				
				mv -v \
					"${podcast}" \
				"/art/media/resources/stories/Slashdot";
			endif
			unset podcast;
		end
		unset slashdot;
	endif
	
	goto parse_argv;
#goto back_up;


delete:
	set to_be_deleted=( \
	"\n" \
	"\n" \
	);
	
	if( ${?to_be_deleted} ) then
		foreach podcast( "`printf "\""${to_be_deleted}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if( "${podcast}" != "" && -e "${podcast}" ) then
				if( -d "${podcast}" ) then
					rm -rv \
						"${podcast}";
				else
					rm -v \
						"${podcast}";
				endif
			endif
			unset podcast;
		end
		unset to_be_deleted;
	endif
	
	set directories_to_delete=( \
	"\n" \
	);
	
	if( ${?directories_to_delete} ) then
		foreach podcast( "`printf "\""${directories_to_delete}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if( "${podcast}" != "" ) then
				set podcast_dir="`dirname "\""${podcast}"\""`";
				if( "${podcast_dir}" != "/media/podcasts" && -d "${podcast_dir}" ) \
					rm -rv \
						"${podcast_dir}";
			endif
			unset podcast_dir podcast;
		end
		unset directories_to_delete;
	endif
	
	if( -d "/media/podcasts/Slashdot" ) \
		rm -rv "/media/podcasts/Slashdot";
	
	goto parse_argv;
#goto delete;

playlists:
	set playlist_dir="/media/podcasts/playlists/m3u";
	foreach playlist("`/bin/ls --width=1 -t "\""${playlist_dir}"\""`")
		set playlist_escaped="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/([\/.])/\\\1/g'`";
		if(! ${?playlist_count} ) then
			@ playlist_count=1;
		else
			@ playlist_count++;
		endif
		
		if( "`find "\""${playlist_dir}"\"" -iregex "\"".*\/\.${playlist_escaped}\.sw."\""`" != "" ) then
			printf "<file://%s/%s> is in use and will not be deleted.\n" "${playlist_dir}" "${playlist}" > /dev/stderr;
		else if( "`wc -l "\""${playlist_dir}/${playlist}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" > 2 ) then
			printf "<file://%s/%s> is the latest playlist and appears to still list files.\n\tWould your like to remove it:\n" "${playlist_dir}" "${playlist}" > /dev/stderr;
			rm -vi "${playlist_dir}/${playlist}";
		else
			rm -v "${playlist_dir}/${playlist}";
		endif
		unset playlist_escaped playlist;
	end
	unset playlist_count playlist_dir;
	goto parse_argv;
#goto playlists;


logs:
	set current_day=`date "+%d"`
	set current_month=`date "+%m"`
	set current_year=`date "+%Y"`;
	
	set current_hour=`date "+%k"`
	set current_hour=`printf "%d-(%d%%6)\n" "${current_hour}" "${current_hour}" | bc`;
	if( ${current_hour} < 10 ) \
		set current_hour="0${current_hour}";
	
	( rm -v "`find /media/podcasts/ -regextype posix-extended -iregex '.*alacast'\''s log for .*' \! -iregex '.*alacast'\''s log for ${current_year}-${current_month}-${current_day} from ${current_hour}.*'`" > /dev/tty ) >& /dev/null;
	
	goto parse_argv;
#goto logs;


