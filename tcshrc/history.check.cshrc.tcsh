#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "history.check.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

set my_history="/profile.d/history";
if(! ${?histfile} ) \
	goto exit_script;

main:
	if( "${histfile}" != "${my_history}" ) \
		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh";
		history -M;
		history -S;
		cp -u -v "${histfile}" "${histfile}.bckcp";
		goto exit_script;
	endif

	if(! -e "${histfile}" ) then
		if( -e "${histfile}.bckcp" ) then
			cp -u -v "${histfile}.bckcp" "${histfile}";
			history -L;
		endif
	else
		history -M;
		history -S;
		cp -u -v "${histfile}" "${histfile}.bckcp";
	endif
#main:

exit_script:
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "history.check.cshrc.tcsh";
#exit_script:
