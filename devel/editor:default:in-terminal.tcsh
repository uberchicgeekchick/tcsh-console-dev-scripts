#!/bin/tcsh -f
cd `dirname ${0}`
set resolution = `cat ../resolutions/gnome-terminal/editor.rc`
/usr/bin/gnome-terminal \
	--hide-menubar \
	--geometry=${geometry} \
		--tab-with-profile="projects" --title="${EDITOR}" --working-directory="/projects" --command="${EDITOR}l ${argv}" \
&
