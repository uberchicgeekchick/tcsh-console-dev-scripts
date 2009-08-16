#!/bin/tcsh -f
set highlight
set histlit
set histdup=erase
set histfile="/projects/cli/tcshrc/history"
if( ! -e "${histfile}" ) touch "${histfile}";
set history=6000
set savehist=( $history "merge" )

if(!(${?loginsh})) then
	unalias logout;
	unalias exit;
	history -M;
	
	alias	"logout"	"if ( -e '${histfile}' ) cp '${histfile}' '${histfile}.bckcp'; if ( -e /etc/csh.logout ) source /etc/csh.logout ; if ( -e ~/.logout ) source ~/.logout ; exit";
endif

