#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "launchers/init.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

	if(! ${?TCSH_SILENT_EXEC} ) then
		set output="&";
	else
		set output=">& /dev/null &";
	endif
	
	setenv TCSH_LAUNCHER_PATH "${TCSH_RC_SESSION_PATH}/../launchers";
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Loading:\n\t[file://%s/init.tcsh] @ %s.\n" "${TCSH_LAUNCHER_PATH}" `date "+%I:%M:%S%P"`;
	source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" --maxdepth=1 "${TCSH_LAUNCHER_PATH}";
	foreach launcher ( "`/usr/bin/find -L ${TCSH_LAUNCHER_PATH} -maxdepth 1 -type f -perm '/u=x' -printf '%f\n'`" )
		switch( "${launcher}" )
			case "init.tcsh":
				if( ${?TCSH_RC_DEBUG} ) \
					printf "Skipping:"\$"TCSH_LAUNCHER_PATH initialization script:\n\t<file://%s/%s>\n" "${TCSH_LAUNCHER_PATH}" "${launcher}";
				breaksw;
			
			case "template":
				if( ${?TCSH_RC_DEBUG} ) \
					printf "**Skipping:** alternative(s) template:\n\t<file://%s/%s>\n" "${TCSH_ALTERNATIVES_PATH}" "${alternative}";
				breaksw;
			
			case "xfmedia":
			case "xine":
				# let the launcher handle setting the alias:
				if( ${?TCSH_RC_DEBUG} ) \
					printf "Sourcing: %s\n" "${TCSH_LAUNCHER_PATH}/${launcher}";
				source "${TCSH_LAUNCHER_PATH}/${launcher}";
				breaksw;
			
			case "mp3info":
				# alias to target this launcher:
				if( ${?TCSH_RC_DEBUG} ) \
					printf "Aliasing: [%s] to [%s/%s]\n" "${launcher}" "${TCSH_LAUNCHER_PATH}" "${launcher}";
				alias ${launcher} \$"{TCSH_LAUNCHER_PATH}/${launcher}";
				breaksw;
			
			case "browser":
			case "url-shortener":
				# alias to target this launcher:
				if( ${?TCSH_RC_DEBUG} ) \
					printf "Skipping: [%s/%s] as it should just be in your path.\n" "${TCSH_LAUNCHER_PATH}" "${launcher}";
				#alias ${launcher} \$"{TCSH_LAUNCHER_PATH}/${launcher}";
				breaksw;
			
			default:
				if( "`printf "\""%s"\"" "\""${launcher}"\"" | sed -r 's/.*(\.init)"\$"/\1/g'`" == ".init" ) then
					if( ${?TCSH_RC_DEBUG} ) \
						printf "Setting up alias(es) for: %s.\n\tSourcing %s/%s @ %s.\n" ${launcher} ${TCSH_LAUNCHER_PATH} ${launcher} `date "+%I:%M:%S%P"`;
					source "${TCSH_LAUNCHER_PATH}/${launcher}" ${argv};
					if( ${?TCSH_RC_DEBUG} ) \
						printf "[finished]\n";
					breaksw;
				endif
				
				foreach program ( "`where '${launcher}'`" )
					if( "${program}" != "${0}" && "${program}" != "./${launcher}" && "${program}" != "${TCSH_LAUNCHER_PATH}/${launcher}" && -x "${program}" ) \
						break;
					unset program;
				end
				if(! ${?program} ) then
					if( ${?TCSH_RC_DEBUG} ) \
						printf "ERROR: Unable to create alias for %s to [%s/%s] @ %s.\n" "${launcher}" "${TCSH_LAUNCHER_PATH}" "${launcher}" `date "+%I:%M:%S%P"`;
					if( ${?TCSH_RC_DEBUG} ) \
						printf "\tERROR: No executable could be found.\n";
					breaksw;
				endif
				
				# alias to target this launcher:
				if( ${?TCSH_RC_DEBUG} ) \
					printf "Aliasing: [%s] to [%s/%s]\n" "${launcher}" "${TCSH_LAUNCHER_PATH}" "${launcher}";
				alias ${launcher} \$"{TCSH_LAUNCHER_PATH}/${launcher}";
				
				unset program launcher;
				breaksw;
		endsw
	end
	
	if( ${?output} ) \
		unset output;
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "launchers/init.tcsh";
	
