#!/bin/tcsh -f
set test="`printf "\""%s"\"" "\""$argv[1]"\""`"# | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
printf "%s\n" "${test}";

