#!/bin/tcsh

foreach which_canvas ( "${argv}" )
	set geometry = `cat "/profile.d/resolutions/gnome-terminal/default.rc"`
	set screens_options = "aAUR"
	set screens_sessions = `/usr/bin/screen -list`
	if ( "$screens_sessions[1]" != "No" ) set screens_options = "${screens_options}x"
	unset screens_sessions

	switch ( "${1}" )
	case 'Template':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${geometry} \
			--tab-with-profile=uberChick --title "screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile=projects --title="projects" --working-directory="/projects" \
		${argv} &
		breaksw

	case 'Media':
		shift
		set geometry = `cat "/profile.d/resolutions/gnome-terminal/alacast.rc"`
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${geometry} \
			--tab-with-profile=uberChick --title "screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile=projects --title "Alacast" --working-directory="/projects/www/Alacast" \
			--tab-with-profile=projects --title="multimedia" --working-directory="/media" \
			--tab-with-profile=rTorrent --working-directory="/media/torrents" --title "rTorrent" --command="rtorrent"  \
			--tab-with-profile=projects --title="uberChicGeekChicks-Podcast-Syncronizer" --working-directory="/projects/www/Alacast/bin" --command="/projects/www/Alacast/bin/uberChicGeekChicks-Podcast-Syncronizer.php --update=detailed --logging --player=xine --interactive" \
		${argv} &
		breaksw

	case 'Canvas':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${geometry} \
			--tab-with-profile=projects --title="/profile.d" --working-directory="/profile.d" \
			--tab-with-profile=uberChick --title "screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile=projects --title "Alacast" --working-directory="/projects/www/Alacast" \
			--tab-with-profile=projects --title="ssh" --working-directory="/projects/ssh" \
			--tab-with-profile=projects --title="www" --working-directory="/projects/www" \
			--tab-with-profile=projects --title="uberChicGeekChick.Com" --working-directory="/projects/www/MyWebDesigns/uberChicGeekChick.Com" \
			--tab-with-profile=projects --title="console" --working-directory="/projects/console" \
			--tab-with-profile=projects --title="gtk" --working-directory="/projects/gtk" \
			--tab-with-profile=projects --title="media" --working-directory="/projects/media" \
		${argv} &
		breaksw
	
	case 'Game-Dev':
		shift
		set geometry = `cat "/profile.d/resolutions/gnome-terminal/game-dev.rc"`
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${geometry} \
			--tab-with-profile=uberChick --title "screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile=projects --title="art" --working-directory="/projects/media/art" \
			--tab-with-profile=projects --title="media-library" --working-directory="/media/media-library" \
			--tab-with-profile=projects --title="game-design" --working-directory="/projects/media/game-design" \
			--tab-with-profile=projects --title="tools" --working-directory="/projects/media/game-design/tools" \
			--tab-with-profile=projects --title="engines" --working-directory="/projects/media/game-design/engines" \
			--tab-with-profile=projects --title="libraries" --working-directory="/projects/media/game-design/libraries" \
			--tab-with-profile=projects --title="Raydium" --working-directory="/projects/media/game-design/engines/Raydium" \
		${argv} &
		breaksw

	case 'Audio':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${geometry} \
			--tab-with-profile=uberChick --title "screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile=projects --title="Alacast" --working-directory="/projects/www/Alacast" \
			--tab-with-profile=projects --title="podcasts" --working-directory="/projects/media/podcasts" \
			--tab-with-profile=projects --title="media library" --working-directory="/media/media-library" \
		${argv} &
		breaksw

	case 'Screen':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${geometry} \
			--tab-with-profile=uberChick --working-directory="${HOME}" \
			--tab-with-profile=screen --title "screen" --command="/usr/bin/screen -${screens_options}"  \
		${argv} &
	case "CLI":
		shift
	default:
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${geometry} \
			--tab-with-profile=uberChick --working-directory="/profile.d" \
			--tab-with-profile=screen --title "screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile=Alacast --working-directory="/projects/gtk/Alacast/OPMLs" \
			--tab-with-profile=uberChick --working-directory="/media" \
			--tab-with-profile=rTorrent --working-directory="/media/torrents" --title "rTorrent" --command="rtorrent"  \
			--tab-with-profile=uberChick --working-directory="/projects" \
			--tab-with-profile=uberChick --working-directory="/projects/www/MyWebDesigns/uberChicGeekChick.Com" \
			--tab-with-profile=uberChick --working-directory="${HOME}" \
		${argv} &
		breaksw
	endsw
end
