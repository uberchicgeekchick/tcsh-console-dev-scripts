#!/bin/tcsh -f
if(!(${?1})) then
	printf "Usage: %s [search term]" $0;
	exit -1;
endif

cd "`dirname '${0}'`";

set silent="";
if( "${1}" == "--silent" || "${1}" == "--quiet" ) then
	set silent=">& /dev/null";
	shift;
endif

set mp3_player_folder="`grep 'mp3_player_folder' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`";
set refetch_script="${mp3_player_folder}/gPodder:Refetch:`echo ${1} | sed 's/\([\-\=]\+\)/\:/g'`.tcsh";

./gPodder:Search:index.rss.tcsh --verbose "${1}" >! "${refetch_script}.tmp"
ex '+1,$s/[\r\n]\+//g' '+1,$s/\(<\/item>\)/\1\n/g' '+1,$s/.*<title>\([^>]\+\)<\/title>.*<title>\([^<]\+\)<\/title>.*<url>\([^<]\+\)<\/url>.*/if ( ! -d "\1" ) mkdir "\1"\rwget -c -O "\1\/\2" "\3"/g' '+2,$s/^\(wget\ \-c\ \-O\ \)\"\([^\"]\+\)\"\ \"\([^\"]\+\)\.\([^\.\"]\+\)\"$/\1\ \"\2\.\4\"\ \"\3\.\4\"/' '+wq' "${refetch_script}.tmp" >& /dev/null;
cd "${mp3_player_folder}";
if( `wc -l "${refetch_script}.tmp" | sed 's/^\([0-9]\+\)\ .*/\1/g'` > 0 ) then
	printf '#\!/bin/tcsh -f' >! "${refetch_script}";
	ex "+1r${refetch_script}.tmp" "+wq" "${refetch_script}" >& /dev/null;
	chmod +x "${refetch_script}";
	"${refetch_script}" ${silent};
	rm "${refetch_script}";
endif
rm "${refetch_script}.tmp";

