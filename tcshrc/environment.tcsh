#!/tcsh/bin -f
source /projects/cli/tcshrc/debug:check environment.tcsh ${argv};
#print the expanded, completed, & corrected command line after is entered but before its executed.
#set echo
set addsuffix

setenv eol '$';

setenv	LS_OPTIONS	"--human-readable --color --quoting-style=c --classify  --group-directories-first --format=vertical"

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

#set fignore=(.o \~)
set listflags=( "xa" "ls ${LS_OPTIONS}" )
set listlinks
set listmaxrows=23

# special alias which it ran when 'M-h' or 'M-H' is pressed at the command line
# this command is ran with the current buffer command as its only agument.
#alias	helpcommand	"info"
alias	helpcommand	"man"

unset autologout
unset ignoreeof

if( ! ${?TCSH_SESSION_RC_PATH} ) setenv TCSH_SESSION_RC_PATH "/projects/cli/tcshrc";

if( ${?TCSHRC_DEBUG} ) printf "Setting up TCSH history environment @ %s.\n" `date "+%I:%M:%S%P"`;
source /projects/cli/tcshrc/history.tcsh
if( ${?TCSHRC_DEBUG} ) printf "TCSH environment setup completed @ %s.\n" `date "+%I:%M:%S%P"`;

source /projects/cli/tcshrc/debug:clean-up environment.tcsh;
