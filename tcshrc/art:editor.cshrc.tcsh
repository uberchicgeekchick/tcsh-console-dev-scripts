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
	printf "Setting EDITOR as VIM & setting up options, aliases, and advanced bindings @ %s.\n" `date "+%I:%M:%S%P"`;

if(! ${?CSHEDIT} ) then
	setenv CSHEDIT "vi";
else if( "${CSHEDIT}" != "vi" ) then
	setenv CSHEDIT "vi";
endif


#alias vim-enhanced "vim-enhanced --noplugin -X -p";
alias vim-enhanced "vim-enhanced -X -p";
alias vim "vim-enhanced";
alias lvim "vim-enhanced -c 'normal '\''0'"
alias vi "vim-enhanced";
alias v "vi";

alias ex "ex -E -n --noplugin -X";

setenv EDITOR "vim-enhanced";
bindkey "^Z" run-fg-editor;

#alias vim-sever 'set vim_server=`vim-enhanced --serverlist`; if( "${vim_server}" == "" ) set vim_server=`hostname --fqdn`; vim-enhanced --servername $vim_server -X --remote-tab-silent';
alias vim-remote "vim-server";
alias vi-remote "vim-server";
alias rvim "vim-server";
alias rvi "vim-server";
alias rvi "vim-server";
alias vim-connect "vim-server"
alias vi-connect "vim-server"

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art:editor.cshrc.tcsh";

