#!/bin/tcsh -f
source /projects/cli/tcshrc/debug:check paths.tcsh ${argv};
if( ${?TCSHRC_DEBUG} ) printf "Setting up PATH environmental variable.\n";
if( ! ${?TCSH_SESSION_RC_PATH} ) setenv TCSH_SESSION_RC_PATH "/projects/cli/tcshrc";

if( ${?PATH} ) unsetenv PATH;

setenv PATH ".:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d";
source /projects/cli/tcshrc/source:argv art:alacast.tcsh art:paths.tcsh paths:lib.tcsh paths:lib64.tcsh paths:programs.tcsh;
if( ${?TCSHRC_DEBUG} ) printf "PATH setup complete.\n";
source /projects/cli/tcshrc/debug:clean-up paths.tcsh;
