#!/bin/tcsh -f
	set install_path="${HOME}/.local/share/applications";
	if(! -d "${install_path}" ) then
		mkdir -p "${install_path}";
	endif
	cd "${install_path}";
	
	printf "Creating Yast2 modules .desktop entries...\n";
	foreach module("`/sbin/yast2 -list`")
		printf "Creating .desktop entry for Yast2's %s module's" "$module";;
		if( -e "Yast2-${module}.desktop" ) \
			rm -f "Yast2-${module}.desktop";
		set text="`printf "\""%s"\"" "\""$module"\"" | sed -r 's/^(.)(.+)"\$"/\U\1\l\2/'`";
		printf "#"\!"/usr/bin/env xdg-open\n\n[Desktop Entry]Encoding=UTF-8\nVersion=1.0\nType=Application\nTerminal=false\nIcon[en_US]=/usr/share/icons/hicolor/48x48/apps/yast-${module}.png\nName[en_US]=${text} (yast2 ${module})\nExec=sudo /sbin/yast2 ${module}\nName=${text} ${description}\nIcon=/usr/share/icons/hicolor/48x48/apps/yast-${module}.png\n">! "Yast2-${module}.desktop";
		printf "\t[finished]\n";
		unset module;
	end
