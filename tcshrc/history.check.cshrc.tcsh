if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
set scripts_basename="history.check.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
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
	alias "history:check" "source "\$"{TCSH_RC_SESSION_PATH}/${scripts_basename}";
	alias "history:refresh" "history-check";
	
	if(!( ${?histfile} && ${?my_histfile} )) then
		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh" ${argv};
	else if( "${histfile}" != "${my_history}" ) then
		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh" ${argv};
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
		printf "\t[finished]\n" > ${stdout};
		goto exit_script;
	endif
	
	printf "Merging this terminal's history with existing "\$"histfile: <file://%s>" "${histfile}" > ${stdout};
	history -M;
	printf "\t[finished]\nSaving merged and complete history's "\$"histfile: <file://%s>" "${histfile}" > ${stdout};
	history -S;
	printf "\t[finished]\n" > ${stdout};
	/bin/cp -fLpv "${histfile}" "${histfile}.bckcp";
#main:

exit_script:
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_basename}";
#exit_script:
