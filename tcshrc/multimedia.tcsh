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
	#set condition="";
	set output=">& /dev/null &"

	#set audio_driver="oss"
	set video_driver="opengl"
	#set audio_driver="alsa"
	set audio_driver="esd"
	#set video_driver="sdl"
	
	set resolution=`cat "/profile.d/resolutions/video/hd.rc"`
	
	alias	xine	"/usr/bin/xine --video-driver ${video_driver} --audio-drive ${audio_driver} --geometry=${resolution} --session volumn=200,amp=200,loop=repeat --deinterlace --aspect-ratio anamorphic"
	alias xfmedia "${condition}/usr/bin/xfmedia --video-out=${video_driver} --audio-out=${audio_driver} --vwin-geometry=${resolution} ${output}"
	foreach resolution_source ( /profile.d/resolutions/video/* )
		set alias_suffix=`basename "${resolution_source}" | cut -d'.' -f1`
		set resolution=`cat "${resolution_source}"`
		alias	"xine-${alias_suffix}"	"/usr/bin/xine --geometry=${resolution} --aspect-ratio=anamorphic"
		alias "xfmedia-${alias_suffix}" "${condition}/usr/bin/xfmedia --video-out=${video_driver} --audio-out=${audio_driver} --vwin-geometry='${resolution_source}' ${output}"
	end
endif

set totem_playlist="/media/media-library/playlists/default.m3u"
alias	totem		"if ( ! -e '${totem_playlist}' ) touch '${totem_playlist}' ; /usr/bin/totem '${totem_playlist}' ${output}";
set video_playlist="/media/media-library/playlists/video.m3u"
alias	totem-video	"if ( ! -e '${video_playlist}' ) touch '${video_playlist}' ; /usr/bin/totem --class='totem-video' '${video_playlist}' ${output}";

alias gpodder "/projects/cli/tcsh-dev/media/gPodder-helper-scripts/gPodder:Silent:STDERR.tcsh"

unset audio_driver video_driver resolution resolution_source output condition totem_playlist video_playlist

