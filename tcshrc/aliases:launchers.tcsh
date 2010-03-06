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

setenv TCSH_LAUNCHER_PATH "${TCSH_RC_SESSION_PATH}/../launchers";
source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" --maxdepth=1 "${TCSH_LAUNCHER_PATH}";
foreach launcher ( "`find ${TCSH_LAUNCHER_PATH} -maxdepth 1 -type f -perm '/u=x' -printf '%f\n'`" )
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
	alias ${launcher} \$"{TCSH_LAUNCHER_PATH}/${launcher}";
	
	# let the launcher handle setting the alias:
	#if( ${?TCSH_RC_DEBUG} ) printf "Sourcing: %s\n" "${TCSH_LAUNCHER_PATH}/${launcher}";
	#source "${TCSH_LAUNCHER_PATH}/${launcher}";
	unset program launcher;
end

setenv TCSH_WEBSITE_LAUNCHERS_PATH "${TCSH_LAUNCHER_PATH}/websites";
source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" --maxdepth=1 "${TCSH_WEBSITE_LAUNCHERS_PATH}";
foreach launcher ( "`find '${TCSH_WEBSITE_LAUNCHERS_PATH}' -type f -perm '/u=x' -printf '%f\n'`" )
	set website="`printf '%s' '${launcher}' | sed -r 's/(.*)\.tcsh${eol}/\1/'`";
	if( ${?TCSH_RC_DEBUG} ) printf "Setting up website alias for [%s] to [%s/%s].\n" "${website}" "${TCSH_WEBSITE_LAUNCHERS_PATH}" "${launcher}";
	alias	"${website}"	\$"{TCSH_WEBSITE_LAUNCHERS_PATH}/${launcher}";
	unset website launcher;
end
unset launcher;

if( ${?sed_regexp_set} ) then
	unalias sed;
	unset sed_regexp_set;
endif

unsetenv output

set source_file="aliases:launchers.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";
