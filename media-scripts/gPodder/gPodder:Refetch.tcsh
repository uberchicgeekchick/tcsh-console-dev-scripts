#!/bin/tcsh -f
if ( "${?1}" == "0" ) then
	printf "Usage: %s [search term]" $o
	exit -1
endif

gPodder:Search:index.rss.tcsh --output "${1}" >! "Refetch:${1} Podcasts.tcsh"
vi '+1,$s/.*<title>\([^>]\+\)<\/title>.*<title>\([^<]\+\)<\/title>.*<url>\([^<]\+\)<\/url>.*/if ( ! -d "\1" ) mkdir "\1"\rwget -O "\1\/\2.mp3" "\3"/g' '+wq' "Refetch:${1} Podcasts.tcsh"
