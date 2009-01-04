#!/bin/tcsh -f
alias blender "blender -p 80 80 1400 800"
alias cmake "cmake -Wno-dev"

alias	mysql	"mysql --socket=/srv/mysql/mysql.sock -u${USER} -p"
alias	mysqldump	"mysqldump --databases --comment --no-autocommit --extended-insert --socket=/srv/mysql/mysql.sock -u${USER} -p"

bindkey	"^Z" run-fg-editor;
alias	vi	"vim-enhanced -p"
alias	vim	"vim-enhanced -p"

#alias	ex	"ex -s"

alias screen "/usr/bin/screen -aAURx"

setenv PATH "${PATH}:/programs/GTK-PHP-IDE/bin:/projects/games/engines/Raydium/raydium/bin"


complete kill_program.tcsh "p/*/c/"
complete interupt_program.tcsh "p/*/c/"

source /projects/console/tcsh-dev/helper-scripts/add:path.tcsh /projects/gtk/Alacast/bin

source /projects/console/tcsh-dev/helper-scripts/add:path.tcsh /projects/www/Alacast/bin
source /projects/console/tcsh-dev/helper-scripts/add:path.tcsh /projects/console/tcsh-dev
