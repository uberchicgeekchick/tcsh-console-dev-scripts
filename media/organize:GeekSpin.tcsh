#!/bin/tcsh -f
set podcasts_dir = "/media/podcasts";
set cc_artist = "/media/podcasts/GeekSpin";
set media_dir = "/media/library/music/nerdy & geeky";
if( -d "${podcasts_dir}/${cc_artist}, The" ) then
	if ( `ls "${podcasts_dir}/${cc_artist}, The"` != "" ) then
		mv "${podcasts_dir}/${cc_artist}, The"/* "${media_dir}/${cc_artist}";
		rmdir "${podcasts_dir}/${cc_artist}, The";
	endif
endif
