#!/bin/tcsh -f
if ( ! ${?1} ) then
	printf "Usage: %s [search term]" $0
	exit -1
endif

cd "`dirname '${0}'`";

gPodder:Search:index.rss.tcsh --verbose "${1}" >! "Refetch:${1} Podcasts.tcsh"
ex '+1,$s/[\r\n]\+//' '+1,$s/\(<\/item>\)/\1\n/g' '+1,$s/.*<title>\([^>]\+\)<\/title>.*<title>\([^<]\+\)<\/title>.*<url>\([^<]\+\)<\/url>.*/if ( ! -d "\1" ) mkdir "\1"\rwget -O "\1\/\2.mp3" "\3"/g' '+wq' "Refetch:${1} Podcasts.tcsh"
