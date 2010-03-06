#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
set source_file="canvas.init.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${source_file}" ${argv};
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
	source "${TCSH_RC_SESSION_PATH}/../devel/make/compilers.environment" --reset;
else
	source "${TCSH_RC_SESSION_PATH}/../devel/make/compilers.environment";
endif


if(${?OSS_CANVAS}) unsetenv OSS_CANVAS

if(! ${?SSH_CONNECTION} ) printf "Setting up build shell @ %s\n\t[cwd: %s]\t" `date "+%I:%M:%S%P"` $cwd;
source "${TCSH_RC_SESSION_PATH}/../devel/make/build.tcsh";
if( ${?TCSH_RC_DEBUG} ) printf "[done]";

set source_file="canvas.init.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";
