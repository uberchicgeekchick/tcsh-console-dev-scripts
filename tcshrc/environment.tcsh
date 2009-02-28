#!/tcsh/bin -f
#print the expanded, completed, & corrected command line after is entered but before its executed.
#set echo
set addsuffix

set correct=cmd
set autoexpand
set autocorrect
set autolist
set color
set colorcat

set dextract
set dunique

set listjobs=long
set notify
#set notify=1s

set nobeep
set noclobber

set highlight
set histdup=erase
set histfile="/profile.d/history"
set history=1000
set savehist=( $history "merge" )
set histlit

#set printexitvalue

set nostat=( /afs )
set showdots=1
set symlinks=ignore

set killdup=erase

set implicitcd
set rmstar

#set fignore=(.o \~)
set listflags=( "xa" "ls ${LS_OPTIONS}" )
set listlinks
set listmaxrows=23

# special alias which it ran when 'M-h' or 'M-H' is pressed at the command line
# this command is ran with the current buffer command as its only agument.
alias	helpcommand	"man"

unset autologout
unset ignoreeof


