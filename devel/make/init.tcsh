#!/bin/tcsh -f
if( (! ${?TCSHRC_DEBUG} ) && ${?1} && "${1}" != "" && "${1}" == "--debug" ) setenv TCSHRC_DEBUG;

alias	"make:canvas"		"if(!(${?OSS_CANVAS})) setenv OSS_CANVAS; source /projects/cli/devel/make/init.tcsh"
alias	"make:compile"		"if(${?OSS_CANVAS}) unsetenv OSS_CANVAS; source /projects/cli/devel/make/init.tcsh"


if ( -e "./canvas.init.tcsh" ) then
	if( ${?TCSHRC_DEBUG} ) printf "Setting up custom make environment.\n";
	source "./canvas.init.tcsh";
else if( !(${?OSS_CANVAS}) || -e "./.build.init.tcsh" || -e "../.build.init.tcsh" ) then
	if( ${?TCSHRC_DEBUG} ) printf "Setting up program build environment.\n";
	source "/projects/cli/devel/make/build.tcsh";
else
	if( ${?TCSHRC_DEBUG} ) printf "Setting up artistic canvas.\n";
	source "/projects/cli/devel/make/artistic.tcsh";
endif

