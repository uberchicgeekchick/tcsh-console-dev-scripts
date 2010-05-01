#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "launchers/websites/init.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

setenv TCSH_WEBSITE_LAUNCHER_PATH "${TCSH_LAUNCHER_PATH}/websites";
if( ${?TCSH_RC_DEBUG} ) \
	printf "Loading:\n\t[file://%s/init.tcsh] @ %s.\n" "${TCSH_WEBSITE_LAUNCHER_PATH}" `date "+%I:%M:%S%P"`;

find_browser:
	set browsers=( "links" "lynx" );
	foreach browser(${browsers})
		foreach browser("`where '${browser}'`")
			if( -x "${browser}" ) \
				break;
			unset browser;
		end
		if( ${?browser} ) \
			break;
	end
	if(! ${?browser} ) \
		goto no_browser;
	if(! -x ${browser} ) \
		goto no_browser;
	setenv BROWSER "${browser}";
	
	set browsers=( "firefox" "ephinany" );
	foreach browser(${browsers})
		foreach browser("`where '${browser}'`")
			if( -x "${browser}" ) \
				break;
			unset browser;
		end
		if( ${?browser} ) \
			break;
	end
	if(! ${?browser} ) \
		goto no_browser;
	if(! -x ${browser} ) \
		goto no_browser;
	setenv XBROWSER "${browser}";
	
	unset browsers;
#find_browser:


source "${TCSH_RC_SESSION_PATH}/../setenv/PATH:recursively:add.tcsh" --maxdepth=1 "${TCSH_WEBSITE_LAUNCHER_PATH}";
foreach launcher ( "`find -L '${TCSH_WEBSITE_LAUNCHER_PATH}' -ignore_readdir_race -type f -perm '/u=x' -printf '%f\n'`" )
	switch( "${launcher}" )
		case "init.tcsh":
			if( ${?TCSH_RC_DEBUG} ) \
				printf "Skipping:\n\t[file://%s/%s]\n\tits not a launcher.\n" "${TCSH_WEBSITE_LAUNCHER_PATH}" "${launcher}";
			continue;
			breaksw;
	endsw
	
	set website="`printf '%s' '${launcher}' | sed -r 's/(.*)\.tcsh"\$"/\1/'`";
	if( ${?TCSH_RC_DEBUG} ) printf "Setting up website alias for [%s] to [%s/%s].\n" "${website}" "${TCSH_WEBSITE_LAUNCHER_PATH}" "${launcher}";
	if( "`alias '${website}'`" != "" ) \
		unalias "${website}";
	alias	"${website}"	\$"{TCSH_WEBSITE_LAUNCHER_PATH}/${launcher}";
	unset	website	launcher;
end
unset launcher;

exit_script:
	if( ${?sed_regexp_set} ) then
		unalias sed;
		unset sed_regexp_set;
	endif
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "launchers/websites/init.tcsh";
	exit;
#exit_script:

no_browser:
	if( ${?TERM} ) \
		printf "**error finding compatible browser while looking for %s.\n" "${browsers}" > /dev/stderr;
	unset browsers;
	goto exit_script;
#no_browser:

