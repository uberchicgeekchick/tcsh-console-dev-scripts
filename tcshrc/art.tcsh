#!/bin/tcsh -f
setenv	GREP_OPTIONS	"--binary-files=without-match --color --with-filename --line-number --ignore-case";
alias	grep		"grep ${GREP_OPTIONS}";
alias	egrep		"grep ${GREP_OPTIONS} --perl-regexp";

alias	cmake	"cmake -Wno-dev";
alias	sqlite	"sqlite3";

alias	mysql	"mysql --socket=/srv/mysql/mysql.sock -u${USER} -p";
alias	mysqldump	"mysqldump --databases --comment --no-autocommit --extended-insert --socket=/srv/mysql/mysql.sock -u${USER} -p";

bindkey	"^Z" run-fg-editor;
alias	vi	"vim-enhanced -p";
alias	vim	"vim-enhanced -p";

complete kill_program.tcsh "p/*/c/";
complete interupt_program.tcsh "p/*/c/";

source /projects/cli/setenv/PATH:recursively:add.tcsh /projects/gtk/alacast/scripts;
source /projects/cli/setenv/PATH:recursively:add.tcsh /projects/cli;

alias	ex	"ex -E";

setenv	BONOBO_ACTIVATION_PATH	"/usr/lib64/bonobo/servers";

setenv PATH "${PATH}:/bin:/projects/games/engines/Raydium/raydium/bin";

setenv OSS_CANVAS;
source /projects/cli/devel/make/init.tcsh;

source /projects/cli/launchers/init.tcsh;

alias	sed		"sed --regexp-extended";


