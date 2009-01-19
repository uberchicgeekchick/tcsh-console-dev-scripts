#!/bin/tcsh -f
cd "`dirname '${0}'`"
set music_library = "`basename ${cwd}`"
set podcasts_download_path = "/media/podcasts"

# Some basic directory structure checks:
set artists_path = ""
if ( -d "./artists" ) set artists_path = "./artists"
else if ( -d "./Artists" ) set artists_path = "./Artists"
else
	printf "I cannot find the path where artists songs are located in the current directory."
	exit -1
endif

set genres_path = ""
if ( -d "./genres" ) set genres_path = "./genres"
else if ( -d "./Genres" ) set genres_path = "./Genres"
else
	printf "I cannot find the path where genres are stored in the current directory."
	exit -1
endif

# Archiving all new sons, top tracks, or podcasts:
foreach genre ( "`find '${podcasts_download_path}' -type d -name '${music_library}*'`" )
	set genre = "`printf '${genre}' | sed 's/.*\/${music_library}:\ genre\ \(.*\).*/\1/g'`"
	printf "Moving %s's new %s songs\n" "${music_library}" "${genre}"
	if ( ! -d "${genres_path}/${genre}" ) mkdir -p "${genres_path}/${genre}"
	mv ${podcasts_download_path}/${music_library}:\ genre\ "${genre}"/* "${genres_path}/${genre}/"
	rmdir ${podcasts_download_path}/${music_library}:\ genre\ "${genre}"/
end

foreach title ( "`find ${genres_path} -iname '*.mp3'`" )
	set song = "`printf "\""${title}"\"" | sed 's/.*\/\(.*\)\ \-\ \(.*\)\.mp3/\2/g'`"
	set artist = "`printf "\""${title}"\"" | sed 's/.*\/\(.*\)\ \-\ \(.*\)\.mp3/\1/g'`"
	
	if ( -e "${artists_path}/${artist}/${song}.mp3" ) continue
	
	printf "Linking %s to %s/%s/%s.mp3\n" "${title}" "${artists_path}" "${artist}" "${song}"
	if ( ! -d "${artists_path}/${artist}" ) mkdir -p "${artists_path}/${artist}"
	ln "${title}" "${artists_path}/${artist}/${song}.mp3"
	if ( ! -e "${artists_path}/${artist}/${song}.mp3" ) printf "\tERROR: I was unable to link %s to ${artists_path}/%s/%s.mp3\n" "${title}" "${artist}" "${song}"
end
