#!/bin/tcsh -f
# This file sources /projects/cli/tcshrc/complete.tcsh and
# /projects/cli/tcshrc/bindkey.tcsh used especially by tcsh.
#


#setenv TCSHRC_DEBUG;
if( ! ${?SSH_CONNECTION} && ${?1} && "${1}" != "" && "${1}" == "--debug" ) setenv TCSHRC_DEBUG;
if( ${?TCSHRC_DEBUG} ) printf "Loading /etc/csh.cshrc @ %s.\n" `date "+%I:%M:%S%P"`;

onintr -
set noglob
unalias sed
#
# Call common progams from /bin or /usr/bin only
#

if( ${?PATH} ) unsetenv PATH

alias path 'if( -x /bin/\!^ ) /bin/\!*; if( -x /usr/bin/\!^ ) /usr/bin/\!*'
if( -x /bin/id ) then
    set id=/bin/id
else if( -x /usr/bin/id ) then
    set id=/usr/bin/id
endif

#
# Default echo style
#
set echo_style=both

#
# If `login files' are not sourced first
#
if( ${?loginsh} && ! ${?CSHRCREAD} ) then
	if( ${?TCSHRC_DEBUG} ) printf "Loading csh.login @ %s.\n" `date "+%I:%M:%S%P"`;
	source /etc/csh.login >& /dev/null
	if( ${?TCSHRC_DEBUG} ) printf "csh.login finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
endif

#
# In case if not known
#
if(! ${?UID}  ) set -r  UID=${uid}
if(! ${?EUID} ) set -r EUID="`${id} -u`"

#
# Avoid trouble with Emacs shell mode
#
if($?EMACS) then
  setenv LS_OPTIONS '-N --color=none -T 0';
  path tset -I -Q
  path stty cooked pass8 dec nl -echo
# if($?tcsh) unset edit
endif

#
# Only for interactive shells
#
if(! ${?prompt}) goto done

#
# Let root watch its system
#
if( "$uid" == "0" ) then
    set who=( "%n has %a %l from %M." )
    set watch=( any any )
endif

#
# This is an interactive session
#
# Now read in the key bindings of the tcsh
#
if($?tcsh && -r /projects/cli/tcshrc/bindkey.tcsh) then
	if( ${?TCSHRC_DEBUG} ) printf "Setting up key bindings @ %s.\n" `date "+%I:%M:%S%P"`;
	source /projects/cli/tcshrc/bindkey.tcsh
	if( ${?TCSHRC_DEBUG} ) printf "Key bindings setup completed @ %s.\n" `date "+%I:%M:%S%P"`;
endif

#
# Some useful settings
#
if( ${?TCSHRC_DEBUG} ) printf "Setting up TCSH environment @ %s.\n" `date "+%I:%M:%S%P"`;
source /projects/cli/tcshrc/environment.tcsh
if( ${?TCSHRC_DEBUG} ) printf "TCSH environment setup completed @ %s.\n" `date "+%I:%M:%S%P"`;

#
#
if( -x /usr/bin/dircolors ) then
    if( -r $HOME/.dir_colors ) then
	eval `/usr/bin/dircolors -c $HOME/.dir_colors`
    else if( -r /etc/DIR_COLORS ) then
	eval `/usr/bin/dircolors -c /etc/DIR_COLORS`
    endif
endif
setenv LS_OPTIONS '--color=tty'
if( ${?LS_COLORS} ) then
    if( "${LS_COLORS}" == "" ) setenv LS_OPTIONS '--color=always'
endif
unalias ls
if( "$uid" == "0" ) then
    setenv LS_OPTIONS "-A -N $LS_OPTIONS -T 0"
else
    setenv LS_OPTIONS "-N $LS_OPTIONS -T 0"
endif
alias ls 'ls $LS_OPTIONS'
alias la 'ls -aF --color=none'
alias ll 'ls -l  --color=none'
alias l  'll'
alias dir  'ls --format=vertical'
alias vdir 'ls --format=long'
alias d dir;
alias v vdir;
alias o 'less'
alias .. 'cd ..'
alias ... 'cd ../..'
alias cd.. 'cd ..'
alias rd rmdir
alias md 'mkdir -p'
alias startx 'if( ! -x /usr/bin/startx ) echo "No startx installed";\
	      if(   -x /usr/bin/startx ) /usr/bin/startx |& tee ${HOME}/.xsession-error'
alias remount '/bin/mount -o remount,\!*'

#
# Prompting and Xterm title
#
set prompt="%B%m%b %C2%# "
if( -o /dev/$tty ) then
  alias cwdcmd '(echo "Directory: $cwd" > /dev/$tty)'
  if( -x /usr/bin/biff ) /usr/bin/biff y
  # If we're running under X11
  if( ${?DISPLAY} ) then
    if( ${?TERM} && ${?EMACS} == 0 ) then
      if( ${TERM} == "xterm" ) then
        alias cwdcmd '(echo -n "\033]2;$USER on ${HOST}: $cwd\007\033]1;$HOST\007" > /dev/$tty)'
        cd .
      endif
    endif
    if( -x /usr/bin/biff ) /usr/bin/biff n
    set prompt="%C2%# "
  endif
endif
#
# tcsh help system does search for uncompressed helps file
# within the cat directory system of a old manual page system.
# Therefore we use whatis as alias for this helpcommand
#
alias helpcommand whatis

#
# Expert mode: if we find $HOME/.csh.expert we skip our settings
# used for interactive completion and read in the expert file.
if(-r $HOME/.csh.expert) then
	unset noglob
	if( ${?TCSHRC_DEBUG} ) printf "Loading expert settings [%s/.csh.expert] @ %s.\n" "${HOME}" `date "+%I:%M:%S%P"`;
	source $HOME/.csh.expert
	if( ${?TCSHRC_DEBUG} ) printf "Expert settings finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
	goto done
endif

#
# Source the completion extension of the tcsh
#
if($?tcsh) then
	set _rev=${tcsh:r}
	set _rel=${_rev:e}
	set _rev=${_rev:r}
	if(($_rev > 6 || ($_rev == 6 && $_rel > 1)) && -r /projects/cli/tcshrc/complete.tcsh) then
		if( ${?TCSHRC_DEBUG} ) printf "Loading TCSH auto-completion rules @ %s.\n" `date "+%I:%M:%S%P"`;
		source /projects/cli/tcshrc/complete.tcsh
		if( ${?TCSHRC_DEBUG} ) printf "Completion setup finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
	endif
	#
	# Enable editing in multibyte encodings for the locales
	# where this make sense, but not for the new tcsh 6.14.
	#
	if($_rev < 6 || ($_rev == 6 && $_rel < 14)) then
		switch ( `/usr/bin/locale charmap` )
		case UTF-8:
			set dspmbyte=utf8
			breaksw
		case BIG5:
			set dspmbyte=big5
			breaksw
		case EUC-JP:
			set dspmbyte=euc
			breaksw
		case EUC-KR:
			set dspmbyte=euc
			breaksw
		case GB2312:
			set dspmbyte=euc
			breaksw
		case SHIFT_JIS:
			set dspmbyte=sjis
			breaksw
		default:
			breaksw
		endsw
	endif
	#
	unset _rev _rel
endif

done:
onintr
unset noglob

#
# Just in case the user excutes a command with ssh
#
if( ${?SSH_CONNECTION} && ! ${?CSHRCREAD} ) then
	set _SOURCED_FOR_SSH=true
	source /etc/csh.login >& /dev/null
	unset _SOURCED_FOR_SSH
endif

#
# Local configuration
#
if( -r /etc/csh.cshrc.local ) then
	if( ${?TCSHRC_DEBUG} ) printf "Loading local TCSH setting [/etc/csh.cshrc.local] @ %s.\n" `date "+%I:%M:%S%P"`;
	source /etc/csh.cshrc.local
	if( ${?TCSHRC_DEBUG} ) printf "Local TCSH setting finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
endif
if( -r /projects/cli/tcshrc/csh.cshrc ) then
	if( ${?TCSHRC_DEBUG} ) printf "Loading custum TCSH settings [/projects/cli/tcshrc/csh.cshrc] @ %s.\n" `date "+%I:%M:%S%P"`;
	source /projects/cli/tcshrc/csh.cshrc
	if( ${?TCSHRC_DEBUG} ) printf "Custom TCSH settings finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
endif

if( ${?TCSHRC_DEBUG} ) printf "TCSH setup completed @ %s.\n" `date "+%I:%M:%S%P"`;
# End of /etc/csh.cshrc
