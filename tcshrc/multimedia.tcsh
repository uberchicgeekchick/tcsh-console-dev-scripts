#!/bin/tcsh -f
alias	mp3info	"id3v2 --list"

set sound_driver = "alsa"
set video_driver = "opengl"
set resolution = `cat "/profile.d/resolutions/video/hd.rc"`

alias xfmedia "/usr/bin/xfmedia --video-out=${video_driver} --audio-out=${sound_driver} --vwin-geometry=${resolution}"
foreach resolution_source ( /profile.d/resolutions/video/* )
	set alias_suffix = `basename "${resolution_source}" | cut -d'.' -f1`
	set resolution = `cat "${resolution_source}"`
	alias "xfmedia-${alias_suffix}" "/usr/bin/xfmedia --video-out=${video_driver} --audio-out=${sound_driver} --vwin-geometry='${resolution_source}'"
end
