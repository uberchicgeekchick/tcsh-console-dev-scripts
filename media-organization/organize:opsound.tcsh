#!/bin/tcsh -f
cd `basename "${0}"`
if ( ! -d "./genres" ) mkdir "./genres"
foreach title ( "`find ./genres -iname '*.mp3'`" )
	set artist = "`printf '${title}' | sed 's/.*\/\(.*\)\ \-\ \(.*\)\.mp3/\1/g' `"
	set song = "`printf '${title}' | sed 's/.*\/\(.*\)\ \-\ \(.*\)\.mp3/\2/g' `"
	printf "Linking %s to %s/%s.mp3\n" "${title}" "${artist}" "${song}"
	if ( ! -e "./artists/${artist}/${song}.mp3" ) then
		if ( ! -d "./artists/${artist}" ) mkdir -p "./artists/${artist}"
		ln "${title}" "./artists/${artist}/${song}.mp3"
	endif
end
