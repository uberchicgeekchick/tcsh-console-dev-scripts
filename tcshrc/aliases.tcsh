#!/bin/tcsh -f
complete	alias	'p/1/c/' 'p/2,/c,f/'
setenv		GREP_OPTIONS	"--binary-files=without-match --color --with-filename --line-number"
alias		grep		"grep ${GREP_OPTIONS}"
alias		egrep		"grep ${GREP_OPTIONS} --perl-regexp -e"

setenv	LS_OPTIONS	"--human-readable --color --quoting-style=c --classify  --group-directories-first --format=across"

alias	ls	"ls ${LS_OPTIONS}"
alias	ll	"ls -l"
alias	l	"ll"
alias	lc	"ls --width=1 "
alias	la	"ls --all"
alias	lA	"ls --almost-all"
alias	dl	"ls --directory"
alias	dla

alias	df	"df --human-readable"
alias	du	"du --summarize --human-readable"
alias	du:dir	"du ./*"

alias	rr	"rm -r"
alias	rf	"rr -f"

alias pidof "pidof -x"
complete pidof 'p/*/c/'

#alias	cp	"cp --interactive"
unalias cp
#alias	mv	"mv --interactive"
unalias	mv

alias	mkdir	"mkdir -p"
alias	md	"mkdir"

alias	hostname	"hostname --fqdn"
alias	wget		"wget --no-check-certificate"
alias	shasum		"shasum --algorithm 512"

alias	screen-saver	"gnome-screensaver-command --activate &"
alias	unzip		"unzip -o -q"
alias	ispell		"aspell -a --sug-mode=normal"

