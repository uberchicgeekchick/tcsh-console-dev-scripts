#!/bin/tcsh -f
if(${?OSS_CANVAS}) unsetenv OSS_CANVAS

if( ${?TCSHRC_DEBUG} ) printf "Setting up build shell\n\t[cwd: %s].\t" $cwd;
source "/projects/cli/devel/make/build.tcsh";
if( ${?TCSHRC_DEBUG} ) printf "[done]";

