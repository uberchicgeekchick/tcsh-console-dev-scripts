#!/bin/tcsh -f
alias	mp3info	"id3v2 --list"

set xfmedia_settings="${HOME}/.config/xfmedia/settings.xml"
set condition="if ( -e '${xfmedia_settings}' ) mv '${xfmedia_settings}' '${xfmedia_settings}.bck'; "
set output=">& /dev/null &"

set sound_driver="oss"
set video_driver="opengl"
set resolution=`cat "/profile.d/resolutions/video/hd.rc"`

alias xfmedia "${condition}/usr/bin/xfmedia --video-out=${video_driver} --audio-out=${sound_driver} --vwin-geometry=${resolution} ${output}"
foreach resolution_source ( /profile.d/resolutions/video/* )
	set alias_suffix=`basename "${resolution_source}" | cut -d'.' -f1`
	set resolution=`cat "${resolution_source}"`
	alias "xfmedia-${alias_suffix}" "${condition}/usr/bin/xfmedia --video-out=${video_driver} --audio-out=${sound_driver} --vwin-geometry='${resolution_source}' ${output}"
end

set totem_playlist="/media/media-library/Playlists/default.m3u"
alias totem "if ( ! -e '${totem_playlist}' ) touch '${totem_playlist}' ; /usr/bin/totem '${totem_playlist}'";

alias gpodder "/projects/console/tcsh-dev/media-organization/gPodder/gPodder:Silent:STDERR.tcsh"
