#!/bin/tcsh -f
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
	
	set documents=( \
		"/art/www/uberChicks.Net/phone-sex-operator/characters/Lexi.asc" \
	);
	
	set primary_playlists=( \
		"/media/library/playlists/tox/erotica.tox" \
		"/media/library/playlists/tox/lifestyle.tox" \
	);
	
	set latest_playlist="/media/podcasts/playlists/tox/`/bin/ls -tr --width 1 /media/podcasts/playlists/tox/ | tail -1`";
	
	set scripts=( \
		"/media/clean-up.tcsh" \
	);
	
	set secondary_playlists=( \
		"/media/library/playlists/tox/science.tox" \
		"/media/library/playlists/tox/technology.tox" \
		"/media/library/playlists/tox/culture.tox" \
		"/media/library/playlists/tox/podiobooks.tox" \
		"/media/library/playlists/tox/slashdot.tox" \
	);
	
	set final_playlists=( \
		"/media/library/playlists/tox/vodcasts.tox" \
	);
	
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
		${documents} \
		${primary_playlists} \
		${scripts} \
		${secondary_playlists} \
		"${latest_playlist}" \
		${final_playlists} \
		'+tablast' \
	;
	unset vim_command;
	goto exit_script;
#goto edit_playlists;


display_playlists:
	foreach document( ${documents} )
		if( -e "${document}" ) \
			printf "%s\n" "${document}";
		unset document;
	end
	
	foreach playlist( ${primary_playlists} )
		if( -e "${playlist}" ) \
			printf "%s\n" "${playlist}";
		unset playlist;
	end
	
	foreach script( ${scripts} )
		if( -e "${script}" ) \
			printf "%s\n" "${script}";
		unset script;
	end
	
	foreach playlist( ${secondary_playlists} )
		if( -e "${playlist}" ) \
			printf "%s\n" "${playlist}";
		unset playlist;
	end
	
	if( "${latest_playlist}" != "" ) \
		printf "%s\n" "${latest_playlist}";
	
	foreach playlist( ${final_playlists} )
		if( -e "${playlist}" ) \
			printf "%s\n" "${playlist}";
		unset playlist;
	end
	
	goto exit_script;
#goto display_playlists;



exit_script:
	if( ${?latest_playlist} )\
		unset latest_playlist;
	if( ${?primary_playlists} )\
		unset primary_playlists;
	if( ${?scripts} )\
		unset scripts;
	if( ${?secondary_playlists} )\
		unset secondary_playlists;
	if( ${?final_playlists} )\
		unset final_playlists;
	
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

