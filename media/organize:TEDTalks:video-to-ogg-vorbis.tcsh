#!/bin/tcsh -f
set video_path="/projects/media/resources/TEDTalks (video)";
set ogg_path="/projects/media/resources/TEDTalks (audio)";
set oggconvert="/projects/cli/media/oggconvert";

cd "${video_path}";
foreach video("`find . -type f`")
	set video="`echo '${video}' | sed 's/\(\!\)/\\\1/g'`";
	${oggconvert} "${video}";
	#set tedtalk_video_with_extension="`echo '${video}' | sed 's/\(.*\)\(, released on[^\.]\+\)\?\.\([^\.]\+$\)/\1\.\3/g'`";
	set new_ogg="`echo '${video}' | sed 's/\(.*\)\(, released on[^\.]\+\)\?\.\([^\.]\+$\)/\1\2\.ogg/g'`";
	set tedtalk="`echo '${video}' | sed 's/\(.*\)\(, released on[^\.]\+\)\?\.\([^\.]\+$\)/\1/g'`";
	if( `find "${ogg_path}" -name "${tedtalk}*.ogg"` != "" ) then
		printf "Skipping existing OGG Vorbis:\n\t%s\n" "${tedtalk}";
		continue;
	endif
	
	#set pubDate="`echo '${video}' | sed 's/\(.*\)\(, released on[^\.]\+\)\?\.\([^\.]\+$\)/\1\.\3/g'`";
	#set extension="`echo '${video}' | sed 's/\(.*\)\(, released on[^\.]\+\)\?\.\([^\.]\+$\)/\3/g'`";
	mv "${new_ogg}" "${ogg_path}/${tedtalk}.ogg"
end
