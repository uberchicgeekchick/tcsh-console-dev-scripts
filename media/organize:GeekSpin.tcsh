#!/bin/tcsh -f
set podcasts_dir = "/media/podcasts";
set cc_artist = "GeekSpin";
set media_dir = "/media/music/nerdy-or-geeky";

if( -d "${podcasts_dir}/${cc_artist}, The" ) then
	if( `ls "${podcasts_dir}/${cc_artist}, The"` != "" ) \
		mv "${podcasts_dir}/${cc_artist}, The"/* "${media_dir}/${cc_artist}";
	rmdir "${podcasts_dir}/${cc_artist}, The";
endif

if( "`find -L -regextype posix-extended -iregex '.*\.(mp3|m4a)"\$"'`" != "" ) \
	oggconvert --transcode "${media_dir}/${cc_artist}";

foreach title ("`find -L '${media_dir}/${cc_artist}' -regextype posix-extended -iregex '.*, released on[^\.]*\.[^\.]+'`" )
	set song = "`printf "\""${title}"\"" | sed -r 's/(.*)(, released on[^\.]*)\.([^\.]+"\$")/\1\.\3/g'`";
	mv "${title}" "${song}";
end

