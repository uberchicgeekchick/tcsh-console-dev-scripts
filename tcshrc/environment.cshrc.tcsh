#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "environment.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

#print the expanded, completed, & corrected command line after is entered but before its executed.
#set echo
set addsuffix

setenv	LS_OPTIONS	"--human-readable --color --quoting-style=c --classify --group-directories-first --format=vertical"

#set correct=all
set correct=cmd
set autoexpand
set autocorrect
set autolist=ambiguous
set color
set colorcat

set dextract
set dunique

set listjobs=long
set notify
#set notify=1s

alias ssshh 'set nobeep'
set nobeep
set noclobber

#set printexitvalue

set nostat=( /afs )
set showdots=1
set symlinks=ignore

set killdup=erase

set rmstar

# special alias which it ran when 'M-h' or 'M-H' is pressed at the command line
# this command is ran with the current buffer command as its only agument.
#alias helpcommand "whatis"
#alias helpcommand "info"
#alias helpcommand links http://google.com/search\?q=
alias helpcommand "man"

unset autologout
unset ignoreeof

if( ${?TCSH_RC_DEBUG} ) \
	printf "Setting up TCSH's history @ %s.\n" `date "+%I:%M:%S%P"`;
source "${TCSH_RC_SESSION_PATH}/history.cshrc.tcsh";

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "environment.cshrc.tcsh";

