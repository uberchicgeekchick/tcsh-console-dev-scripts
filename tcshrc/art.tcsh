#!/bin/tcsh -f
alias blender "blender -p 80 80 1400 800"

alias	cmake	"cmake -Wno-dev"
alias	sqlite	"sqlite3"

alias	mysql	"mysql --socket=/srv/mysql/mysql.sock -u${USER} -p"
alias	mysqldump	"mysqldump --databases --comment --no-autocommit --extended-insert --socket=/srv/mysql/mysql.sock -u${USER} -p"

bindkey	"^Z" run-fg-editor;
alias	vi	"vim-enhanced -p"
alias	vim	"vim-enhanced -p"

complete kill_program.tcsh "p/*/c/"
complete interupt_program.tcsh "p/*/c/"

source /projects/cli/setenv/PATH:recursively:add.tcsh /projects/gtk/alacast/scripts
source /projects/cli/setenv/PATH:recursively:add.tcsh /projects/cli

alias	ex	"/projects/cli/helpers/ex:silent"
alias	screen	"/projects/cli/helpers/screen:attach"

setenv	BONOBO_ACTIVATION_PATH	"/usr/lib64/bonobo/servers"

setenv OSS_CANVAS
setenv PATH "${PATH}:/programs/connectED/bin:/bin:/projects/games/engines/Raydium/raydium/bin"
if ( -e "./.canvas.init.csh" ) then
	source "./.canvas.init.csh";
else
	source /projects/cli/devel/make/init.tcsh
endif
source /projects/cli/launchers/init.tcsh

