#!/bin/tcsh -f
if ( -x "/usr/bin/ghb" ) then
	alias	handbrake	"/usr/bin/ghb"
	alias	HandBrake	"handbrake"
	alias	HandBrakeGTK	"handbrake"
	alias	HandBrakeGUI	"handbrake"
endif

if ( -x "/usr/bin/id3v2" ) alias	mp3info	"id3v2 --list"

if ( -x "/usr/bin/xfmedia" ) then
	set output=" &";
	if( ${?QUIT_EXEC} ) set output=" >& /dev/null &";
	
	#set audio_driver="alsa"
	#set audio_driver="oss"
	set audio_driver="esd"
	
	#set video_driver="sdl"
	set video_driver="opengl"
	
	set resolution=`cat "/profile.d/resolutions/video/hd.rc"`
	
	#set xfmedia_settings="${HOME}/.config/xfmedia/settings.xml"
	#set xfmedia_condition="if ( -e '${xfmedia_settings}' ) mv '${xfmedia_settings}' '${xfmedia_settings}.bck'; "
	set xfmedia_playlist="/media/library/playlists/xfmedia.m3u"
	set xfmedia_condition="if(! -e '${xfmedia_playlist}' ) touch '${xfmedia_playlist}'; "
	alias xfmedia "${xfmedia_condition}/usr/bin/xfmedia --video-out="\""${video_driver}"\"" --audio-out="\""${audio_driver}"\"" --vwin-geometry="\""${resolution}"\""${output}"
	
	foreach resolution_source ( /profile.d/resolutions/video/* )
		set alias_suffix=`basename "${resolution_source}" | cut -d'.' -f1`
		set resolution=`cat "${resolution_source}"`
		alias "xfmedia-${alias_suffix}" "${xfmedia_condition}/usr/bin/xfmedia --video-out="\""${video_driver}"\"" --audio-out="\""${audio_driver}"\"" --vwin-geometry="\""${resolution}"\""${output}"
	end
endif

if( -x "/usr/bin/xine" ) then
	alias	xine	"/usr/bin/xine --video-driver ${video_driver} --audio-drive ${audio_driver} --geometry=${resolution} --session volumn=200,amp=200,loop=repeat --deinterlace --aspect-ratio anamorphic${output}"
	foreach resolution_source ( /profile.d/resolutions/video/* )
		set alias_suffix=`basename "${resolution_source}" | cut -d'.' -f1`
		set resolution=`cat "${resolution_source}"`
		alias	"xine-${alias_suffix}"	"/usr/bin/xine --video-driver ${video_driver} --audio-drive ${audio_driver} --geometry=${resolution} --session volumn=200,amp=200,loop=repeat --deinterlace --aspect-ratio anamorphic${output}"
	end
endif

if( -x "/usr/bin/totem" ) then
	set totem_audio_playlist="/media/library/playlists/default.m3u"
	alias	totem		"if ( ! -e '${totem_audio_playlist}' ) touch '${totem_audio_playlist}' ; /usr/bin/totem '${totem_audio_playlist}'${output}";
	set totem_video_playlist="/media/library/playlists/video.m3u"
	alias	totem-video	"if ( ! -e '${totem_video_playlist}' ) touch '${totem_video_playlist}' ; /usr/bin/totem --class='totem-video' '${totem_video_playlist}'${output}";
endif

#alias gpodder "/projects/cli/helpers/exec:silent:stderr gpodder"
alias gpodder "/projects/cli/media/gPodder-helper-scripts/gPodder:Silent:STDERR.tcsh"

unset audio_driver video_driver resolution resolution_source output xfmedia_condition xfmedia_playlist totem_audio_playlist totem_video_playlist

