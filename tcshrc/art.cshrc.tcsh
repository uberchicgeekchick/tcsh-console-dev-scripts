#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
set source_file="art.cshrc.tcsh";
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

if(! ${?echo_style} ) then
	set echo_style=sysv;
else if( "${echo_style}" != "sysv" ) then
	set echo_style=sysv;
endif

if(! ${?eol} ) setenv eol '$';
#if(! ${?eol} ) setenv eol '"\$"';

source "${TCSH_RC_SESSION_PATH}/art:color.cshrc.tcsh";

#setenv	GREP_OPTIONS	"--binary-files=without-match --color --with-filename --line-number --ignore-case --initial-tab";
setenv	GREP_OPTIONS	"--binary-files=without-match --color --with-filename --line-number --initial-tab";
alias	grep		"grep ${GREP_OPTIONS}";
alias	egrep		"grep ${GREP_OPTIONS} --perl-regexp";
unsetenv GREP_OPTIONS

alias	cmake	"cmake -Wno-dev";
alias	sqlite	"sqlite3";

alias	mysql	"mysql --socket=/srv/mysql/mysql.sock -u${USER} -p";
alias	mysqldump	"mysqldump --databases --comment --no-autocommit --extended-insert --socket=/srv/mysql/mysql.sock -u${USER} -p";

complete kill_program.tcsh "p/*/c/";
complete interupt_program.tcsh "p/*/c/";

setenv	BONOBO_ACTIVATION_PATH	"/usr/lib64/bonobo/servers";

setenv	SCREENRC	"/profile.d/~slash./screenrc";
setenv	TERMCAP		"/profile.d/~slash./screens.termcap"

alias	rsed		"sed --regexp-extended";

if(! ${?source_file} ) set source_file="art.cshrc.tcsh";
if( "${source_file}" != "art.cshrc.tcsh" ) set source_file="art.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";
