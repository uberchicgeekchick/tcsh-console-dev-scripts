#!/bin/tcsh -f
if(${?OSS_CANVAS}) unsetenv OSS_CANVAS

printf "Setting up build shell\n\t[cwd: %s].\t" $cwd;
source "/projects/cli/devel/make/build.tcsh";
printf "[done]";

