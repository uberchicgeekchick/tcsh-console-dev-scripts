#!/bin/tcsh -f
set oggconvert="/projects/cli/console.pallet/media/oggconvert";
if(! -e "${oggconvert}" ) then
	printf "Unable to find ogg conversion script:\n\t%s\n" "${oggconvert}";
	exit -1;
endif

set video_path="/media/podcasts/TEDTalks (Video)";
if(! -d "${video_path}" ) \
	mkdir -p "${video_path}";
set ogg_path="/media/podcasts/TEDTalks (audio)";
if(! -d "${ogg_path}" ) \
	mkdir -p "${ogg_path}";

cd "${video_path}";
foreach video("`/usr/bin/find . -regextype posix-extended -iregex '(mp4|m4v)' -type f`")
	set video="`echo "\""${video}"\"" | sed 's/\(\!\)/\\\1/g'`";
	${oggconvert} --any-file "${video}";
	#set tedtalk_video_with_extension="`echo '${video}' | sed 's/\(.*\)\(, released on[^\.]\+\)\?\.\([^\.]\+$\)/\1\.\3/g'`";
	set new_ogg="`echo "\""${video}"\"" | sed -r 's/(.*)(, released on[^\.]+)?\.([^\.]+)"\$"/\1\2\.ogg/g'`";
	set tedtalk="`echo "\""${video}"\"" | sed -r 's/(.*)(, released on[^\.]+)?\.([^\.]+)"\$"/\1/g'`";
	if( "`/usr/bin/find "\""${ogg_path}"\"" -name "\""${tedtalk}*.ogg"\""`" != "" ) then
		printf "Skipping existing OGG Vorbis:\n\t%s\n" "${tedtalk}";
		continue;
	endif
	
	#set pubDate="`echo '${video}' | sed -r 's/(.*)(, released on[^\.]+)?\.([^\.]+)"\$"/\2/g'`";
	#set extension="`echo '${video}' | sed -r 's/(.*)(, released on[^\.]+)?\.([^\.]+)"\$"/\3/g'`";
	mv "${new_ogg}" "${ogg_path}/${tedtalk}.ogg"
end
