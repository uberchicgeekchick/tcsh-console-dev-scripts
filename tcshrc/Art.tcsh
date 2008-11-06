#!/bin/tcsh -f
alias blender "blender -p 80 80 1300 800"
alias cmake "cmake -Wno-dev"

alias	mysql	"mysql -u${USER} -p"
alias	mysqldump	"mysqldump -u${USER} -p"

bindkey	"^Z" run-fg-editor;
alias	vi	"vim-enhanced -p"
alias	vim	"vim-enhanced -p"

alias screen "/usr/bin/screen -aAURx"

setenv PATH "${PATH}:/projects/www/Alacast/bin:/projects/www/Alacast/bin/support/gpodder"
setenv PATH "${PATH}:/projects/gtk/GTK-PHP-IDE/bin:/projects/media/game-design/raydium/bin"


complete kill_program.tcsh "p/*/c/"
complete interupt_program.tcsh "p/*/c/"

if ( `mount | grep "/projects/ssh"` == "" ) sshfs dreams@avalon.ocssolutions.com:/home/dreams /projects/ssh

source /projects/console/helper-scripts/add:path.tcsh /projects/console
