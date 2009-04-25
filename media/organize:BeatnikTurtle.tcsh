#!/bin/tcsh -f
set podcasts_dir = "/media/podcasts";
set cc_artist = "Beatnik Turtle";
set media_dir = "/media/library/music/nerdy & geeky/artists";
if( -d "${podcasts_dir}/${cc_artist}'s Song of the Day" ) then
	if ( `ls "${podcasts_dir}/${cc_artist}'s Song of the Day"` != "" ) then
		mv "${podcasts_dir}/${cc_artist}'s Song of the Day"/* "${media_dir}/${cc_artist}";
		rmdir "${podcasts_dir}/${cc_artist}'s Song of the Day";
	endif
endif
