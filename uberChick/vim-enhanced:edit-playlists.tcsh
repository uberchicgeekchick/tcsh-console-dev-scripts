#!/bin/tcsh -f
	if(! ${?0} ) then
		printf "**errno:** you cannot source this script.\n";
		set status=-1;
		exit -1;
	endif
	
	set documents=( \
		"/art/www/uberChicks.Net/phone-sex-operator/characters/Lexi.asc" \
	);
	
	set primary_playlists=( \
		"/media/library/playlists/m3u/eee.m3u" \
		"/media/library/playlists/m3u/podcasts.m3u" \
		"/media/library/playlists/m3u/podiobooks.m3u" \
		"/media/library/playlists/m3u/lifestyle.m3u" \
	);
	
	set latest_playlist="`/bin/ls -tr --width 1 /media/podcasts/playlists/m3u/ | tail -1`";
	if( "${latest_playlist}" != "" ) then
		set latest_playlist="/media/podcasts/playlists/m3u/${latest_playlist}";
	else
		set latest_playlist="";
	endif
	
	set scripts=( \
		"/media/clean-up.tcsh" \
	);
	
	set secondary_playlists=( \
		"/media/library/playlists/m3u/erotica.m3u" \
		"/media/library/playlists/m3u/vodcasts.m3u" \
		"/media/library/playlists/m3u/slashdot.m3u" \
	);

if( ${#argv} > 0 ) then
	switch( "$argv[1]" )
		case "--auto-edit":
		case "--edit":
			goto edit_playlists;
			breaksw;
		
		case "--display":
		default:
			goto display_playlists;
			breaksw;
	endsw
endif

edit_playlists:
	vim-enhanced -p \
		${documents} \
		${primary_playlists} \
		${scripts} \
		"${latest_playlist}" \
		${secondary_playlists} \
	;
	goto exit_script;
#goto edit_playlists;


display_playlists:
	foreach document( ${documents} )
		printf "%s\n" "${document}";
		unset document;
	end
	
	foreach playlist( ${primary_playlists} )
		printf "%s\n" "${playlist}";
		unset playlist;
	end
	
	if( "${latest_playlist}" != "" ) \
		printf "%s\n" "${latest_playlist}";
	
	foreach script( ${scripts} )
		printf "%s\n" "${script}";
		unset script;
	end
	
	foreach playlist( ${secondary_playlists} )
		printf "%s\n" "${playlist}";
		unset playlist;
	end
	
	goto exit_script;
#goto display_playlists;



exit_script:
	unset primary_playlists scriptslatest_playlist secondary_playlists;
	set status=0;
	exit 0;
#goto exit_script;

