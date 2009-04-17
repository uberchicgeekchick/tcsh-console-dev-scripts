#!/bin/tcsh -f
set music_path = "/media/library/music"
set music_library = "`basename '${0}' | sed 's/.*organize:\(.*\)\.tcsh/\1/g'`"
set podcasts_download_path = "/media/podcasts"

if ( ! -d "${music_path}/${music_library}" ) then
	printf "The music library's path is not a valid directory. so I'm unable to continue.\nI attempted to organize music using the following path:\n\t%s/%s\n" "${music_path}" "${music_library}"
	exit -1
endif

cd "${music_path}/${music_library}"

# Archiving all new sons, top tracks, or podcasts:
foreach genre ( "`find '${podcasts_download_path}' -type d -name '${music_library}*'`" )
	set genre = "`printf '${genre}' | sed 's/.*\/${music_library}\ genre\ \(.*\).*/\1/g'`"
	printf "Moving %s's new %s songs\n" "${music_library}" "${genre}"
	if ( ! -d "Genres/${genre}" ) mkdir -p "Genres/${genre}"
	mv ${podcasts_download_path}/${music_library}\ genre\ "${genre}"/* "Genres/${genre}/"
	rmdir ${podcasts_download_path}/${music_library}\ genre\ "${genre}"/
end

foreach title ( "`find Genres -iname '*.mp3'`" )
	set song = "`printf "\""${title}"\"" | sed 's/.*\/\(.*\)\ \-\ \(.*\)\.mp3/\2/g'`"
	set artist = "`printf "\""${title}"\"" | sed 's/.*\/\(.*\)\ \-\ \(.*\)\.mp3/\1/g'`"
	
	if ( -e "Artists/${artist}/${song}.mp3" ) continue
	
	printf "Linking %s to %s/%s/%s.mp3\n" "${title}" "Artists" "${artist}" "${song}"
	if ( ! -d "Artists/${artist}" ) mkdir -p "Artists/${artist}"
	ln "${title}" "Artists/${artist}/${song}.mp3"
	if ( ! -e "Artists/${artist}/${song}.mp3" ) printf "\tERROR: I was unable to link %s to Artists/%s/%s.mp3\n" "${title}" "${artist}" "${song}"
end
