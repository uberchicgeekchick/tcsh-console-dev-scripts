#!/bin/tcsh -f
vim-enhanced -p /media/library/playlists/m3u/eee.m3u /media/library/playlists/m3u/podcasts.m3u /media/podcasts/playlists/m3u/"`/bin/ls -tr --width 1 /media/podcasts/playlists/m3u/ | tail -1`" /media/clean-up.tcsh /media/library/playlists/m3u/podiobooks.m3u /media/library/playlists/m3u/lifestyle.m3u;
