#!/bin/tcsh -f
cd "/profile.d/~slash.";
set filelst=("linphonerc" "history");
foreach file ( ${filelst} )
	if( -e ${file} && -s ${file} ) cp ${file} backup/${file}
end

