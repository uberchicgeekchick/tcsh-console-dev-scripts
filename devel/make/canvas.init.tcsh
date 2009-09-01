#!/bin/tcsh -f
if( ! ${?SSH_CONNECTION} && ${?1} && "${1}" != "" && "${1}" == "--debug" ) setenv TCSHRC_DEBUG;
if(${?OSS_CANVAS}) unsetenv OSS_CANVAS

if( ${?TCSHRC_DEBUG} ) printf "Setting up build shell @ %s\n\t[cwd: %s]\t" `date "+%I:%M:%S%P"` $cwd;
source "/projects/cli/devel/make/build.tcsh";
if( ${?TCSHRC_DEBUG} ) printf "[done]";

