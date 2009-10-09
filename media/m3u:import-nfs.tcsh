#!/bin/tcsh -f
set path_to_progies="/projects/cli/media";
set path_to_playlists="/media/library/playlists";

${path_to_progies}/m3u:add-nfs.tcsh "${path_to_playlists}/nfs/m3u/podcasts.local.m3u" "${path_to_playlists}/m3u/podcasts.nfs.m3u";
${path_to_progies}/m3u-to-tox.tcsh "${path_to_playlists}/m3u/podcasts.nfs.m3u" "${path_to_playlists}/tox/podcasts.nfs.tox";
cp --verbose "${path_to_playlists}/tox/podcasts.nfs.tox" "${HOME}/.xine/xine-ui_old_playlist.tox";
${path_to_progies}/tox:strip-nfs.tcsh "${path_to_playlists}/tox/podcasts.nfs.tox" "${path_to_playlists}/nfs/tox/podcasts.local.tox";
