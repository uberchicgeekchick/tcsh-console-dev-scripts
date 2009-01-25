#!/bin/tcsh -f
alias grep "/usr/bin/grep --binary-files=without-match --color --with-filename --line-number --perl-regexp"

setenv LS_OPTIONS "--human-readable --color --quoting-style=escape --classify"

alias	ls	"ls ${LS_OPTIONS}"
alias	ll	"ls -l"
alias	l	"ll"
alias	lt	"ls --width=1"
alias	la	"ls -A"


alias	df	"df --human-readable"
alias	du	"du --summarize --human-readable"
alias	du:dir	"du ./*"

alias	shasum		"shasum --algorithm 512"

#alias	cp	"cp --interactive"
unalias cp
#alias	mv	"mv --interactive"
unalias mv

alias mkdir "mkdir -p"
alias md "mkdir"

alias	mkexec	"chmod +x"

alias	hostname	"hostname --fqdn"
alias	"wget"		"wget --no-check-certificate"
alias	"screen-sever"	"gnome-screensaver-command --activate &"
