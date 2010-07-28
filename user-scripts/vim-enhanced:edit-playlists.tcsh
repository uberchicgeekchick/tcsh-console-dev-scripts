#!/bin/tcsh -f
	set scripts_basename="vim-enhanced:edit-playlists.tcsh";
	onintr exit_script;
	if(! ${?0} ) then
		set being_sourced;
	else
		if( "`basename "\""${0}"\""`" != "${scripts_basename}" ) \
			set being_sourced;
	endif
	
	if( ${?being_sourced} ) \
		goto exit_script;
	
	set documents=( \
		"/art/www/uberChicks.Net/phone-sex-operator/characters/Lexi.asc" \
	);
	
	set primary_playlists=( \
		"/media/library/playlists/m3u/erotica.m3u" \
		"/media/library/playlists/m3u/lifestyle.m3u" \
	);
	
	set latest_playlist="/media/podcasts/playlists/m3u/`/bin/ls -tr --width 1 /media/podcasts/playlists/m3u/ | tail -1`";
	
	set scripts=( \
		"/media/clean-up.tcsh" \
	);
	
	set secondary_playlists=( \
		"/media/library/playlists/m3u/science.m3u" \
		"/media/library/playlists/m3u/technology.m3u" \
		"/media/library/playlists/m3u/culture.m3u" \
		"/media/library/playlists/m3u/podiobooks.m3u" \
		"/media/library/playlists/m3u/slashdot.m3u" \
	);
	
	set final_playlists=( \
		"/media/library/playlists/m3u/vodcasts.m3u" \
	);

	if( ${#argv} == 0 ) then
		set argv=("--edit");
	else if( ${#argv} > 1 ) then
		printf "Usage: %s --edit|--display\n";
		goto exit_script;
	endif
	
	switch( "$argv[1]" )
		case "--edit":
			goto edit_playlists;
			breaksw;
		
		case "--display":
		default:
			goto display_playlists;
			breaksw;
	endsw
	

edit_playlists:
	vim-enhanced -p \
		${documents} \
		${primary_playlists} \
		${scripts} \
		${secondary_playlists} \
		"${latest_playlist}" \
		${final_playlists} \
		'+tablast' \
	;
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
	if( ${?being_sourced} ) then
		printf "**errno:** you cannot source this script.\n";
		@ errno=-1;
		unset being_sourced;
	endif
	
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

