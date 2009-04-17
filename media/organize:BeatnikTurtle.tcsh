#!/bin/tcsh -f
set podcasts_dir = "/media/podcasts";
set cc_artist = "Beatnik Turtle's Song of the Day";
set media_dir = "/media/library/music/CC Artists";
if( -d "${podcasts_dir}/${cc_artist}" ) then
	if ( `ls "${podcasts_dir}/${cc_artist}"` != "" ) then
		mv "${podcasts_dir}/${cc_artist}"/* "${media_dir}/${cc_artist}"
		rmdir "${podcasts_dir}/${cc_artist}"
	endif
endif
