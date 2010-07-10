if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "art:paths.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;


source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" "${TCSH_RC_SESSION_PATH}/../" --no-other-fs -maxdepth=1 -f=bin "/art/games/engines/raydium/bin" --no-other-fs -maxdepth=1 -f=bin "/art/games/tools/servers/opensim/bin" --no-follow --no-other-fs -maxdepth=1 -f=bin "${HOME}";


source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art:paths.cshrc.tcsh";

