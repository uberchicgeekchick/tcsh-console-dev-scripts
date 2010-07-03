#!/bin/tcsh -f

vim-enhanced -p ./templates/tcsh-script.template.tcsh ./media/oggconvert ./media/playlist-manager/playlist:convert.tcsh ./media/playlist-manager/playlist:find:missing:listings.tcsh ./media/playlist-manager/playlist:find:non-existent:listings.tcsh ./media/playlist-manager/playlist:copy:missing:listings.tcsh ./media/playlist-manager/playlist:sort:by:pubdate.tcsh ./remote-fs/mount:sshfs.tcsh ./helpers/mv.stop.scripting.dammit\!

