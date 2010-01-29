#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
set source_file="prompts.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${source_file}" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

if(! ${?eol} ) setenv eol '$';
#if(! ${?eol} ) setenv eol '"\$"';

set padhour='0'
set ellipsis

# set tcsh default command prompt:
#
#set prompt="\n%B%{^[[105m%}(%p on %Y-%W-%D)%b\n%{^[[0m%}%{^[[35m%}%U[ %B%n@%m%b ]%u\n%{^[[37m%}<file://%$pwd>\n%{^[[0m%}%{^[[31m%}@%c9 #%{^[[0m%} "
#
#set prompt="\n%B%{^[[47m%}(%p on %Y-%W-%D)%b\n%{^[[107m%}%B[ %U%n@%m%u ]%b\n%{^[[37m%}<file://%$pwd>\n%{^[[0m%}%{^[[101m%}%{^[[37m%}%B@%c9 #%{^[[0m%} "
if(! ${?pwd} ) set pwd="`pwd`";
set prompt='\n%B%{^[[13m%}(%p on %Y-%W-%D)%b\n%{^[[15m%}[ %n@%m ]\n%{^[[37m%}<file://%$pwd>\n%{^[[31m%}[@%c03] ';
if( "${uid}" != "0" ) then
	if( ${?TCSH_RC_DEBUG} ) printf "Setting user's prompt.\n";
	set prompt="${prompt}#>";
else
	if( ${?TCSH_RC_DEBUG} ) printf "Setting super user's prompt.\n";
	set prompt="${prompt}${eol}>";
endif

# echo's the new current directory when the current working directory's changed.
# This also detects if we're in X11 & if so than it update's the title bar of xterm, gnome-terminal, et.al..
unalias cwdcmd;
set cwdcmd='set pwd="`pwd`"; printf "Directory: %s <file://%s> @ %s\n" "${cwd}" "${pwd}" "`date \+%c`"';
if(! -o /dev/$tty ) then
	if( ${?TCSH_RC_DEBUG} ) printf "Setting cwdcmd alias.\n";
	alias cwdcmd "${cwdcmd}";
	cd .;
else
	if( -x /usr/bin/biff ) /usr/bin/biff y;
	# If we're running under X11
	if( ${?DISPLAY} ) then
		if( ${?TERM} && ${?EMACS} == 0 ) then
			if( ${TERM} == "xterm" ) then
				if( ${?TCSH_RC_DEBUG} ) printf "Setting cwdcmd alias for X11 terminal.\n";
				alias cwdcmd 'printf "\033]2;<%s@%s> %s[file://%s] #>\007\033]1;%s\007" "${USER}" "${HOST}" "${cwd}" "`pwd`" "${HOST}" > /dev/$tty; '"${cwdcmd}"' > /dev/$tty;';
				cd .;
			endif
		endif
		if( -x /usr/bin/biff ) /usr/bin/biff n;
	endif
	if( "`alias cwdcmd`" == "" ) then
		if( ${?TCSH_RC_DEBUG} ) printf "Setting cwdcmd alias.\n";
		alias cwdcmd ''"${cwdcmd}"' > /dev/$tty';
		cd .;
	endif
endif
unset cwdcmd

# Used wherever normal csh prompts with a question mark.
# set prompt2="%B%R?>%b "
# set prompt2="%B%R%b%S?%s%L"


# Used  when displaying  the  corrected command line when automatic
# spelling correction is in effect.
#
# set prompt3="CORRECT>%R (y|n|e)?"
# set prompt3="%BCORRECT%b%S>%s%R (%By%b|%Bn%b|%Be%b)%S?%s%L"
# set prompt3="%{^[[41;33;5m%}CORRECT%S\n\t>%s%R (%By%b|%Bn%b|%Be%b)%S?%s%L\n\t(y|n|e)"

if(! ${?source_file} ) set source_file="prompts.cshrc.tcsh";
if( "${source_file}" != "prompts.cshrc.tcsh" ) set source_file="prompts.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";

