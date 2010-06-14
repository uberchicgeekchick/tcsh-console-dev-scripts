#!/bin/tcsh -f
# Both
# 	${TCSH_RC_SESSION_PATH}/complete.cshrc.tcsh
# and
# 	${TCSH_RC_SESSION_PATH}/bindkey.cshrc.tcsh
# are sourced from this file.
#
if( ${?TCSH_RC_SOURCE_FILE} ) then
	unsetenv TCSH_RC_SOURCE_FILE;
endif
if( ${?TCSH_RC_DEBUG} ) \
	unsetenv TCSH_RC_DEBUG;
#if(! ${?TCSH_RC_SESSION_PATH} )
setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "etc-csh.cshrc" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;


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
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Loading csh.login @ %s.\n" `date "+%I:%M:%S%P"`;
	source /etc/csh.login >& /dev/null
	if( ${?TCSH_RC_DEBUG} ) \
		printf "csh.login finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
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
if(${?tcsh} && -r "${TCSH_RC_SESSION_PATH}/bindkey.cshrc.tcsh" ) then
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Setting up key bindings @ %s.\n" `date "+%I:%M:%S%P"`;
	source "${TCSH_RC_SESSION_PATH}/bindkey.cshrc.tcsh";
endif

#
# Some useful settings
#
if( ${?TCSH_RC_DEBUG} ) \
	printf "Setting up TCSH environment @ %s.\n" `date "+%I:%M:%S%P"`;
source "${TCSH_RC_SESSION_PATH}/environment.cshrc.tcsh"

#
#
if( ${?TCSH_RC_DEBUG} ) \
	printf "Setting up TCSH's ls-F, ls, & LS_OPTIONS @ %s.\n" `date "+%I:%M:%S%P"`;
source "${TCSH_RC_SESSION_PATH}/ls.cshrc.tcsh";

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
if( ${?TCSH_RC_DEBUG} ) \
	printf "Setting up TCSH prompts @ %s.\n" `date "+%I:%M:%S%P"`;
source "${TCSH_RC_SESSION_PATH}/prompts.cshrc.tcsh";

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
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Loading expert settings [%s/.csh.expert] @ %s.\n" "${HOME}" `date "+%I:%M:%S%P"`;
	source $HOME/.csh.expert
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Expert settings finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
	goto done
endif

#
# Source the completion extension of the tcsh
#
if($?tcsh) then
	set _rev=${tcsh:r}
	set _rel=${_rev:e}
	set _rev=${_rev:r}
	if(($_rev > 6 || ($_rev == 6 && $_rel > 1)) && -r "${TCSH_RC_SESSION_PATH}/complete.cshrc.tcsh") then
		if( ${?TCSH_RC_DEBUG} ) \
			printf "Loading TCSH auto-completion rules @ %s.\n" `date "+%I:%M:%S%P"`;
		source "${TCSH_RC_SESSION_PATH}/complete.cshrc.tcsh";
		if( ${?TCSH_RC_DEBUG} ) \
			printf "Completion setup finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
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
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Loading local TCSH setting [/etc/csh.cshrc.local] @ %s.\n" `date "+%I:%M:%S%P"`;
	source /etc/csh.cshrc.local
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Local TCSH setting finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
endif
if( -r "${TCSH_RC_SESSION_PATH}/csh.cshrc" ) then
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Loading custom TCSH settings [%s/csh.cshrc] @ %s.\n" "${TCSH_RC_SESSION_PATH}" `date "+%I:%M:%S%P"`;
	source "${TCSH_RC_SESSION_PATH}/csh.cshrc";
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Custom TCSH settings finished loading @ %s.\n" `date "+%I:%M:%S%P"`;
endif

if( ${?TCSH_RC_DEBUG} ) \
	printf "TCSH setup completed @ %s.\n" `date "+%I:%M:%S%P"`;
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "etc-csh.cshrc";
# End of /etc/csh.cshrc
