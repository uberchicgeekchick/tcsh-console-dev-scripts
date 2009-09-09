#!/bin/tcsh -f
set highlight
set histlit
set histdup=erase
set histfile="/profile.d/history"
if( ! -e "${histfile}" ) touch "${histfile}";
set history=6000
set savehist=( $history "merge" )

if(!(${?loginsh})) then
	unalias logout;
	unalias exit;
	history -M;
	
	alias	"logout"	"if( ${?histfile} && -e '${histfile}' ) cp -u -v '${histfile}' '${histfile}.bckcp'; history -M; history -S; exit;";
endif

