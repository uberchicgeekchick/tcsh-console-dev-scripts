#!/bin/tcsh
ffmpeg -i "${1}" -vcodec libtheora -acodec vorbis The\ Prestige-\[theora]\[vorbis].ogg
