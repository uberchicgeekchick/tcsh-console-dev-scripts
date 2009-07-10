#!/bin/tcsh -f

alias	"make:canvas"		"if(!(${?OSS_CANVAS})) setenv OSS_CANVAS; source /projects/cli/devel/make/init.tcsh"
alias	"make:compile"		"if(${?OSS_CANVAS}) unsetenv OSS_CANVAS; source /projects/cli/devel/make/init.tcsh"


if(!(${?OSS_CANVAS})) then
	printf "Setting up build shell.\n";
	source "/projects/cli/devel/make/build.tcsh";
else
	printf "Setting up artistic canvas.\n";
	source "/projects/cli/devel/make/artistic.tcsh";
endif

