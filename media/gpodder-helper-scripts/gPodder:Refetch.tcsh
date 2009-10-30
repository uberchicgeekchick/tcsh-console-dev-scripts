#!/bin/tcsh -f
cd "`dirname '${0}'`";

set search_script="`dirname '${0}'`/gPodder:Search:index.rss.tcsh";

if(!( ${?1} && "${1}" != "" && "${1}" != "--help" )) then
	printf "%s uses %s to find what episodes to redownload.\n\tIt supports all of its options in addition to:\n\t\t--quiet\t-Which cause the wget ouptput to be surpressed.\t\n\t\n\tIn addition %s' options are:\n\t" `basename ${0}` ${search_script} ${search_script};
	${search_script} --help
	exit -1;
endif

set silent="";
if( ${?1} && ( "${1}" == "--silent" || "${1}" == "--quiet" ) ) then
	set silent=">& /dev/null";
	shift;
endif

if( ${?1} && ( "${1}" == "--verbose" || "${1}" == "--debug" ) ) then
	set debug_enabled;
	shift;
endif

set mp3_player_folder="`grep 'mp3_player_folder' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`";

cd "${mp3_player_folder}";

if( ${?GREP_OPTIONS} ) then
	set grep_options="${GREP_OPTIONS}";
	unsetenv GREP_OPTIONS;
endif

if(! ${?eol} ) setenv eol='$';

set search_attribute="`echo "\""${1}"\"" | sed 's/^\-\-\([^=]\+\)=\(.*\)${eol}/\1/'`";
set search_value="`echo "\""${1}"\"" | sed 's/^\-\-\([^=]\+\)=\(.*\)${eol}/\2/'`";


foreach podcast_match( "`${search_script} --${search_attribute}="\""${search_value}"\"" | sed 's/'\''/\\'\''/g' | sed 's/^[^\:]\+:\(.*\)${eol}/\1/g' | sed 's/\\!//'`" )
	if( ${?debug_enabled} ) echo "${search_value}";
	set podcast_match="`printf "\""${podcast_match}"\"" | sed 's/\([-\ \(\)]\)/\\\1/g' | sed 's/'\''/\\'\''/g'`";
	if( ${?debug_enabled} ) echo "${podcast_match}";
	set refetch_script="${mp3_player_folder}/gPodder:Refetch:`printf "\""${search_value}"\"" | sed 's/\([\-\=\/\*\?\.\[\]()]\+\)/\:/g'`.tcsh";
	if( ${?debug_enabled} ) echo "${refetch_script}";
	
	if( ${?debug_enabled} ) echo ${search_script} --verbose --${search_attribute}=\"${podcast_match}\" \>\! \"${refetch_script}.tmp\";
	${search_script} --verbose --${search_attribute}="${podcast_match}" >! "${refetch_script}.tmp";
	ex -E -n -X '+1,$s/[\r\n]\+//g' '+s/\(<\/item>\)/\1\n/g' '+s/#//g' '+1,$s/.*<title>\([^>]\+\)<\/title>.*<title>\([^<]\+\)<\/title>.*<url>\(.*\)\.\([^<\.]\+\)<\/url>.*<pubDate>\([^<]\+\)<\/pubDate>.*/if( -d "\1" ) then\relse\r\tmkdir "\1"\rendif\rwget -c -O "\1\/\2, released on: \5\.\4" '\''\3\.\4'\''/g' '+1,$s/\!//g' '+wq!' "${refetch_script}.tmp" > /dev/null;
	
	while ( `/usr/bin/grep --perl-regexp '("[^\/]+)\/(.*)"' "${refetch_script}.tmp"` != "" )
		ex -E -n -X '+1,$s/\("[^\/]\+\)\/\(.*"\)/\1\-\2/g' '+wq!' "${refetch_script}.tmp" >& /dev/null;
	end
	
	set podcast_dir=`head -3 "${refetch_script}.tmp" | tail -1 | sed 's/.*mkdir "\([^"]\+\)"/\1/' | sed 's/\([()]\)/\\\1/g' | sed 's/'\''/\\'\''/g'`;
	ex -E -n -X '+4,$s/\('"${podcast_dir}"'\)\-/\1\//g' '+wq!' "${refetch_script}.tmp";
	
	if( `wc -l "${refetch_script}.tmp" | sed 's/^\([0-9]\+\)\ .*/\1/g'` > 0 ) then
		printf '#\!/bin/tcsh -f\n' >! "${refetch_script}";
		cat "${refetch_script}.tmp" >> "${refetch_script}";
		chmod +x "${refetch_script}";
		"${refetch_script}" ${silent};
		if( ${status} == 0 ) rm "${refetch_script}";
	endif
	if( ${status} == 0 ) rm "${refetch_script}.tmp";
end

if( ${?grep_options} ) then
	setenv GREP_OPTIONS "${grep_options}";
	unset grep_options;
endif

