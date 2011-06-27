#!/bin/tcsh -f
foreach mp3 ("`find "\""$cwd"\"" -regextype posix-extended -iregex "\"".*\.mp3"\""`")
	
	set artist="`printf "\""%s"\"" "\""${mp3}"\"" | sed -r 's/.*\/([^/]+)\/\[?[0-9.\-]{4,10}\]?.*\.mp3/\1/g' | sed -r 's/ \- Discography//'`";
	if( "${artist}" == "${mp3}" || "${artist}" == "" ) \
		set artist="";
	
	set year="`printf "\""%s"\"" "\""${mp3}"\"" | sed -r 's/.*\/\[?([0-9.\-]{4,10})\]?.*/\1/'`";
	if( "${year}" == "0" || "${year}" == "${mp3}" ) \
		set year="";
	
	set album="`printf "\""%s"\"" "\""${mp3}"\"" | sed -r 's/.*\/\[?[0-9.\-]{4,10}\]? [-]? ?([^/]+)\/.*/\1/'`";
	if( "${year}" == "${mp3}" || "${year}" == "" ) \
		set year="";
	
	set track="`printf "\""%s"\"" "\""${mp3}"\"" | sed -r 's/.*\[?[0-9.\-]{4,10}\]? (- )?[^/]*\/([0-9]+)(\. | - |-)?.*"\$"/\2/'`";
	if( "${year}" == "0" || "${year}" == "${mp3}" ) \
		set year="";
	
	set song="`printf "\""%s"\"" "\""${mp3}"\"" | sed -r 's/.*\/\[?[0-9.\-]{4,10}\]? [^/]*\/[0-9]+(\. | - |-|_|:)?[ \-]*(.+)\.mp3"\$"/\2/' | sed -r 's/[_.]/ /g' | sed -r 's/([^ .(]+)/\u\1/g' | sed -r 's/([a-z])([A-Z])/\1 \2/g' | sed -r 's/^[ ]*//'`";
	if( "${song}" == "${mp3}" || "${song}" == "" ) \
		set song="";
	
	id3v2 --delete-all "${mp3}"; id3tag --artist="${artist}" --year="${year}" --album="${album}" --track="${track}" --song="${song}" --genre="" "${mp3}";

end

