#!/bin/tcsh

foreach which_canvas ( "${argv}" )
	set default_geometry = `cat "/profile.d/resolutions/gnome-terminal/default.rc"`
	set canvas_geometry = `cat "/profile.d/resolutions/gnome-terminal/canvas.rc"`
	set alacast_geometry = `cat "/profile.d/resolutions/gnome-terminal/alacast.rc"`

	set screens_options = "aAUR"
	set screens_sessions = `/usr/bin/screen -list`
	if ( "$screens_sessions[1]" != "No" ) set screens_options = "${screens_options}x"
	unset screens_sessions

	switch ( "${which_canvas}" )
	case 'Template':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${default_geometry} \
			--tab-with-profile="uberChick" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="projects" --title="projects" --working-directory="/projects" \
		${argv} &
		breaksw

	case 'Programming:All':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			--tab-with-profile="uberChick" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="projects" --title="/profile.d" --working-directory="/profile.d" \
			--tab-with-profile="uberChick" --title="srv" --working-directory="/srv" \
			--tab-with-profile="projects" --title="projects" --working-directory="/projects" \
			--tab-with-profile="projects" --title="ssh" --working-directory="/projects/ssh" \
			--tab-with-profile="projects" --title="console" --working-directory="/projects/console" \
			--tab-with-profile="projects" --title="gtk" --working-directory="/projects/gtk" \
			--tab-with-profile="projects" --title="GTK-PHP-IDE" --working-directory="/projects/gtk/GTK-PHP-IDE/GTK-PHP-IDE" \
			--tab-with-profile="projects" --title="Alacast" --working-directory="/projects/www/Alacast" \
			--tab-with-profile="projects" --title="www" --working-directory="/projects/www" \
			--tab-with-profile="projects" --title="uberChicGeekChick.Com" --working-directory="/projects/www/MyWebDesigns/uberChicGeekChick.Com" \
			--tab-with-profile="projects" --title="my media" --working-directory="/projects/media" \
			--tab-with-profile="projects" --title="my games" --working-directory="/projects/games" \
		${argv} &
		breaksw
	
	case 'Programming:Games':
		shift
		set geometry = `cat "/profile.d/resolutions/gnome-terminal/game-dev.rc"`
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			--tab-with-profile="uberChick" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="projects" --title="projects" --working-directory="/projects" \
			--tab-with-profile="projects" --title="art" --working-directory="/projects/media/art" \
			--tab-with-profile="projects" --title="media-library" --working-directory="/media/media-library" \
			--tab-with-profile="projects" --title="game-design" --working-directory="/projects/media/game-design" \
			--tab-with-profile="projects" --title="tools" --working-directory="/projects/media/game-design/tools" \
			--tab-with-profile="projects" --title="engines" --working-directory="/projects/media/game-design/engines" \
			--tab-with-profile="projects" --title="libraries" --working-directory="/projects/media/game-design/libraries" \
			--tab-with-profile="projects" --title="Raydium" --working-directory="/projects/media/game-design/engines/Raydium" \
		${argv} &
		breaksw

	case 'Programming:WebApps':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			--tab-with-profile="uberChick" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="projects" --title="projects" --working-directory="/projects" \
			--tab-with-profile="projects" --title="reference" --working-directory="/projects/reference" \
			--tab-with-profile="uberChick" --title="srv" --working-directory="/srv" \
			--tab-with-profile="projects" --title="GTK-PHP-IDE" --working-directory="/projects/gtk/GTK-PHP-IDE/GTK-PHP-IDE" \
			--tab-with-profile="projects" --title="ssh" --working-directory="/projects/ssh" \
			--tab-with-profile="projects" --title="www" --working-directory="/projects/www" \
			--tab-with-profile="projects" --title="Alacast" --working-directory="/projects/www/Alacast" \
			--tab-with-profile="projects" --title="uberChicGeekChick.Com" --working-directory="/projects/www/MyWebDesigns/uberChicGeekChick.Com" \
		${argv} &
		breaksw
	
	case 'Programming:Apps':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			--tab-with-profile="uberChick" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="projects" --title="/profile.d" --working-directory="/profile.d" \
			--tab-with-profile="projects" --title="projects" --working-directory="/projects" \
			--tab-with-profile="projects" --title="ssh" --working-directory="/projects/ssh" \
			--tab-with-profile="projects" --title="gtk" --working-directory="/projects/gtk" \
			--tab-with-profile="projects" --title="GTK-PHP-IDE" --working-directory="/projects/gtk/GTK-PHP-IDE/GTK-PHP-IDE" \
			--tab-with-profile="projects" --title="console" --working-directory="/projects/console" \
			--tab-with-profile="projects" --title="Alacast" --working-directory="/projects/www/Alacast" \
		${argv} &
		breaksw
	
	case 'Media:Production':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			--tab-with-profile="uberChick" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="uberChick" --title="media" --working-directory="/media" \
			--tab-with-profile="projects" --title="media library" --working-directory="/media/media-library" \
			--tab-with-profile="projects" --title="my podcasts" --working-directory="/projects/media/podcasts" \
			--tab-with-profile="projects" --title="my media" --working-directory="/projects/media" \
		${argv} &
		breaksw

	case 'Media:Social':
		shift
		set rtorrent_session_dir = "`/usr/bin/grep -r session ~/.rtorrent.rc | sed 's/session\ =\ \(.*\)/\1'/`"
		if ( "${rtorrent_session_dir}" != "" && -d "${rtorrent_session_dir}" ) then
			if ( -e "${rtorrent_session_dir}/rtorrent.lock" ) rm -f "${rtorrent_session_dir}/rtorrent.lock"
			#if ( -e "${rtorrent_session_dir}/rtorrent.dht_cache" ) rm -f "${rtorrent_session_dir}/rtorrent.dht_cache"
		end
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${alacast_geometry} \
			--tab-with-profile="rTorrent" --title="rTorrent" --working-directory="/media/torrents" --command="rtorrent"  \
			--tab-with-profile="uberChick" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="projects" --title="media" --working-directory="/media" \
			--tab-with-profile="projects" --title="podiobooks" --working-directory="/media/podiobooks" \
			--tab-with-profile="projects" --title="podcasts" --working-directory="/media/podcasts" \
			--tab-with-profile="projects" --title="Alacast" --working-directory="/projects/www/Alacast" \
			--tab-with-profile="projects" --title="uberChicGeekChicks-Podcast-Syncronizer" --working-directory="/projects/www/Alacast/bin" --command="/projects/www/Alacast/bin/uberChicGeekChicks-Podcast-Syncronizer.php --update=detailed --logging --player=xine --interactive" \
		${argv} &
		breaksw

	case 'Session:Screen':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${default_geometry} \
			--tab-with-profile="uberChick" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="uberChick" --title="~/" --working-directory="${HOME}" \
		${argv} &
		breaksw
	case "CLI":
		shift
	default:
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${default_geometry} \
			--tab-with-profile="screen" --title="screen" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="uberChick" --title="/profile.d" --working-directory="/profile.d" \
			--tab-with-profile="uberChick" --title="srv" --working-directory="/srv" \
			--tab-with-profile="uberChick" --title="ssh" --working-directory="/projects/ssh" \
			--tab-with-profile="Alacast" --title="programs" --working-directory="/programs" \
			--tab-with-profile="uberChick" --title="media" --working-directory="/media" \
			--tab-with-profile="uberChick" --title="projects" --working-directory="/projects" \
			--tab-with-profile="uberChick" --title="~/" --working-directory="${HOME}" \
		${argv} &
		breaksw
	endsw
end
