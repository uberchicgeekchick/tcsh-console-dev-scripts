#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "art.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

source ${TCSH_RC_SESSION_PATH}/source:argv "${TCSH_RC_SESSION_PATH}/art:color.cshrc.tcsh" "${TCSH_RC_SESSION_PATH}/art:devel:make:init.cshrc.tcsh" "${TCSH_RC_SESSION_PATH}/art:editor.cshrc.tcsh" "art:grep-and-find.cshrc.tcsh";


alias cmake "cmake -Wno-dev";
alias sqlite "sqlite3";

alias mysql "mysql --socket=/srv/mysql/mysql.sock -u${USER} -p";
alias mysqldump "mysqldump --databases --comment --no-autocommit --extended-insert --socket=/srv/mysql/mysql.sock -u${USER} -p";

complete kill_program.tcsh "p/*/c/";
complete interupt_program.tcsh "p/*/c/";

setenv	BONOBO_ACTIVATION_PATH	"/usr/lib64/bonobo/servers";

setenv	SCREENRC	"/profile.d/~slash./screenrc";
setenv	TERMCAP		"/profile.d/~slash./screens.termcap"

alias rsed "sed -r";

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art.cshrc.tcsh";
