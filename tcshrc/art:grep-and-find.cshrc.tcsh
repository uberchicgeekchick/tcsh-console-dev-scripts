#!/bin/tcsh -f
	set scripts_name="art:grep-and-find.cshrc.tcsh";
	if( `printf '%s' "${0}" | sed -r 's/^[^\.]*(tcsh)$/\1/'` != "tcsh" ) then
		printf "%s%s only supports being sourced from within a TCSH script.\n" "${0}" "${scripts_name}";
		set status=-1;
		exit ${status};
	endif
	
	if(! ${?TCSH_RC_SESSION_PATH} ) \
		setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
		source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_name}" ${argv};
		if( $args_handled > 0 ) then
			@ args_shifted=0;
			while( $args_shifted < $args_handled )
				@ args_shifted++;
				shift;
			end
			unset args_shifted;
		endif
		unset args_handled;

if( ${?TCSH_RC_DEBUG} ) \
	printf "Setting up grep, egrep, and find.\n";

#setenv	GREP_OPTIONS	"--binary-files=without-match --color --with-filename --line-number --initial-tab --no-messages --context=6 --perl-regexp --ignore-case";
setenv	GREP_OPTIONS	"--binary-files=without-match --color --with-filename --line-number --no-messages";
alias "grep" "grep ${GREP_OPTIONS}";
alias "egrep" "grep --perl-regexp";# ${GREP_OPTIONS}";
alias "egrep-i" "egrep --ignore-case";
unsetenv GREP_OPTIONS

alias find "find -L";

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_name}";

