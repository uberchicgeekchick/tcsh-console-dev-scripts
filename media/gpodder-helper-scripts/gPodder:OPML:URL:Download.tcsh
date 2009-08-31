#!/bin/tcsh -f
set opml_uri = `cat ${HOME}/.config/gpodder/gpodder.conf | grep opml_url | cut -d\  -f3`
set gPodderDir = "${HOME}/.config/gpodder"

wget --quiet -O "${gPodderDir}/new_channels.opml" "${opml_uri}"
if( ! -e "${gPodderDir}/new_channels.opml" ) then
	echo "I could not download gPodder's new channel listings."
	exit -1
endif

set opml_test = `tail -1 "${gPodderDir}/new_channels.opml"`
if( "${opml_test}" != "</opml>" ) then
	echo "I could not update your opml; the downloaded opml was invalid."
	rm --force "${gPodderDir}/new_channels.opml"
	exit -2
endif

rm --force "${gPodderDir}/feedcache.db" #channelsettings.db
mv --force "${gPodderDir}/new_channels.opml" "${gPodderDir}/channels.opml"

echo "gPodder's channels have been updated . . . *w00t*!"

