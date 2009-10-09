#!/bin/tcsh -f

source /projects/cli/tcshrc/debug:check art.tcsh ${argv};

if( ! ${?TCSH_SESSION_RC_PATH} ) setenv TCSH_SESSION_RC_PATH "/projects/cli/tcshrc";

if(! ${?eol} ) setenv eol '$';
setenv color_start `cat ${TCSH_SESSION_RC_PATH}/art.color`;
if( ${?TCSHRC_DEBUG} ) printf "${color_start}00;31mSetting ${eol}color_start environmental variable${color_start}00m\n";


setenv	GREP_OPTIONS	"--binary-files=without-match --color --with-filename --line-number --ignore-case --initial-tab";
alias	grep		"grep ${GREP_OPTIONS}";
alias	egrep		"grep ${GREP_OPTIONS} --perl-regexp";

alias	cmake	"cmake -Wno-dev";
alias	sqlite	"sqlite3";

alias	mysql	"mysql --socket=/srv/mysql/mysql.sock -u${USER} -p";
alias	mysqldump	"mysqldump --databases --comment --no-autocommit --extended-insert --socket=/srv/mysql/mysql.sock -u${USER} -p";

complete kill_program.tcsh "p/*/c/";
complete interupt_program.tcsh "p/*/c/";

setenv	BONOBO_ACTIVATION_PATH	"/usr/lib64/bonobo/servers";

setenv	SCREENRC	"/profile.d/~slash./screenrc";

alias	regex		"sed --regexp-extended";

source /projects/cli/tcshrc/debug:clean-up art.tcsh
