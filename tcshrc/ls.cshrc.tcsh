#!/bin/tcsh -f
if( -x /usr/bin/dircolors ) then
    if( -r $HOME/.dir_colors ) then
	eval `/usr/bin/dircolors -c $HOME/.dir_colors`;
    else if( -r /etc/DIR_COLORS ) then
	eval `/usr/bin/dircolors -c /etc/DIR_COLORS`;
    endif
endif
setenv LS_OPTIONS '--color=always';
if( ${?LS_COLORS} ) then
    if( "${LS_COLORS}" == "" ) setenv LS_OPTIONS '--color=always';
endif
unalias ls;
if( "$uid" == "0" ) then
    setenv LS_OPTIONS "-A -N $LS_OPTIONS -T 0";
else
    setenv LS_OPTIONS "-N $LS_OPTIONS -T 0";
endif
setenv	LS_OPTIONS	"${LS_OPTIONS} --human-readable --quoting-style=c --classify  --group-directories-first --format=vertical --time-style='+%Y-%m-%d %H:%m:%S %Z(%:z)'";

set listflags=("xA" "${LS_OPTIONS}");
alias	ls	"ls-F";
alias	ls	"ls $LS_OPTIONS";
alias	ll	"ls -l";
alias	l	"ll";
alias	lc	"ls --width=1 ";
alias	la	"ls --all";
alias	lA	"ls --almost-all";
alias	lD	"ls -l --directory";
alias	lDa	"lD --all";
alias	lDA	"lD --almost-all";
alias	dir	'ls --format=vertical';
alias	vdir	'ls --format=long';
alias	d	dir;
alias	v	vdir;

