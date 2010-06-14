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

main:
	set my_history="/profile.d/history";
	if(! ${?histfile} ) then
		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh";
	else if( "${histfile}" != "${my_history}" ) then
		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh";
	endif
	
	if(! -e "${histfile}" ) then
		if( -e "${histfile}.bckcp" ) then
			/bin/cp -ufv "${histfile}.bckcp" "${histfile}";
			history -L;
		else
			history -S;
		endif
		goto exit_script;
	endif
	
	history -M;
	history -S;
	/bin/cp -ufv "${histfile}" "${histfile}.bckcp";
#main:

exit_script:
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "history.check.cshrc.tcsh";
#exit_script:
