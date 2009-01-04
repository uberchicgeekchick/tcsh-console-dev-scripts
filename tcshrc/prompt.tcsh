#!/bin/tcsh -f
# prompt settings
# limits previous directories to 3 levels. When %c or etc is used.
set ellipsis
# set tcsh default command prompt:
set prompt = "\n%B%{^[[105m%}(%p on %Y-%W-%D)\n%{^[[35m%}[ %m %n ]\n%{^[[31m%}@%c3/%{^[[35m%}# "


# Used wherever normal csh prompts with a question mark.
# set prompt2="%B%R?>%b "
set prompt2="%B%R%b%S?%s%L"


# Used  when displaying  the  corrected command line when automatic
# spelling correction is in effect.
#
# set prompt3="CORRECT>%R (y|n|e)?"
# set prompt3="%BCORRECT%b%S>%s%R (%By%b|%Bn%b|%Be%b)%S?%s%L"
set prompt3="%{^[[41;33;5m%}CORRECT%S\n\t>%s%R (%By%b|%Bn%b|%Be%b)%S?%s%L\n\t(y|n|e)"

