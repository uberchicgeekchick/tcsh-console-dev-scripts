#!/bin/tcsh

if ( "${?1}" == "0" ) then
	echo "Usage:\n\tprofileBackup.tcsh progie [extraFile1 extraFile2...]";
	exit -1;
endif

set firefoxProfile = "/home/uberchicgeekchick/Settings/profiles/$1/uberChicGeekChick"
set backupTarball = "/home/uberchicgeekchick/Backups/profiles/$1.tar.bz2"
shift
cd ${firefoxProfile}
#	set profileDir = exec "basename `pwd`"
#	set backupCommand = "tar -cjf ${backupTarball} ${profileDir}/bookmarks.html ${profileDir}/cookies.txt ${profileDir}/formhistory.dat ${profileDir}/history.dat ${profileDir}/persdict.dat ${profileDir}/search.sqlite ${profileDir}/stylish.rdf ${profileDir}/sessionmanager.dat ${profileDir}/sessionstore.bak ${profileDir}/sessionstore.js"
#	while ( ${?1} )
#	set backupCommand = "${backupCommand} ${1}"
#	shift
#end
set backupCommand = "tar -cjf ${backupTarball} bookmarks.html cookies.txt formhistory.dat history.dat persdict.dat search.sqlite stylish.rdf sessionmanager.dat sessionstore.bak sessionstore.js"

exec ${backupCommand}
