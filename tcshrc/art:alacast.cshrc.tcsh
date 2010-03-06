#!/bin/tcsh -f
if( "`echo '${0}' | sed -r 's/^[^\.]*(tcsh)/\1/'`" != "tcsh" ) then
	cd "`dirname '${0}'`";
	set scripts_name="`basename '${0}'`";
	printf "%s sets up alacast's environmental settings\n%s should be sourced and not run directly.\nUsage:\n\tsource %s" "${source}" "${scripts_name}" "${cwd}/${scripts_name}";
	cd "${owd}"
	unset scripts_name;
	exit -1;
endif

if( ${?TCSH_RC_DEBUG} ) printf "Setting up Alacast v1's and v2's environment @ %s\n" `date "+%I:%M:%S%P"`;

setenv ALACASTS_CLI_PATH "/projects/cli/alacast";
setenv PATH "${PATH}:${ALACASTS_CLI_PATH}/bin:${ALACASTS_CLI_PATH}/scripts:${ALACASTS_CLI_PATH}/helpers/gpodder-0.11.3-hacked/bin:${ALACASTS_CLI_PATH}/helpers/gpodder-0.11.3-hacked/helper-scripts";
setenv ALACASTS_GTK_PATH "/projects/cli/alacast";
setenv PATH "${PATH}:${ALACASTS_GTK_PATH}/bin:${ALACASTS_GTK_PATH}/scripts";


# $ALACAST_OPTIONS acts like arguments to alacast.php when no command line arguments are given:
setenv ALACASTS_OPTIONS '--logging --titles-reformat-numerical --titles-append-pubdate --playlist=m3u --strip-characters=#;!';

# when no option are given alacast:cli uses the environmental variable: $ALACAST_OPTIONS.
alias "alacast.php:sync" "${ALACASTS_CLI_PATH}/bin/alacast.php --with-defaults=sync";
# --with-defaults prepends $ALACAST_OPTIONS
alias "alacast.php:update" "${ALACASTS_CLI_PATH}/bin/alacast.php --with-defaults=update";

