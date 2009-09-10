#!/bin/tcsh -f
source /projects/cli/tcshrc/debug:check paths.tcsh ${argv};
if( ! ${?TCSH_SESSION_PATH_SET} ) then
	setenv TCSH_SESSION_PATH_SET;
	if( ${?TCSHRC_DEBUG} ) printf "Setting up PATH environmental variable.\n";
	if( ! ${?TCSH_SESSION_RC_PATH} ) setenv TCSH_SESSION_RC_PATH "/projects/cli/tcshrc";
	
	if( ${?PATH} ) unsetenv PATH;
	
	setenv PATH ".:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d";
	source /projects/cli/tcshrc/source:argv art:alacast.tcsh art:paths.tcsh paths:lib.tcsh paths:lib64.tcsh paths:programs.tcsh;
endif
if( ${?TCSHRC_DEBUG} ) printf "PATH setup complete.\n";
unset paths_sources path_source_file;
source /projects/cli/tcshrc/debug:clean-up paths.tcsh;
