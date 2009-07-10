#!/bin/tcsh -f
set podcasts_dir = "/media/podcasts";
set cc_artist = "Beatnik Turtle";
set media_dir = "/media/library/music/cc-artists";

if( -d "${podcasts_dir}/${cc_artist}'s Song of the Day" ) then
	if( `ls "${podcasts_dir}/${cc_artist}'s Song of the Day"` != "" ) then
		mv "${podcasts_dir}/${cc_artist}'s Song of the Day"/* "${media_dir}/${cc_artist}";
		rmdir "${podcasts_dir}/${cc_artist}'s Song of the Day";
	endif
endif

foreach title ( "`find '${media_dir}/${cc_artist}' -iregex '.*, released on.*\.\(mp.\|ogg\|flac\)'`" )
	set song = "`printf "\""${title}"\"" | sed 's/\(.*\)\(, released on[^\.]*\)\.\(mp.\|ogg\|flac\)/\1/g'`";
	set extension = "`printf "\""${title}"\"" | sed 's/.*\.\(mp.\|ogg\|flac\)/\1/g'`";
	mv "${title}" "${song}.${extension}";
end

