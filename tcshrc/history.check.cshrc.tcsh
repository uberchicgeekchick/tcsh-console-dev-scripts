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
	if(!( ${?histfile} && ${?my_histfile} )) then
		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh" $argv;
	else if( "${histfile}" != "${my_history}" ) then
		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh" $argv;
	endif
	
	if(! -e "${histfile}" ) then
		if( -e "${histfile}.bckcp" ) then
			/bin/cp -ufv "${histfile}.bckcp" "${histfile}";
			printf "Loading history from back-up" > ${stdout};
			history -L;
		else
			printf "Saving initial history to create "\$"histfile: <file://%s>" "${histfile}" > ${stdout};
			history -S;
		endif
		printf "\t[done]\n" > ${stdout};
		goto exit_script;
	endif
	
	printf "Merging this terminal's history with existing "\$"histfile: <file://%s>" "${histfile}" > ${stdout};
	history -M;
	printf "\t[done]\nSaving merged and complete history: "\$"histfile: <file://%s>" "${histfile}" > ${stdout};
	history -S;
	printf "\t[done]\n" > ${stdout};
	/bin/cp -ufv "${histfile}" "${histfile}.bckcp";
#main:

exit_script:
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "history.check.cshrc.tcsh";
#exit_script:
