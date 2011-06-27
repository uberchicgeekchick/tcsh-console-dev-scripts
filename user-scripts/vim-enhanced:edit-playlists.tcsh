#!/bin/tcsh -f
init:
	set scripts_basename="vim-enhanced:edit-playlists.tcsh";
	@ errno=0;
	onintr exit_script;
	if(! ${?0} ) then
		@ errno=-1;
		goto error_handler;
	else
		if( "`basename "\""${0}"\""`" != "${scripts_basename}" ) then
			@ errno=-1;
			goto error_handler;
		endif
	endif
	
	set playlist_one=( \
		"/media/library/playlists/tox/lifestyle.tox" \
		"/media/library/playlists/tox/podiobooks/podiobooks.tox" \
		"/media/library/playlists/tox/vodcasts.tox" \
		"/media/library/playlists/tox/television/television.tox" \
		"/media/library/playlists/tox/movies/movies.tox" \
		"/media/library/playlists/tox/movies/lesbian.tox" \
		"/media/library/playlists/tox/movies/trans.tox" \
	);
	
	set scripts=( \
		"/media/clean-up.tcsh" \
	);
	
	set latest_playlist="/media/podcasts/playlists/tox/`/bin/ls -tr --width 1 /media/podcasts/playlists/tox/ | tail -1`";
	
	set playlists_two=( \
		"/media/library/playlists/tox/science.tox" \
		"/media/library/playlists/tox/technology.tox" \
		"/media/library/playlists/tox/culture.tox" \
		"${HOME}/.xine/xine-ui_old_playlist.tox" \
	);
	#set third_playlists=( \
	#);
	
	#goto validate_playlists;
#goo init;

parse_argv:
	@ argc=${#argv};
	if( $argc == 0 ) then
		set argv=("--edit");
	else if( $argc > 1 ) then
		printf "to many arguments.\n";
		goto usage;
	endif
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		switch( "$argv[$arg]" )
			case "--help":
				goto usage;
			
			case "--gui":
				set use_gvim;
			case "--edit":
				goto edit_playlists;
			
			case "--display":
				goto display_playlists;
			
			default:
				printf "default switch handler.\n";
				goto usage;
		endsw
	end
	goto edit_playlists;
#goto init;

usage:
	@ errno=0;
	goto error_handler;
#goto usage;


error_handler:
	if(! ${?errno} ) \
		goto exit_script;
	switch($errno)
		case 0:
			printf "Usage: %s --edit|--display";
			breaksw;
		case -1:
			printf "%s cannot be sourced." "${scripts_basenam}";
			breaksw;
	endsw
	printf "\n";
	goto exit_script;
#goto error_handler;


edit_playlists:
	if( ${?use_gvim} ) then
		set vim_command="gvim";
	else if( ${?server} ) then
		set vim-command="vim-server";
	else
		set vim_command="vim-enhanced";
	endif
	${vim_command} -n -p \
		${playlist_one} \
		${scripts} \
		${playlists_two} \
		\ #${third_playlists} \
		"${latest_playlist}" \
		'+tabnext 6' \
	;
	unset vim_command;
	goto exit_script;
#goto edit_playlists;


display_playlists:
	@ i=1;
	foreach playlist( ${playlist_one} )
		@ i++;
		if( -e "${playlist}" ) \
			printf "%s\n" "$playlist";
		unset playlist;
	end
	
	@ i=1;
	foreach script( ${scripts} )
		@ i++;
		if( -e "${script}" ) \
			printf "%s\n" "$script";
		unset script;
	end
	
	@ i=1;
	foreach playlist( ${playlists_two} )
		@ i++;
		if( -e "${playlist}" ) \
			printf "%s\n" "$playlist";
		unset playlist;
	end
	
	#@ i=1;
	#foreach playlist( ${third_playlists} )
	#	@ i++;
	#	if( -e "${playlist}" ) \
	#		printf "%s\n" "$playlist";
	#unset playlist;
	#end
	
	if( "${latest_playlist}" != "" ) \
		printf "%s\n" "$latest_playlist";
	
	goto exit_script;
	goto parse_argv;
#goto validate_playlists;



exit_script:
	if( ${?playlist_one} )\
		unset playlist_one;
	if( ${?scripts} )\
		unset scripts;
	if( ${?playlists_two} )\
		unset playlists_two;
	#if( ${?third_playlists} )\
	#	unset third_playlists;
	
	if( ${?latest_playlist} )\
		unset latest_playlist;
	
	if( ${?document} ) \
		unset document;
	if( ${?playlist} ) \
		unset playlist;
	if( ${?script} ) \
		unset script;
	
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $errno;
#goto exit_script;

