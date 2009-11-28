#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/tcshrc";
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

if(! ${?eol} ) setenv eol '$';
setenv color_start `cat ${TCSH_RC_SESSION_PATH}/art.color`;
if( ${?TCSHRC_DEBUG} ) printf "${color_start}00;31mSetting ${eol}color_start environmental variable${color_start}00m\n";


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

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art.cshrc.tcsh";
