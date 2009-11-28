#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "paths.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

if( ${?TCSHRC_DEBUG} ) printf "Setting up PATH environmental variable.\n";

if( ${?PATH} ) unsetenv PATH;

setenv PATH ".:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d";
source /projects/cli/tcshrc/source:argv art:alacast.cshrc.tcsh art:paths.cshrc.tcsh paths:lib.cshrc.tcsh paths:lib64.cshrc.tcsh paths:programs.cshrc.tcsh;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "paths.cshrc.tcsh";
