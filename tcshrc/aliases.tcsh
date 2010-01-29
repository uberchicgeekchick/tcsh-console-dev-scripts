#!/bin/tcsh -f
#alias	alias	"/projects/cli/console.pallet/tcshrc/alias.launcher";


complete	alias	'p/1/c/' 'p/2,/c,f/';

alias	ps	"/bin/ps -A -c -F --forest --heading";
alias	ps-g	"/bin/ps -A -c -F --forest --heading | egrep";

alias	ln	"ln --interactive";

alias	df	"df --human-readable";
alias	du	"du --summarize --human-readable";
alias	du-a	"du ./*";

alias	rd	rmdir;

alias	rm	"rm --verbose";
alias	rr	"rm --recursive";
alias	rf	"/bin/rm --recursive --force";
alias	rmf	"rr --force";

alias		pidof	"pidof -x";
complete	pidof	'p/*/c/';

#alias	cp	"cp --dereference --recursive --verbose --interactive";
alias	cp	"cp --dereference --recursive --verbose";
#alias	mv	"mv --interactive --verbose";
alias	mv	"mv --verbose";

alias	mkdir	"mkdir -p";
alias	md	"mkdir";

alias	nautilus	"nautilus --geometry=800x700 --no-desktop --browser";

alias	hostname	"hostname --fqdn";
alias	wget		"wget --no-check-certificate";
alias	shasum		"shasum --algorithm 512";

alias	screen-saver	"gnome-screensaver-command --activate &";
alias	unzip		"unzip -o -q";
alias	ispell		"aspell -a --sug-mode=normal";

alias	alsamixer	"alsamixer -V all";
