#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "art:editor.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;
if( ${?TCSH_RC_DEBUG} ) \
	printf "Setting up EDITOR as VIM & advanced bindings @ %s.\n" `date "+%I:%M:%S%P"`;

if( ${?CSHEDIT} ) then
	if( ${CSHEDIT} != "vi" ) \
		unsetenv CSHEDIT;
endif
if(! ${?CSHEDIT} ) \
	setenv CSHEDIT "vi";

#alias vim-enhanced "vim-enhanced --noplugin -X -p";
alias vim-enhanced "vim-enhanced -X -p";
alias vim-deamon "vim-enhanced --servername='`hostname --fqdn`'";
alias vim "vim-enhanced";
alias lvim "vim-enhanced -c 'normal '\''0'"
alias vi "vim-enhanced";
alias ex "ex -E -n --noplugin -X";
setenv	EDITOR		"vim-enhanced";
bindkey	"^Z"		run-fg-editor;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art:editor.cshrc.tcsh";

