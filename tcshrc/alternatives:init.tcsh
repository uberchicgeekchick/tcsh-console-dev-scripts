#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "alternatives/init.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;
	
	alias ex "ex -E -n -X --noplugin";

if(!(${?DEBUG_EXEC})) then
	setenv output " >& /dev/null &";
else
	setenv output " &";
endif

setenv TCSH_ALTERNATIVES_PATH "${TCSH_RC_SESSION_PATH}/../alternatives";
if( ${?TCSH_RC_DEBUG} ) \
	printf "Loading:\n\t[file://%s/init.tcsh] @ %s.\n" "${TCSH_ALTERNATIVES_PATH}" `date "+%I:%M:%S%P"`;
source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" --maxdepth=1 "${TCSH_ALTERNATIVES_PATH}";
foreach alternative ( "`find -L ${TCSH_ALTERNATIVES_PATH} -maxdepth 1 -type f -perm '/u=x' -printf '%f\n'`" )
	switch( "${alternative}" )
		case "init.tcsh":
			if( ${?TCSH_RC_DEBUG} ) \
				printf "Skipping:\n\t<file://%s/%s>\n\tits not a alternative(s) initalization scriprt.\n" "${TCSH_ALTERNATIVES_PATH}" "${alternative}";
			breaksw;
		
		default:
			foreach program ( "`where "\""${alternative}"\""`" )
				if( "${program}" != "${0}" && "${program}" != "./${alternative}" && "${program}" != "${TCSH_ALTERNATIVES_PATH}/${alternative}" && -x "${program}" ) \
					break;
				unset program;
			end
			
			if(! ${?program} ) then
				if( ${?TCSH_RC_DEBUG} ) \
					printf "ERROR: Unable to create alias for %s to [%s/%s] @ %s.\n\tERROR: No executable could be found.\n" "${alternative}" "${TCSH_ALTERNATIVES_PATH}" "${alternative}" `date "+%I:%M:%S%P"`;
				unset program;
				breaksw;
			endif
			
			# alias to target this alternative:
			if( ${?TCSH_RC_DEBUG} ) \
				printf "Aliasing: [%s] to [%s/%s]\n" "${alternative}" "${TCSH_ALTERNATIVES_PATH}" "${alternative}";
			if( `alias "${alternative}"` != "" ) then
				set alias_argz=" `alias "\""${alternative}"\"" | sed -r 's/^([^ ]+) (.*)/\2/'`";;
			else
				set alias_argz;
			endif
			
			alias ${alternative} \$"{TCSH_ALTERNATIVES_PATH}/${alternative}${alias_argz}";
			
			unset programm alias_argz;
			breaksw;
	endsw
	unset alternative;
end

unsetenv output

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "alternatives/init.tcsh";
