#!/bin/tcsh -f
alias grep "/usr/bin/grep --color --perl-regexp --with-filename --line-number"

setenv LS_OPTIONS "--human-readable --color --quoting-style=escape --classify"

alias	ls	"ls ${LS_OPTIONS}"
alias	ll	"ls -l"
alias	l	"ll"
alias	lt	"ls --width=1"
alias	la	"ls -A"


alias	df	"df --human-readable"
alias	du	"du --summarize --human-readable"
alias	cwddu	"du ./*"

#alias	cp	"cp --interactive"
unalias cp
#alias	mv	"mv --interactive"
unalias mv

alias mkdir "mkdir -p"
alias md "mkdir"

alias	hostname	"hostname --fqdn"
alias	"wget"		"wget --no-check-certificate"
alias	"screen-sever"	"gnome-screensaver-command --activate &"
