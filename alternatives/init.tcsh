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

setenv TCSH_ALTERNATIVES_PATH "${TCSH_RC_SESSION_PATH}/../alternatives";
	
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Loading:\n\t[file://%s/init.tcsh] @ %s.\n" "${TCSH_ALTERNATIVES_PATH}" `date "+%I:%M:%S%P"`;
	source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" --maxdepth=1 "${TCSH_ALTERNATIVES_PATH}";
	foreach alternative ( "`find -L ${TCSH_ALTERNATIVES_PATH} -maxdepth 1 -type f -perm '/u=x' -printf '%f\n'`" )
		switch( "${alternative}" )
			case "init.tcsh":
				if( ${?TCSH_RC_DEBUG} ) \
					printf "**Skipping:** alternative(s) initalization scriprt:\n\t<file://%s/%s>\n" "${TCSH_ALTERNATIVES_PATH}" "${alternative}";
				breaksw;
			
			case "template":
				if( ${?TCSH_RC_DEBUG} ) \
					printf "**Skipping:** alternative(s) template:\n\t<file://%s/%s>\n" "${TCSH_ALTERNATIVES_PATH}" "${alternative}";
				breaksw;
			
			case "find.bck":
			case "find":
				if( ${?TCSH_RC_DEBUG} ) \
					printf "Skipping incomplete alternative scriprt:\n\t<file://%s/%s>\n" "${TCSH_ALTERNATIVES_PATH}" "${alternative}";
				breaksw;
			
			default:
				if( "`printf "\""%s"\"" "\""${alternative}"\"" | sed -r 's/.*(\.init)"\$"/\1/g'`" == ".init" ) then
					if( ${?TCSH_RC_DEBUG} ) \
						printf "Setting up alias(es) for: %s.\n\tSourcing %s/%s @ %s.\n" ${alternative} ${TCSH_LAUNCHER_PATH} ${alternative} `date "+%I:%M:%S%P"`;
					source "${TCSH_ALTERNATIVES_PATH}/${alternative}" ${argv};
					if( ${?TCSH_RC_DEBUG} ) \
						printf "[finished]\n";
					breaksw;
				endif
		
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
				set alias_argz=" `alias "\""${alternative}"\"" | sed -r 's/^([^ ]+) (.*)/\2/'`";;
				if( "${alias_argz}" != "" ) then
					set escaped_alternative="`printf "\""%s"\"" "\""${alias_argz}"\"" | sed -r 's/([\[\/\(\.\+\*\-])/\\\1/g'`";
					if( "`printf "\""%s"\"" "\""${alias_argz}"\"" | sed -r 's/^(${escaped_alternative})(.*)"\$"/\1/'`" == "${TCSH_ALTERNATIVES_PATH}/${alternative}" ) \
						set alias_argz="`printf "\""%s"\"" "\""${alias_argz}"\"" | sed -r 's/^(${escaped_alternative})(.*)"\$"/\2/'`";
				endif
				
				alias ${alternative} \$"{TCSH_ALTERNATIVES_PATH}/${alternative}${alias_argz}";
				
				unset programm alias_argz;
				breaksw;
		endsw
		unset alternative;
	end
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "alternatives/init.tcsh";
	
