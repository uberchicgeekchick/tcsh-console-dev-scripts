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
	set slashdot=( \
	"\n" \
"/media/podcasts/Slashdot/GCC Moving To Use C++ Instead of C, released on: Tue, 01 Jun 2010 08:58:00 GMT.mp3" \
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
"/media/podcasts/NASACast Video/NASA TV's This Week @NASA, May 28, released on: Fri, 28 May 2010 16:00:00 GMT.mp4" \
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
	if( "`/bin/ls -A /media/podcasts/playlists/m3u/`" != "" ) \
		rm -v "/media/podcasts/playlists/m3u/"*;
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


