#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "logout.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

set status=0;
touch "${histfile}.lock";

source "${TCSH_RC_SESSION_PATH}/history.check.cshrc.tcsh" $argv;

if( -e "${histfile}.jobs" ) \
	/bin/rm -fv "${histfile}.jobs";

if( -e "${histfile}.lock" ) \
	/bin/rm -fv "${histfile}.lock";

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "logout.cshrc.tcsh";
exit ${status};
