#!/bin/tcsh -f
cd `basename "${0}"`
if ( ! -d "./Genres" ) mkdir "./Genres"
foreach title ( "`find ./Genres -iname '*.mp3'`" )
	set song = "`printf '${title}' | sed 's/.*\/\(.*\)\ by\ \(.*\)\.mp3/\1/g' `"
	set artist = "`printf '${title}' | sed 's/.*\/\(.*\)\ by\ \(.*\)\.mp3/\2/g' `"
	printf "Linking %s to %s/%s\n" "${title}" "${artist}" "${song}"
	if ( ! -e "./Artists/${artist}/${song}.mp3" ) then
		if ( ! -d "./Artists/${artist}" ) mkdir -p "./Artists/${artist}"
		ln "${title}" "./Artists/${artist}/${song}.mp3"
	endif
end
