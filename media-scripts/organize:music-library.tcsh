#!/bin/tcsh -f
set music_catalog = `dirname "${0}"`
set music_catalog = `basename "${music_catalog}"`
set artists_dir = ""

set genres_dir = ""
if ( -d "./genres" ) then
	set genres_dir = "./genres"
else if ( -d "./Genres" ) then
	set genres_dir = "./Genres"
else
	printf "I cannot find the genres directory.\n"
	exit -1
endif

set artists_dir = ""
if ( -d "./artists" ) then
	set artists_dir = "./artists"
else if ( -d "./Artists" ) then
	set artists_dir = "./Artists"
else
	printf "I cannot find the artists directory.\n"
	exit -1
endif

if ( ! -d "./Genres" ) mkdir "./Genres"
foreach title ( "`find ./Genres -iname '*.mp3'`" )
	set separator = "`printf '${title}' | sed 's/.*\/\(.*\)\ \(by\|\-\)\ \(.*\)\.mp3/\2/g'`"
	if ( "${separator}" == "by" ) then
		set song = "`printf '${title}' | sed 's/.*\/\(.*\)\ \(by\|\-\)\ \(.*\)\.mp3/\1/g'`"
		set artist = "`printf '${title}' | sed 's/.*\/\(.*\)\ \(by\|\-\)\ \(.*\)\.mp3/\3/g'`"
	else if ( "${separator}" == "-" ) then
		set song = "`printf '${title}' | sed 's/.*\/\(.*\)\ \(by\|\-\)\ \(.*\)\.mp3/\3/g'`"
		set artist = "`printf '${title}' | sed 's/.*\/\(.*\)\ \(by\|\-\)\ \(.*\)\.mp3/\1/g'`"
	else
		printf "I was unable to find the artist and song title for %s\n" "${title}"
		continue
	endif

	printf "Linking %s to %s/%s.mp3\n" "${title}" "${artist}" "${song}"
	if ( ! -e "./Artists/${artist}/${song}.mp3" ) then
		if ( ! -d "./Artists/${artist}" ) mkdir -p "./Artists/${artist}"
		ln "${title}" "./Artists/${artist}/${song}.mp3"
	endif
end
