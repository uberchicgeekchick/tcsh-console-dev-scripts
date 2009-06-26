#!/bin/tcsh -f
set podcasts_dir = "/media/podcasts";
set cc_artist = "/media/podcasts/GeekSpin";
set media_dir = "/media/library/music/nerdy & geeky";

if(!( -d "${podcasts_dir}/${cc_artist}, The" )) exit 0;

if ( `ls "${podcasts_dir}/${cc_artist}, The"` != "" ) exit 0;

mv "${podcasts_dir}/${cc_artist}, The"/* "${media_dir}/${cc_artist}";
rmdir "${podcasts_dir}/${cc_artist}, The";

foreach title ( "`find '${media_dir}/${cc_artist}' -iregex '.*, released on.*\.\(mp.\|ogg\|flac\)'`" )
	set song = "`printf "\""${title}"\"" | sed 's/\(.*\)\(, released on[^\.]*\)\.\(mp.\|ogg\|flac\)/\1/g'`";
	set extension = "`printf "\""${title}"\"" | sed 's/.*\.\(mp.\|ogg\|flac\)/\1/g'`";
	mv "${title}" "${song}.${extension}";
end

