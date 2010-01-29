#!/bin/tcsh -f
set source_file="art:paths.cshrc.tcsh";
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${source_file}" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled source_file;


source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" "${TCSH_RC_SESSION_PATH}/../" "--sub-directory-name-restriction=bin" "/projects/games/engines/raydium/bin" "--sub-directory-name-restriction=bin" "/projects/games/tools/servers/opensim/bin";
#source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" --sub-directory-name-restriction=bin /projects/games/engines/raydium/bin --sub-directory-name-restriction=bin /projects/games/tools/servers/opensim/bin;
#setenv PATH "${PATH}:/projects/games/engines/raydium/bin:/projects/games/tools/opensim/bin";


if(! ${?source_file} ) set source_file="art:paths.cshrc.tcsh";
if( "${source_file}" != "art;paths.cshrc.tcsh" ) set source_file="art:paths.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";

