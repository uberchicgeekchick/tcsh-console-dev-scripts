#!/bin/tcsh -f
if ( -x "/usr/bin/ghb" ) then
	alias	handbrake	"/usr/bin/ghb"
	alias	HandBrake	"handbrake"
	alias	HandBrakeGTK	"handbrake"
	alias	HandBrakeGUI	"handbrake"
endif

if ( -x "/usr/bin/id3v2" ) alias	mp3info	"id3v2 --list"

if ( -x "/usr/bin/xfmedia" ) then
	set xfmedia_settings="${HOME}/.config/xfmedia/settings.xml"
	set condition="if ( -e '${xfmedia_settings}' ) mv '${xfmedia_settings}' '${xfmedia_settings}.bck'; "
	set output=">& /dev/null &"

	#set sound_driver="oss"
	#set video_driver="opengl"
	set sound_driver="esd"
	set video_driver="sdl"
	
	set resolution=`cat "/profile.d/resolutions/video/hd.rc"`
	
	alias xfmedia "${condition}/usr/bin/xfmedia --video-out=${video_driver} --audio-out=${sound_driver} --vwin-geometry=${resolution} ${output}"
	foreach resolution_source ( /profile.d/resolutions/video/* )
		set alias_suffix=`basename "${resolution_source}" | cut -d'.' -f1`
		set resolution=`cat "${resolution_source}"`
		alias "xfmedia-${alias_suffix}" "${condition}/usr/bin/xfmedia --video-out=${video_driver} --audio-out=${sound_driver} --vwin-geometry='${resolution_source}' ${output}"
	end
endif

set totem_playlist="/media/media-library/playlists/default.m3u"
alias totem "if ( ! -e '${totem_playlist}' ) touch '${totem_playlist}' ; /usr/bin/totem '${totem_playlist}' ${output}";

alias gpodder "/projects/cli/tcsh-dev/media/gPodder-helper-scripts/gPodder:Silent:STDERR.tcsh"
