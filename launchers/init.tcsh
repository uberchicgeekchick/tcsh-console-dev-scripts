#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
set source_file="aliases:launchers.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${source_file}" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled source_file;
if( ${?TCSH_RC_DEBUG} ) printf "Loading aliases.launchers.tcsh @ %s.\n" `date "+%I:%M:%S%P"`;

if(! ${?eol} ) setenv eol '$';
#if(! ${?eol} ) setenv eol '"\$"';

if(!(${?DEBUG_EXEC})) then
	setenv output " >& /dev/null &";
else
	setenv output " &";
endif

set TCSH_LAUNCHER_PATH="${TCSH_RC_SESSION_PATH}/../launchers";
set starting_directory="${cwd}";
cd "${TCSH_LAUNCHER_PATH}";
foreach launcher ( "`find ${TCSH_LAUNCHER_PATH} -type f -perm '/u=x' -printf '%f\n'`" )
	switch( "${launcher}" )
		case "init.tcsh":
		case "firefox-bin":
		case "template-cli-launcher":
		case "template-x-launcher":
			continue;
			breaksw;
		case "xfmedia":
		case "xine":
		case "mp3info":
			# let the launcher handle setting the alias:
			if( ${?TCSH_RC_DEBUG} ) printf "Sourcing: %s\n" "${TCSH_LAUNCHER_PATH}/${launcher}";
			source "${TCSH_LAUNCHER_PATH}/${launcher}";
			continue;
			breaksw;
		case "browser":
		case "google":
		case "url-shortener":
			# alias to target this launcher:
			if( ${?TCSH_RC_DEBUG} ) printf "Skipping: [%s/%s] as it should just be in your path.\n" "${TCSH_LAUNCHER_PATH}" "${launcher}";
			#alias ${launcher} "${TCSH_LAUNCHER_PATH}/${launcher}";
			continue;
			breaksw;
	endsw
	
	if( "`echo ${launcher} | sed 's/.*\(\.init\)${eol}/\1/g'`" == ".init" ) then
		if( ${?TCSH_RC_DEBUG} ) printf "Setting up alias(es) for: %s.\n\tSourcing %s/%s @ %s.\n" ${launcher} ${TCSH_LAUNCHER_PATH} ${launcher} `date "+%I:%M:%S%P"`;
		source ${TCSH_LAUNCHER_PATH}/${launcher};
		if( ${?TCSH_RC_DEBUG} ) printf "[done]\n";
		continue;
	endif
	
	foreach program ( "`where '${launcher}'`" )
		if( "${program}" != "${0}" && "${program}" != "./${launcher}" && "${program}" != "${TCSH_LAUNCHER_PATH}/${launcher}" && -x "${program}" ) break;
		unset program;
	end
	if(! ${?program} ) set program="";
	if(! -x "${program}" ) then
		if( `alias '${launcher}'` != "" ) unalias "${launcher}";
		if( ${?TCSH_RC_DEBUG} ) printf "ERROR: Unable to create alias for %s to [%s/%s] @ %s.\n" $launcher $cwd $launcher `date "+%I:%M:%S%P"`;
		if( ${?TCSH_RC_DEBUG} ) printf "\tERROR: No executable could be found.\n";
		continue;
	endif
	
	# alias to target this launcher:
	if( ${?TCSH_RC_DEBUG} ) printf "Aliasing: [%s] to [%s/%s]\n" "${launcher}" "${TCSH_LAUNCHER_PATH}" "${launcher}";
	alias ${launcher} "${TCSH_LAUNCHER_PATH}/${launcher}";
	
	# let the launcher handle setting the alias:
	#if( ${?TCSH_RC_DEBUG} ) printf "Sourcing: %s\n" "${TCSH_LAUNCHER_PATH}/${launcher}";
	#source "${TCSH_LAUNCHER_PATH}/${launcher}";
	unset program;
end
unset TCSH_LAUNCHER_PATH launcher;
cd "${starting_directory}";

if( ${?sed_regexp_set} ) then
	unalias sed;
	unset sed_regexp_set;
endif

unsetenv output

set source_file="aliases:launchers.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";
