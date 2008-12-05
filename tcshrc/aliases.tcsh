#!/bin/tcsh -f
alias grep "/usr/bin/grep --color --perl-regexp --with-filename --line-number"

alias	ls	"ls --human-readable --color --quoting-style=escape"
alias	l	"ls --human-readable --color --quoting-style=escape --long"
alias	ll	"ls --human-readable --color --quoting-style=escape --long"
alias	la	"ls --human-readable --color --quoting-style=escape --all"
alias	lA	"ls --human-readable --color --quoting-style=escape --almost-all"

alias	df	"df --human-readable"
alias	du	"du --summarize --human-readable"
#alias	cp	"cp --interactive"
unalias cp
#alias	mv	"mv --interactive"
unalias mv

alias	hostname	"hostname --fqdn"
alias	"wget"	"wget --no-check-certificate"
