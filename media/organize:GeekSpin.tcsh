#!/bin/tcsh -f
set podcasts_dir = "/media/podcasts";
set cc_artist = "GeekSpin";
set media_dir = "/old/media/library/music/nerdy-or-geeky";

if( -d "${podcasts_dir}/${cc_artist}, The" ) then
	if( `ls "${podcasts_dir}/${cc_artist}, The"` != "" ) then
		mv "${podcasts_dir}/${cc_artist}, The"/* "${media_dir}/${cc_artist}";
		rmdir "${podcasts_dir}/${cc_artist}, The";
	endif
endif

foreach title ( "`/usr/bin/find '${media_dir}/${cc_artist}' -iregex '.*, released on.*\.\(mp.\|ogg\|flac\)'`" )
	set song = "`printf "\""${title}"\"" | sed 's/\(.*\)\(, released on[^\.]*\)\.\(mp.\|ogg\|flac\)/\1/g'`";
	set extension = "`printf "\""${title}"\"" | sed 's/.*\.\(mp.\|ogg\|flac\)/\1/g'`";
	mv "${title}" "${song}.${extension}";
end

