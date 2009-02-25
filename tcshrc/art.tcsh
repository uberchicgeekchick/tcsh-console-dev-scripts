#!/bin/tcsh -f
alias blender "blender -p 80 80 1400 800"

alias	cmake	"cmake -Wno-dev"
alias	sqlite	"sqlite3"

alias	mysql	"mysql --socket=/srv/mysql/mysql.sock -u${USER} -p"
alias	mysqldump	"mysqldump --databases --comment --no-autocommit --extended-insert --socket=/srv/mysql/mysql.sock -u${USER} -p"

bindkey	"^Z" run-fg-editor;
alias	vi	"vim-enhanced -p"
alias	vim	"vim-enhanced -p"

alias	exs	"ex -s"

alias screen "/usr/bin/screen -aAURx"

setenv PATH "${PATH}:/programs/connectED/bin:/bin:/projects/games/engines/Raydium/raydium/bin"


complete kill_program.tcsh "p/*/c/"
complete interupt_program.tcsh "p/*/c/"

source /projects/cli/tcsh-dev/setenv/PATH:recursively:add.tcsh /projects/gtk/alacast/bin

source /projects/cli/tcsh-dev/setenv/PATH:recursively:add.tcsh /projects/cli/alacast/bin
source /projects/cli/tcsh-dev/setenv/PATH:recursively:add.tcsh /projects/cli/tcsh-dev

