#!/bin/tcsh -f
cd "`dirname '${0}'`"
set music_library = "`basename ${cwd}`"
set podcasts_download_path = "/media/podcasts"

# Some basic directory structure checks:
if ( ! -d "./Genres" ) mkdir "./Genres"

# Archiving all new sons, top tracks, or podcasts:
foreach genre ( "`find '${podcasts_download_path}' -type d -name '${music_library}*'`" )
	set genre = "`printf '${genre}' | sed 's/.*\/GarageBand\.com\ \(.*\)\ top\ tracks.*/\1/g'`"
	printf "Moving %s's new %s songs\n" "${music_library}" "${genre}"
	if ( ! -d "Genres/${genre}" ) mkdir -p "./Genres/${genre}"
	mv ${podcasts_download_path}/${music_library}\ "${genre}"\ top\ tracks/* "./Genres/${genre}/"
	rmdir ${podcasts_download_path}/${music_library}\ "${genre}"\ top\ tracks/
end

foreach title ( "`find ./Genres -iname '*.mp3'`" )
	set song = "`printf '${title}' | sed 's/.*\/\(.*\)\ by\ \(.*\)\.mp3/\1/g' `"
	set artist = "`printf '${title}' | sed 's/.*\/\(.*\)\ by\ \(.*\)\.mp3/\2/g' `"
	if ( -e "./Artists/${artist}/${song}.mp3" ) continue

	printf "Linking %s to %s/%s.mp3\n" "${title}" "${artist}" "${song}"
	if ( ! -d "./Artists/${artist}" ) mkdir -p "./Artists/${artist}"
	ln "${title}" "./Artists/${artist}/${song}.mp3"
end
