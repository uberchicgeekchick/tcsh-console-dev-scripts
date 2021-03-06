#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "canvas.init.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;



if( "${1}" == "--reset" ) then
	source "${TCSH_CANVAS_PATH}/compilers.environment" --reset;
	source "${TCSH_CANVAS_PATH}/include-and-lib.paths-and-flags.init.tcsh";
else
	if(! ${?INCLUDE_AND_LIB_FLAGS_AND_PATHS} ) \
		source "${TCSH_CANVAS_PATH}/include-and-lib.paths-and-flags.init.tcsh";
	source "${TCSH_CANVAS_PATH}/compilers.environment";
endif



source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "canvas.init.tcsh";

