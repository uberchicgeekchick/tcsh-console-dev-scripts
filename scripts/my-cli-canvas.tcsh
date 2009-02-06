#!/bin/tcsh -f
set resolution_path = "/profile.d/resolutions/gnome-terminal"

foreach which_canvas ( "${argv}" )
	set default_geometry = `cat "${resolution_path}/default.rc"`
	set canvas_geometry = `cat "${resolution_path}/canvas.rc"`

	set screen_command = "/usr/bin/screen -aAUR"
	set screens_options = "aAUR"
	set screens_sessions = `/usr/bin/screen -list`
	if ( "$screens_sessions[1]" != "No" ) then
		set screen_command = "${screen_command}x"
		set screens_options = "${screens_options}x"
	endif
	alias screen "${screen_command}"
	unset sceen_command
	unset screens_sessions
	
	set default_tabs = ( "--tab-with-profile=screen --title=:screen: --command=screen" \
		"--tab-with-profile=projects --title=/profile.d --working-directory=/profile.d" \
		"--tab-with-profile=projects --title=/media --working-directory=/media" \
		"--tab-with-profile=projects --title=~/ --working-directory=${HOME}" \
		"--tab-with-profile=projects --title=/ssh --working-directory=/projects/ssh" \
		"--tab-with-profile=projects --title=/srv --working-directory=/srv" \
		"--tab-with-profile=projects --title=/programs --working-directory=/programs" \
		"--tab-with-profile=projects --title=/projects --working-directory=/projects" \
	);
	
	switch ( "${which_canvas}" )
	case 'Template':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${default_geometry} \
			${default_tabs} \
		${argv} &
		breaksw
	
	case 'Editor:VIM':
		set vim_resolution = `cat ${resolution_path}/vim.rc`
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${default_geometry} \
			--tab-with-profile="projects" --title="vim-enhanced" --working-directory="/projects" --command="/usr/bin/vim-enhanced -p ${argv}" \
		&
		breaksw
		
	case 'Editor:Default':
		set vim_resolution = `cat ${resolution_path}/vim.rc`
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${default_geometry} \
			--tab-with-profile="projects" --title="${EDITOR}" --working-directory="/projects" --command="${EDITOR} -p ${argv}" \
		&
		breaksw
	
	case 'Programming:All':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			${default_tabs} \
			--tab-with-profile="projects" --title="console" --working-directory="/projects/console" \
			--tab-with-profile="projects" --title="gtk" --working-directory="/projects/gtk" \
			--tab-with-profile="projects" --title="art" --working-directory="/projects/art" \
			--tab-with-profile="projects" --title="www" --working-directory="/projects/www" \
			--tab-with-profile="projects" --title="media" --working-directory="/projects/media" \
			--tab-with-profile="projects" --title="games" --working-directory="/projects/games" \
		${argv} &
		breaksw
	
	case 'Programming:Games':
		shift
		set canvas_geometry = `cat "${resolution_path}/game-dev.rc"`
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			${default_tabs} \
			--tab-with-profile="projects" --title="media-library" --working-directory="/media/media-library" \
			--tab-with-profile="projects" --title="tools" --working-directory="/projects/games/tools" \
			--tab-with-profile="projects" --title="engines" --working-directory="/projects/games/engines" \
			--tab-with-profile="projects" --title="libraries" --working-directory="/projects/games/libraries" \
			--tab-with-profile="projects" --title="Raydium" --working-directory="/projects/games/engines/Raydium" \
			--tab-with-profile="projects" --title="art" --working-directory="/projects/art" \
			--tab-with-profile="projects" --title="game-design" --working-directory="/projects/games" \
		${argv} &
		breaksw

	case 'Programming:Internet':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			${default_tabs} \
			--tab-with-profile="projects" --title="Alacast-v2" --working-directory="/projects/gtk/Alacast" \
			--tab-with-profile="projects" --title="reference" --working-directory="/projects/reference" \
			--tab-with-profile="projects" --title="art" --working-directory="/projects/art" \
			--tab-with-profile="projects" --title="www" --working-directory="/projects/www" \
			--tab-with-profile="projects" --title="realFriends" --working-directory="/projects/www/realFriends" \
			--tab-with-profile="projects" --title="MyWebDesigns" --working-directory="/projects/www/MyWebDesigns" \
			--tab-with-profile="projects" --title="uberChicGeekChick.Com" --working-directory="/projects/www/MyWebDesigns/uberChicGeekChick.Com" \
		${argv} &
		breaksw
	
	case 'Programming:Apps':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			${default_tabs} \
			--tab-with-profile="projects" --title="console" --working-directory="/projects/console" \
			--tab-with-profile="projects" --title="tcsh-dev" --working-directory="/projects/console/tcsh-dev" \
			--tab-with-profile="projects" --title="gtk" --working-directory="/projects/gtk" \
			--tab-with-profile="projects" --title="art" --working-directory="/projects/art" \
			--tab-with-profile="projects" --title="Alacast-v2" --working-directory="/projects/gtk/Alacast" \
			--tab-with-profile="projects" --title="connectED" --working-directory="/projects/gtk/connectED" \
		${argv} &
		breakswt
	
	case 'Media:Production':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${canvas_geometry} \
			${default_tabs} \
			--tab-with-profile="projects" --title="art" --working-directory="/projects/art" \
			--tab-with-profile="projects" --title="Alacast-v2" --working-directory="/projects/gtk/Alacast" \
			--tab-with-profile="projects" --title="/media" --working-directory="/media" \
			--tab-with-profile="projects" --title="/media-library" --working-directory="/media/media-library" \
			--tab-with-profile="projects" --title="my podcasts" --working-directory="/projects/media/podcasts" \
		${argv} &
		breaksw

	case 'Media:Social':
		shift
		if ( -e "${HOME}/.rtorrent.rc" ) then
			set rtorrent_session_dir = `/usr/bin/grep 'session' "${HOME}/.rtorrent.rc" | /usr/bin/sed 's/^[^=]\+=\ \(.*\)$/\1/g'`
			if ( "${rtorrent_session_dir}" != "" && -d "${rtorrent_session_dir}" ) then
				rm -f "${rtorrent_session_dir}/rtorrent.lock"
				rm -f "${rtorrent_session_dir}/rtorrent.dht_cache"
			endif
		endif
		
		set alacast_geometry = `cat "${resolution_path}/alacast.rc"`
		
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${alacast_geometry} \
			--tab-with-profile="rTorrent" --title="rTorrent" --working-directory="/media/torrents" --command="rtorrent"  \
			--tab-with-profile="screen" --title="[screen]" --command="/usr/bin/screen -${screens_options}"  \
			--tab-with-profile="projects" --title="/projects" --working-directory="/projects" \
			--tab-with-profile="projects" --title="Alacast-v2" --working-directory="/projects/gtk/Alacast" \
			--tab-with-profile="projects" --title="/media" --working-directory="/media" \
			--tab-with-profile="projects" --title="podiobooks" --working-directory="/media/podiobooks" \
			--tab-with-profile="projects" --title="podcasts" --working-directory="/media/podcasts" \
			--tab-with-profile="projects" --title="alacast" --working-directory="/projects/console/Alacast" --command="/projects/console/Alacast/bin/uberChicGeekChicks-Podcast-Syncronizer.php --update=detailed --logging --player=xine --interactive" \
		${argv} &
		breaksw

	case 'Session:Screen':
		shift
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${default_geometry} \
			--tab-with-profile="screen" --title="[screen]" --command="/usr/bin/screen -${screens_options}"  \
		${argv} &
		breaksw
	case 'CLI':
		shift
	default:
		/usr/bin/gnome-terminal \
			--hide-menubar \
			--geometry=${default_geometry} \
			${default_tabs} \
		${argv} &
		breaksw
	endsw
end
