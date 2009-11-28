#!/bin/tcsh -f
# prompt settings
# limits previous directories to 3 levels. When %c or etc is used.
set padhour='0'
set ellipsis

# set tcsh default command prompt:
#
#set prompt="\n%B%{^[[105m%}(%p on %Y-%W-%D)%b\n%{^[[0m%}%{^[[35m%}%U[ %B%n@%m%b ]%u\n%{^[[0m%}%{^[[31m%}@%c9 #%{^[[0m%} "
#
#set prompt="\n%B%{^[[47m%}(%p on %Y-%W-%D)%b\n%{^[[107m%}%B[ %U%n@%m%u ]%b\n%{^[[0m%}%{^[[101m%}%{^[[37m%}%B@%c9 #%{^[[0m%} "
if( "${uid}" != "0" ) then
	set prompt='\n%B%{^[[13m%}(%p on %Y-%W-%D)%b\n%{^[[15m%}[ %n@%m ]\n%{^[[31m%}@%c03 #>';
else
	set prompt='\n%B%{^[[13m%}(%p on %Y-%W-%D)%b\n%{^[[15m%}[ %n@%m ]\n%{^[[31m%}@%c03 $>';
endif

# echo's the new current directory when the current working directory's changed.
# This also detects if we're in X11 & if so than it update's the title bar of xterm, gnome-terminal, et.al..
if( -o /dev/$tty ) then
	alias cwdcmd '(printf "Directory: %s\n" "${cwd}" > /dev/$tty)';
	if( -x /usr/bin/biff ) /usr/bin/biff y;
	# If we're running under X11
	if( ${?DISPLAY} ) then
		if( ${?TERM} && ${?EMACS} == 0 ) then
			if( ${TERM} == "xterm" ) then
				alias cwdcmd '(printf "\033]2;<%s> [%s] #> @ %s\007\033]1;%s\007Directory: %s\n" "${HOST}" "${USER}" "${cwd}" "${HOST}" "${cwd}" > /dev/$tty)';
				cd .;
			endif
		endif
		if( -x /usr/bin/biff ) /usr/bin/biff n;
	endif
endif

# Used wherever normal csh prompts with a question mark.
# set prompt2="%B%R?>%b "
# set prompt2="%B%R%b%S?%s%L"


# Used  when displaying  the  corrected command line when automatic
# spelling correction is in effect.
#
# set prompt3="CORRECT>%R (y|n|e)?"
# set prompt3="%BCORRECT%b%S>%s%R (%By%b|%Bn%b|%Be%b)%S?%s%L"
# set prompt3="%{^[[41;33;5m%}CORRECT%S\n\t>%s%R (%By%b|%Bn%b|%Be%b)%S?%s%L\n\t(y|n|e)"

