#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
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
unset args_handled;


if(! ${?eol} ) setenv eol '$';
#if(! ${?eol} ) setenv eol '"\$"';
set highlight;
set histlit;
set histdup=erase;
set histfile="/profile.d/history";
if(! -e "${histfile}" ) then
	if( -e "${histfile}.bckcp" ) cp "${histfile}.bckcp" "${histfile}";
endif
if( -e "${histfile}.jobs" ) /bin/rm -f "${histfile}.jobs";
if( -e "${histfile}.lock" ) /bin/rm -f "${histfile}.lock";
set history=6000;
set savehist=( $history "merge" );

if( ${?history_skip_merge} ) goto exit_script;

history -M;

if( ${?loginsh} ) goto exit_script;

unalias logout;
unalias exit;

alias	logout	'source "${TCSH_RC_SESSION_PATH}/etc-csh.logout"; \
		if( ${status} == 0 ) exit;';

exit_script:
	if(! ${?source_file} ) set source_file="history.cshrc.tcsh";
	if( "${source_file}" != "history.cshrc.tcsh" ) set source_file="history.cshrc.tcsh";
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";

