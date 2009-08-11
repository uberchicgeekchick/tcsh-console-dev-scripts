#!/bin/tcsh -f
set histlit
set histdup=erase
set histfile="/projects/cli/tcshrc/history"
set history=3000
set savehist=( $history "merge" )

if(!(${?loginsh})) then
	unalias logout;
	unalias exit;
	if( ! ${?histfile} && -e "${HOME}/.history" ) set histfile="${HOME}/history";
	history -M;
	alias	"logout"	"if( -e /etc/csh.logout ) source /etc/csh.logout ; if( -e ~/.logout ) source ~/.logout ; exit";
endif

