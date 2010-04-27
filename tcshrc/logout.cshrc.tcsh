#!/bin/tcsh -f

set status=0;
touch "${histfile}.lock";

if(! -e "${histfile}" ) then
	if( -e "${histfile}.bckcp" ) \
		cp -u -v "${histfile}.bckcp" "${histfile}";
else
	cp -u -v "${histfile}" "${histfile}.bckcp";
endif

history -M;
history -S;

rm -fv "${histfile}.lock";

exit ${status};
