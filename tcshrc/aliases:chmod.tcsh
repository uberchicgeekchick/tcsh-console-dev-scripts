#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";

source "${TCSH_RC_SESSION_PATH}/argv:check" "aliases:chmod.tcsh" ${argv};

if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;
set owners=( 'u' 'g' 'o' );
set changes=( '-' '+' '=' );
set permissions=( 'r' 'w' 'x' 'X' 's' 't' );
foreach change ( $changes )
	set permissions_so_far=""
	foreach permission ( $permissions )
		set opt="${change}${permission}";
		set permissions_so_far=( ${permissions_so_far}${permission} );
		if( ${permissions_so_far} != ${permission} ) alias "${change} ${permissions_so_far}" "chmod ${change}${permissions_so_far}"
		alias "${opt}" "chmod ${opt}";
		set owners_so_far="";
		foreach owner( $owners )
			set owners_so_far=(${owners_so_far}${owner});
			alias "${owner}${opt}" "chmod ${owner}${opt}";
			alias "${owner}${change}${permissions_so_far}" "chmod ${owner}${change}${permissions_so_far}"
			if( ${owners_so_far} != ${owner} ) alias "${owners_so_far}${opt}" "chmod ${owners_so_far}${opt}";
		end
	end
end

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "aliases:chmod.tcsh";

