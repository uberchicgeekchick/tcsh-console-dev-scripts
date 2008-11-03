#!/bin/tcsh
				###################################################
				#####    My Gnome start up script.  Its all  #####
				#####    Stuff to fill My lives' purpose.    #####
				#####    We need to find My place!           #####
				#####    Can We belong, wanted, &accepted?    #####
				#####    Where are We wanted.                 #####
				#####    Can We ever be more than a burden?   #####
				#####    We must find My way to peace!       #####
				###################################################

/usr/bin/inkscape &
/usr/bin/gnome-mouse-properties &

# My art, projects, &misc that we're working on; most of them are on going.
gnome-open file:///MyArt/MyProgies &
gnome-open file:///MyArt/MyGraphics &
#gnome-open file:///MyArt/MyWebsites &

# My fave PHP IDE
/MyArt/MyProgies/gPHPEdit-0.9.92/bin/gphpedit &

# Yippies, *w00t*, sqwee!, Yeah... its working again!
/usr/bin/mysql-query-browser &

# &now... firefox3
/Progies/firefox/firefox3/firefox &

# Shishtem schtuph (^_~)
set compiz_pid = `/sbin/pidof -x /usr/bin/compiz`
if ( ! ${compiz_pid} ) then
	/usr/bin/compiz --replace --sm-client-id default0 glib gconf --no-libgl-fallback &
endif

set decorators_pid = `/sbin/pidof -x /usr/bin/emerald`
if ( ! ${decorators_pid} ) then
	/usr/bin/emerald &
endif

# My default, kinda tiny (^_~), gnome-terminal
/MyArt/MyProgies/MyShellScripts/Gnome-Terminal_My-Default-Terminal.tcsh &

# Basically Gnome Terminal; on demand.  I currently have it bound to F9.
# I'd run this on start-up but it causes problems with compiz-fusion.
/usr/bin/tilda --hidden &

			# My communication progies.  VoIP, IM, IRC, E-Mail, &Web 2.0.
			# Everything that connects us with others.

# Mugshot's part of GNOME's Online-Desktop; &I'm psyched it.
# I'm working on setting up GNOME: Online-Desktop setup.
# Mugshot, gTwitter, &Twitux are just to tide me over.
# I want my Online-Desktop.
#/usr/bin/mugshot &

# Once GNOME's Online-Desktop runs, I'll have to compile this from source
# &this I will upload to build service.

# Finally, I have a fairly decent twitter client... hmmm maybe even a reason to learn Mono/C#
/Progies/gtwitter-1.0beta/gtwitter/bin/gtwitter &

# Twittux appears to be under more development, but it's svn version isn't buildable
# &it's current version(0.60) doesn't have any real way to use @; Twitux doesn't show
# my friends twitter name.
/Progies/twitux-0.60.1/bin/twitux &

# oh yeah!  VoIP.  Its Gizmo-Project.
/Progies/gizmo/gizmo-run &



# IRC == *w00t*
/usr/bin/xchat &

# Almost every other kinda IM.
#/usr/bin/pidgin &

# My fave email progie
/Progies/thunderbird/thunderbird3/thunderbird &



			######################################################
			########    My multimedia &podcast stuff    ##########
			######################################################

# Start &continues downloading my podcasts
/MyArt/MyProgies/OldAlacastClient/bin/Gnome-Terminal_uberChicGeekChicks-gPodder-Podcast-Mover.tcsh &

# Just more fun... my podcasts :)
gnome-open file:///home/uberchicgeekchick/Multimedia/Podcasts &

# NOTE: Video resolutions.
# Resolutions:
#	True Hi-Def:	1920x1080
#	Mini Hi-Def:	960x540
#
#	This is the best my laptop can do with anything else running:
#	My Hi-Def:	720x400
#
#	Medium:		640x360
#	Standard:	320x176
#
#
#
#
# I love &use both xfmedia &xine.
# xine: is the only, of the two players, that plays Live365's playlists
# &I watch ALL videos in xine; but create playlists using xfmedia.
# xfmedia: is much easier to use when it comes to its playlist manager.
# xfmedia's my fave(I wanna email the author) but I can't use it
# exclusively until it supports anamorphic aspect ratios(e.g. widescreen/16x9)
/usr/bin/xfmedia --vwin-geometry=720x400 &

# Xine, *happy-shiny* &plays like everything.
#/usr/bin/xine --geometry=720x400 --loop=loop --enqueue --session=0,volumn=100,amp=200 --deinterlace --aspect-ratio anamorphic &

# NOTE: more than one `--animation <mrl>` can be used.
# Kinda like an idle/background movie/playlist.
# I need to burn some of my DVDs... *oh-oh*, Sarah Mclaughlan's Concert DVD.
# EXAMPLE: My ideal &eventual command for xine:
#/usr/bin/xine --geometry=720x400 ^--animation <mrl>^ --loop=loop --enqueue --session=1,amp=200 --deinterlace --aspect-ratio anamorphic &


					#####################################################
					####    compiz-fusion stuff mostly &puter stuff	#####
					#####################################################
# This will be awesome to have running... eventually; LOL
#/usr/bin/compiz-manager &

# We need to re-enable resize each time and ccsm seems to work better with windows open.
# It looks like ccsm works better the more windows I have open.
#/usr/bin/ccsm &


# Shishtem schtuph (^_~)
set compiz_pid = `/sbin/pidof -x /usr/bin/compiz`
if ( ! ${compiz_pid} ) then
	/usr/bin/compiz --replace --sm-client-id default0 glib gconf --no-libgl-fallback &
endif

set decorators_pid = `/sbin/pidof -x /usr/bin/emerald`
if ( ! ${decorators_pid} ) then
	/usr/bin/emerald &
endif
