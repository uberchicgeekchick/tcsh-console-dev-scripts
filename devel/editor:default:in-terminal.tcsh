#!/bin/tcsh -f
set vim_resolution = `cat /profile.d/resolutions/gnome-terminal/vim.rc`
/usr/bin/gnome-terminal \
	--hide-menubar \
	--geometry=${default_geometry} \
		--tab-with-profile="projects" --title="vim-enhanced" --working-directory="/projects" --command="${EDITOR}l ${argv}" \
&
