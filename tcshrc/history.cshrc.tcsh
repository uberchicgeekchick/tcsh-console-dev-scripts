#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/tcshrc";
set source_file="history.cshrc.tcsh";
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


if(! ${?eol} ) setenv eol '$';
if(! ${?exec} ) setenv exec '`';
set highlight;
set histlit;
set histdup=erase;
set histfile="/profile.d/history";
if( ! -e "${histfile}" ) touch "${histfile}";
set history=6000;
set savehist=( $history "merge" );

if(!(${?loginsh})) then
	unalias logout;
	unalias exit;
	history -M;
	
	alias	logout	"if( "\""${exec}jobs${exec}"\"" == "\"""\"" ) then \
		source '$TCSH_RC_SESSION_PATH/etc-csh.logout'; \
			if( "\""${eol}{status}"\"" == "\""0"\"" ) exit; \
		endif;";
endif

