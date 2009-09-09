#!/bin/tcsh -f
source /projects/cli/tcshrc/debug:check canvas.init.tcsh ${argv};
if(${?OSS_CANVAS}) unsetenv OSS_CANVAS

if( ${?TCSHRC_DEBUG} ) printf "Setting up build shell @ %s\n\t[cwd: %s]\t" `date "+%I:%M:%S%P"` $cwd;
source "/projects/cli/devel/make/build.tcsh";
if( ${?TCSHRC_DEBUG} ) printf "[done]";

