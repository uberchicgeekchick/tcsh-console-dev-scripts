#!/bin/tcsh -f
while\(1)
	if ( -e '/uberChick/.config/xfmedia/settings.xml' ) mv '/uberChick/.config/xfmedia/settings.xml' '/uberChick/.config/xfmedia/settings.xml.bck'; /usr/bin/xfmedia --video-out=sdl --audio-out=esd --vwin-geometry=720x400 >& /dev/null &
end
