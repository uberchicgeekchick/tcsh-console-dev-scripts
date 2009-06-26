#!/bin/tcsh -f
set podcasts_dir = "/media/podcasts";
set cc_artist = "Beatnik Turtle";
set media_dir = "/media/library/music/nerdy & geeky/artists";
if(!(-d "${podcasts_dir}/${cc_artist}'s Song of the Day" )) exit 0;

if( `ls "${podcasts_dir}/${cc_artist}'s Song of the Day"` == "" ) exit 0;

mv "${podcasts_dir}/${cc_artist}'s Song of the Day"/* "${media_dir}/${cc_artist}";
rmdir "${podcasts_dir}/${cc_artist}'s Song of the Day";


foreach title ( "`find '${media_dir}/${cc_artist}' -iregex '.*, released on.*\.\(mp.\|ogg\|flac\)'`" )
	set song = "`printf "\""${title}"\"" | sed 's/\(.*\)\(, released on[^\.]*\)\.\(mp.\|ogg\|flac\)/\1/g'`";
	set extension = "`printf "\""${title}"\"" | sed 's/.*\.\(mp.\|ogg\|flac\)/\1/g'`";
	mv "${title}" "${song}.${extension}";
end

