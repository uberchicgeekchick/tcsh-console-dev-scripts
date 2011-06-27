#!/bin/tcsh -f
cd `dirname ${0}`
set resolution=`cat ../resolutions/gnome-terminal/editor.rc`
/usr/bin/gnome-terminal \
	--hide-menubar \
		--geometry=${geometry} \
		--tab-with-profile="screen" --title="[screen]" --command="/usr/bin/screen -${screens_options}"  \
		--tab-with-profile="projects" --title="vim-enhanced" --working-directory="/projects" --command="/usr/bin/vim-enhanced -p ${argv}" \
		&
