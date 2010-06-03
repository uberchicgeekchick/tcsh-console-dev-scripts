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
"/media/podcasts/StarShipSofa/Aural Delights No 139 Philip K. Dick Juliette Wade, released on: Wed, 02 Jun 2010 03:11:13 GMT.mp3" \
	"\n" \
"/media/podcasts/PodCastle/PodCastle 106: Little Gods, released on: Wed, 02 Jun 2010 03:17:38 GMT.mp3" \
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
"/media/podcasts/slash./Intelligence Density and the Creative Class, released on: Sat, 29 May 2010 15:57:00 GMT.ogg" \
	"\n" \
"/media/podcasts/slash./Design Contest Highlights Video Games With a Purpose, released on: Sun, 30 May 2010 16:36:00 GMT.ogg" \
	"\n" \
"/media/podcasts/slash./Physics Platformer Gish Goes Open Source, released on: Sun, 30 May 2010 15:15:00 GMT.ogg" \
	"\n" \
"/media/podcasts/slash./Smokescreen, a JavaScript-Based Flash Player, released on: Tue, 01 Jun 2010 18:17:00 GMT.ogg" \
	"\n" \
"/media/podcasts/slash./Tetris Clones Pulled From Android Market, released on: Fri, 28 May 2010 10:48:00 GMT.ogg" \
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
"/media/podcasts/TEDTalks (video)/Brian Skerry reveals ocean's glory -- and horror - Brian Skerry (2010), released on: Wed, 02 Jun 2010 02:36:00 GMT.mp4" \
	"\n" \
"/media/podcasts/APM: Future Tense/Where are books going?, released on: Wed, 02 Jun 2010 15:27:28 GMT.mp3" \
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
			unset podcast;
		end
		unset to_be_deleted;
	endif
	
	set dirs_to_delete=( \
	"\n" \
	"\n" \
	);
	
	if( ${?dirs_to_delete} ) then
		foreach podcast( "`printf "\""${dirs_to_delete}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if( "${podcast}" != "" ) then
				set podcast_dir="`dirname "\""${podcast}"\""`";
				if( "${podcast_dir}" != "/media/podcasts" && -d "${podcast_dir}" ) \
					rm -rv \
						"${podcast_dir}";
			endif
			unset podcast_dir podcast;
		end
		unset dirs_to_delete;
	endif
	
	if( -d "/media/podcasts/Slashdot" ) \
		rm -rv "/media/podcasts/Slashdot";
	
	goto parse_argv;
#goto delete;

playlists:
	set playlist_dir="/media/podcasts/playlists/m3u";
	foreach playlist("`/bin/ls --width=1 -t "\""${playlist_dir}"\""`")
		set playlist_escaped="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/([.])/\\\1/g'`";
		if(! ${?playlist_count} ) then
			@ playlist_count=1;
		else
			@ playlist_count++;
			if( "`find "\""${playlist_dir}"\"" -iregex "\"".*\/\.${playlist_escaped}\.sw."\""`" != "" ) then
				printf "<file://%s/%s> is in use and will not be deleted.\n" "${playlist_dir}" "${playlist}" > /dev/stderr;
			else
				rm -v "${playlist_dir}/${playlist}";
			endif
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


