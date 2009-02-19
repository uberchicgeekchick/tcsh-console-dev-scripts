#!/bin/tcsh -f
setenv		GREP_OPTIONS	"--binary-files=without-match --color --with-filename --line-number"
alias		grep		"grep ${GREP_OPTIONS}"
alias		egrep		"grep ${GREP_OPTIONS} --perl-regexp -e"
unsetenv	GREP_OPTIONS

setenv	LS_OPTIONS	"--human-readable --color --quoting-style=c --classify  --group-directories-first --format=across"

alias	ls	"ls ${LS_OPTIONS}"
alias	ll	"ls -l"
alias	l	"ll"
alias	lt	"ls --width=1"
alias	la	"ls -a"
set	listflags=( "xa" "ls ${LS_OPTIONS}" )
set listlinks

alias	df	"df --human-readable"
alias	du	"du --summarize --human-readable"
alias	du:dir	"du ./*"

alias	rr	"rm -r"
alias	rf	"rr -f"

alias	shasum		"shasum --algorithm 512"

#alias	cp	"cp --interactive"
unalias cp
#alias	mv	"mv --interactive"
unalias	mv

alias	mkdir	"mkdir -p"
alias	md	"mkdir"

alias	hostname	"hostname --fqdn"
alias	wget		"wget --no-check-certificate"
alias	screen-saver	"gnome-screensaver-command --activate &"

