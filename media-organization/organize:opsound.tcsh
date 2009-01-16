#!/bin/tcsh -f
cd "`dirname '${0}'`"
set music_library = "`basename ${cwd}`"
set podcasts_download_path = "/media/podcasts"

# Some basic directory structure checks:
if ( ! -d "./genres" ) mkdir "./genres"

# Archiving all new sons, top tracks, or podcasts:
foreach genre ( "`find '${podcasts_download_path}' -type d -name '${music_library}*'`" )
	set genre = "`printf '${genre}' | sed 's/.*\/opsound\.org\ \(.*\)\ tracks.*/\1/g'`"
	printf "Moving %s's new %s songs\n" "${music_library}" "${genre}"
	if ( ! -d "genres/${genre}" ) mkdir -p "./genres/${genre}"
	mv ${podcasts_download_path}/${music_library}\ "${genre}"\ top\ tracks/* "./genres/${genre}/"
	rmdir ${podcasts_download_path}/${music_library}\ "${genre}"\ top\ tracks/
end

foreach title ( "`find ./genres -iname '*.mp3'`" )
	set song = "`printf '${title}' | sed 's/.*\/\(.*\)\ \-\ \(.*\)\.mp3/\2/g' `"
	set artist = "`printf '${title}' | sed 's/.*\/\(.*\)\ \-\ \(.*\)\.mp3/\1/g' `"
	printf "Linking %s to artists/%s/%s.mp3\n" "${title}" "${artist}" "${song}"
	if ( ! -e "./artists/${artist}/${song}.mp3" ) then
		if ( ! -d "./artists/${artist}" ) mkdir -p "./artists/${artist}"
		ln "${title}" "./artists/${artist}/${song}.mp3"
	endif
end
