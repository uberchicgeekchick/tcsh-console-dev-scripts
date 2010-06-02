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
		switch( "$argv[$arg]" )
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
"/media/podcasts/Amarna: The Adventures of Sophie Roberts/Amarna: The Adventures of Sophie Roberts Episode 11, released on: Tue, 01 Jun 2010 22:22:57 GMT.mp3"\
	"\n" \
"/media/podcasts/Archers, The/Archers: 100601 Tuesday, released on: Tue, 01 Jun 2010 18:20:00 GMT.mp3"\
	"\n" \
"/media/podcasts/Cossmass Infinities/Cossmass Infinities 06 - How You Make The Straight, released on: Tue, 01 Jun 2010 21:15:34 GMT.mp3"\
	"\n" \
"/media/podcasts/Drabblecast B-Sides/Bsides 10- Growing Humans by Neil Buchanan, released on: Tue, 01 Jun 2010 18:30:07 GMT.m4a"\
	"\n" \
"/media/podcasts/LightningBolt Theater of the Mind/How Much Do 1 Love Thee, Let Me Count the Ways, released on: Tue, 01 Jun 2010 15:28:00 GMT.mp3"\
	"\n" \
	);
	
	if( ${?podiobooks} ) then
		if(! -d "/media/podiobooks/Latest" ) \
			mkdir -p  "/media/podiobooks/Latest";
		foreach podiobook_episode( "`printf "\""${podiobooks}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			set podiobook="`dirname "\""${podiobook_episode}"\""`";
			set podiobook="`basename "\""${podiobook}"\""`";
			set podiobook_episode="/media/podcasts/${podiobook}";
			if( "${podiobook_episode}" != "" && -e "${podiobook_episode}" ) \
				mv -v \
					"${podiobook_episode}" \
				"/media/podiobooks/Latest";
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
		if(! -d "/media/podcasts/slash." ) \
			mkdir -p  "/media/podcasts/slash.";
		foreach podcast( "`printf "\""${slashdot}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if( "${podcast}" != "" && -e "${podcast}" ) \
				mv -v \
					"${podcast}" \
				"/media/podcasts/slash.";
			unset podcast;
		end
		unset slashdot;
	endif
	
	goto parse_argv;
#goto move;


back_up:
	set slashdot=( \
	"\n" \
	);
	
	if( ${?slashdot} ) then
		if(! -d "/art/media/resources/stories/Slashdot" ) \
			mkdir -p  "/art/media/resources/stories/Slashdot";
		foreach podcast( "`printf "\""${slashdot}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if( "${podcast}" != "" && -e "${podcast}" ) \
				mv -v \
					"${podcast}" \
				"/art/media/resources/stories/Slashdot";
			unset podcast;
		end
		unset slashdot;
	endif
	
	goto parse_argv;
#goto back_up;


delete:
	set to_be_deleted=( \
	"\n" \
"/media/podcasts/Modern Evil Podcast" \
	"\n" \
"/media/podcasts/Imagination Backroads" \
	"\n" \
	);
	
	if( ${?to_be_deleted} ) then
		foreach podcast( "`printf "\""${to_be_deleted}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			if( "${podcast}" != "" && -e "${podcast}" ) \
				rm -rv \
					"${podcast}";
			unset podcast;
		end
		unset to_be_deleted;
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


