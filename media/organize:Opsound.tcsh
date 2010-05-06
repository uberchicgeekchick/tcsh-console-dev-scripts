#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script cannot be sourced.\n";
	set status=-1;
	exit ${status};
endif

set music_path = "/media/music";
set music_library = "`basename '${0}' | sed -r 's/.*organize:(.*)\.tcsh"\$"/\1/g'`";
set podcasts_download_path = "/media/podcasts";

if( ! -d "${music_path}/${music_library}" ) then
	printf "The music library's path is not a valid directory. so I'm unable to continue.\nI attempted to organize music using the following path:\n\t%s/%s\n" "${music_path}" "${music_library}";
	exit -1;
endif

cd "${music_path}/${music_library}";
if(! -d "Genres" ) \
	mkdir "Genres";
if(! -d "Genres" ) \
	mkdir "Artists";

# Archiving all new sons, top tracks, or podcasts:
( find -L "${podcasts_download_path}" -type d -name "${music_library}*" >! "${podcasts_download_path}/.New ${music_library} Songs.lst" ) >& /dev/null;
foreach genre ( "`cat '${podcasts_download_path}/.New ${music_library} Songs.lst'`" )
	set genre = "`printf '${genre}' | sed -r 's/.*\/${music_library}[\:]?\ genre\ (.*).*/\1/g'`";
	printf "Moving %s's new %s songs\n" "${music_library}" "${genre}";
	if( ! -d "Genres/${genre}" ) \
		mkdir -p "Genres/${genre}";
	mv ${podcasts_download_path}/${music_library}*\ genre\ "${genre}"/* "Genres/${genre}/";
	rmdir ${podcasts_download_path}/${music_library}*\ genre\ "${genre}"/;
end

rm "${podcasts_download_path}/.New ${music_library} Songs.lst";
if( "`find -L Genres/ -regextype posix-extended -iregex '.*\.(mp3|m4a)"\$"'`" != "" ) \
	oggconvert --transcode Genres/;

foreach title ( "`find -L Genres -iregex '.*, released on.*'`" )
	set pubdate="`printf "\""${title}"\"" | sed -r 's/Genres\/([^\/]+)\/(.*)\ \-\ (.*)(, released on[^\.]*)\.([^\.]+)"\$"/\4/g'`";
	if( "${pubdate}" == "" || "${pubdate}" == "${title}" ) \
		continue;
	set genre = "`printf "\""${title}"\"" | sed -r 's/Genres\/([^\/]+)\/(.*)\ \-\ (.*)(, released on[^\.]*)\.([^\.]+)"\$"/\1/g'`";
	set song = "`printf "\""${title}"\"" | sed -r 's/Genres\/([^\/]+)\/(.*)\ \-\ (.*)(, released on[^\.]*)\.([^\.]+)"\$"/\3/g'`";
	set artist = "`printf "\""${title}"\"" | sed -r 's/Genres\/([^\/]+)\/(.*)\ \-\ (.*)(, released on[^\.]*)\.([^\.]+)"\$"/\2/g'`";
	set extension = "`printf "\""${title}"\"" | sed -r 's/.*\.([^\.]+)/\1/g'`";
	mv "${title}" "Genres/${genre}/${artist} - ${song}.${extension}";
end

foreach title ( "`find -L Genres -type f`" )
	set song = "`printf "\""${title}"\"" | sed -r 's/.*\/(.*)\ \-\ (.*)\.([^\.]+)"\$"/\2/g'`";
	set artist = "`printf "\""${title}"\"" | sed -r 's/.*\/(.*)\ \-\ (.*)\.([^\.]+)"\$"/\1/g'`";
	set extension = "`printf "\""${title}"\"" | sed -r 's/.*\.([^\.]+)"\$"/\1/g'`";
	
	if( -e "Artists/${artist}/${song}.${extension}" ) \
		continue;
	
	printf "Linking Artists/%s/%s.%s to %s\n" "${artist}" "${song}" "${extension}" "${title}";
	if( ! -d "Artists/${artist}" ) mkdir -p "Artists/${artist}";
	ln "${title}" "Artists/${artist}/${song}.${extension}";
	if( ! -e "Artists/${artist}/${song}.${extension}" ) \
		printf "\tERROR: I was unable to link %s to Artists/%s/%s.${extension}\n" "${title}" "${artist}" "${song}";
end
