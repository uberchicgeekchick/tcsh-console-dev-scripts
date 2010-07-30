#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "art:color.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

setenv color_start `cat ${TCSH_RC_SESSION_PATH}/art:color`;
setenv tcsh_color "${color_start}";
setenv color "${color_start}";
if( ${?TCSH_RC_DEBUG} ) printf "%sSetting up %scolor TCSH%s environment:\n\tterminal color pallet:\t\t\t%s"\$"{color_start}00;31m[finished]%s"\$"{color_start}00;00m\n" "${color_start}00;00m" "${color_start}00;31m" "${color_start}00;00m" "${color_start}00;31m" "${color_start}00;00m";

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art:color.cshrc.tcsh";

