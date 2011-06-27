#!/bin/tcsh -f
init:
	if(! ${?TCSH_RC_SESSION_PATH} ) \
		setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
	set scripts_basename="history.check.cshrc.tcsh";
	if( ${?0} ) then
		if( "`basename "\""${0}"\""`" == "${scripts_basename}" ) then
			if( ${?TCSH_OUTPUT_ENABLED} ) \
				printf "This script must be sourced and cannot be executed.\n" > ${stdout};
			unset scripts_basename;
			exit -1;
		endif
	endif
	
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
#goto init;


main:
	alias "history-check" "source "\$"{TCSH_RC_SESSION_PATH}/${scripts_basename}";
	alias "history-refresh" "history-check";
	
	if(! -e "${histfile}.lock" ) then
		if( ${?TCSH_OUTPUT_ENABLED} ) \
			printf "Creating history access lock: <file://%s.lock>.\n" "${histfile}" > ${stdout};
		touch "${histfile}.lock";
	endif
	#if(!( ${?histfile} && ${?my_histfile} )) then
	#	if( ${?TCSH_OUTPUT_ENABLED} ) \
	#	printf "Loading history: <file://%s>" "${histfile}" > ${stdout};
	#		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh" ${argv};
	#		history -L;
	#		if( ${?TCSH_OUTPUT_ENABLED} ) \
	#	printf "\t[finished]\n" > ${stdout};
	#		goto exit_script;
	#	else if( "${histfile}" != "${my_history}" ) then
	#		if( ${?TCSH_OUTPUT_ENABLED} ) \
	#			printf "Loading history: <file://%s>" "${histfile}" > ${stdout};
	#		source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh" ${argv};
	#		history -L;
	#		if( ${?TCSH_OUTPUT_ENABLED} ) \
	#			printf "\t[finished]\n" > ${stdout};
	#		goto exit_script;
	#	endif
	
	if(! -e "${histfile}" ) then
		if( -e "${histfile}.bckcp" ) then
			if( ${?TCSH_OUTPUT_ENABLED} ) \
				printf "Restoring: <file://%s> from back-up: <file://%s>" "${histfile}" "${histfile}.bckcp" > ${stdout};
			/bin/cp -fLp "${histfile}.bckcp" "${histfile}";
			if( ${?TCSH_OUTPUT_ENABLED} ) \
				printf "\t[finished]\n" > ${stdout};
			if( ${?TCSH_OUTPUT_ENABLED} ) \
				printf "Loading history: <file://%s>" "${histfile}" > ${stdout};
			history -L;
		else
			if( ${?TCSH_OUTPUT_ENABLED} ) \
				printf "Saving initial history to create "\$"histfile: <file://%s>" "${histfile}" > ${stdout};
			history -S;
			/bin/cp -fLp "${histfile}" "${histfile}.bckcp";
		endif
		if( ${?TCSH_OUTPUT_ENABLED} ) \
			printf "\t[finished]\n" > ${stdout};
		goto exit_script;
	endif
	
	if( ${?TCSH_OUTPUT_ENABLED} ) \
		printf "Merging this terminal's history with existing "\$"histfile: <file://%s>" "${histfile}" > ${stdout};
	history -M;
	if( ${?TCSH_OUTPUT_ENABLED} ) \
		printf "\t[finished]\nSaving merged and complete history's "\$"histfile: <file://%s>" "${histfile}" > ${stdout};
	history -S;
	if( ${?TCSH_OUTPUT_ENABLED} ) \
		printf "\t[finished]\nBacking up: <file://%s> to <file://%s>" "${histfile}" "${histfile}.bckcp" > ${stdout};
	/bin/cp -fLp "${histfile}" "${histfile}.bckcp";
	if( ${?TCSH_OUTPUT_ENABLED} ) \
		printf "\t[finished]\n" > ${stdout};
#main:

exit_script:
	if( -e "${histfile}.lock" ) then
		/bin/rm -f "${histfile}.lock";
		if( ${?TCSH_OUTPUT_ENABLED} ) \
			printf "Removing history access lock: <file://%s.lock>.\n" "${histfile}" > ${stdout};
	endif
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_basename}";
#exit_script:
