#!/bin/tcsh -f
	if(! ${?0} ) then
		printf "**errno:** you cannot source this script.\n";
		set status=-1;
		exit -1;
	endif

	set playlists=( \
		"/media/library/playlists/m3u/eee.m3u" \
		"/media/library/playlists/m3u/podcasts.m3u" \
		"/media/library/playlists/m3u/podiobooks.m3u" \
		"/media/library/playlists/m3u/lifestyle.m3u" \
	);
	
	set latest_playlist="/media/podcasts/playlists/m3u/`/bin/ls -tr --width 1 /media/podcasts/playlists/m3u/ | tail -1`";
	
	set scripts=( \
		"/media/clean-up.tcsh" \
	);

set edit_playlist="echo";
if( ${#argv} > 0 ) then
	switch( "$argv[1]" )
		case "--auto-edit":
		case "--edit":
			set edit_playlist="vim-enhanced -p";
			${edit_playlist} \
				${playlists} \
				${scripts} \
				"${latest_playlist}" \
			;
			exit 0;
			breaksw;
		
		default:
			breaksw;
	endsw
endif
	
	foreach playlist( ${playlists} )
		printf "%s\n" "${playlist}";
	end
		
	printf "%s\n" "${latest_playlist}";
	
	foreach script( ${scripts} )
		printf "%s\n" "${script}";
	end


