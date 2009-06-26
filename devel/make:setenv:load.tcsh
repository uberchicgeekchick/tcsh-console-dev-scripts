#!/bin/tcsh -f

alias "canvas:programming" "if(${?MAKE_BASIC}) unsetenv MAKE_BASIC ; source /projects/cli/tcshrc/make:setenv:load.tcsh"

alias "canvas:compiling" "if(!(${?MAKE_BASIC})) setenv MAKE_BASIC ; source /projects/cli/tcshrc/make:setenv:load.tcsh"


if(!(${?MAKE_BASIC})) then
	source "/projects/cli/tcshrc/make:setenv:full.tcsh";
else
	source "/projects/cli/tcshrc/make:setenv:basic.tcsh";
endif

