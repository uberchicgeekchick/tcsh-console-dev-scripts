#!/bin/tcsh -f
set gPodder_install_path = "/programs/src"

set tarball_backup_path = "/uberChick/Downloads/Multimedia/Podcatchers/gPodder"
if( ! -d "${tarball_backup_path}" ) mkdir -p "${tarball_backup_path}"

cd "${gPodder_install_path}"
foreach gPodder ( gpodder* )
	printf "\tI'm backing up gPodder version %s:\t\t" `echo ${gPodder} | cut -d\- -f2`
	tar -czf "${tarball_backup_path}/${gPodder}.tar.gz" "${gPodder}"
	if( ! -e "${tarball_backup_path}/${gPodder}.tar.gz" ) then
		printf "[fail]\n"
	else
		printf "[done]\n"
	endif
end
