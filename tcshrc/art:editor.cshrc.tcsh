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
#alias vim-enhanced "vim-enhanced -X -p";
alias vim-enhanced "vim-enhanced --servername "\`"hostname --fqdn | sed -r 's/(.*)/\U\1/g'"\`" -X --remote-tab-silent";
alias vim-remote "set vim_server="\`"/usr/bin/vim-enhanced --serverlist"\`"; if( "\"""\$"vim_server"\"" == "\"""\"" ) set vim_server="\`"hostname --fqdn | sed -r 's/(.*)/\U\1/g'"\`"; /usr/bin/vim-enhanced --servername "\$"vim_server -X --remote-tab-silent";
alias vi-remote "vim-remote";
alias rvim "vim-remote";
alias rvi "vim-remote";
alias rvi "vim-remote";
alias vim-connect "vim-remote"
alias vi-connect "vim-remote"
alias vim-enhanced "vim-connect";
alias vim-enhanced "vim-enhanced -X -p";
alias vim "vim-enhanced";
alias lvim "vim-enhanced -c 'normal '\''0'"
alias vi "vim-enhanced";
alias v "vi";
alias ex "ex -E -n --noplugin -X";
setenv EDITOR "vim-enhanced";
bindkey "^Z" run-fg-editor;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art:editor.cshrc.tcsh";

