#!/bin/tcsh -f
set music_library = "`basename ${cwd}`"
set podcasts_download_path = "/media/podcasts"

# Archiving all new sons, top tracks, or podcasts:
foreach genre ( "`find '${podcasts_download_path}' -type d -name '${music_library}*'`" )
	set genre = "`printf '${genre}' | sed 's/.*\/${music_library}:\ genre\ \(.*\).*/\1/g'`"
	printf "Moving %s's new %s songs\n" "${music_library}" "${genre}"
	if ( ! -d "Genres/${genre}" ) mkdir -p "Genres/${genre}"
	mv ${podcasts_download_path}/${music_library}:\ genre\ "${genre}"/* "Genres/${genre}/"
	rmdir ${podcasts_download_path}/${music_library}:\ genre\ "${genre}"/
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
