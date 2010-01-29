#!/bin/tcsh -f
if( "`echo '${0}' | sed -r 's/^[^\.]*(tcsh)/\1/'`" != "tcsh" ) then
	cd "`dirname '${0}'`";
	set source_file="`basename '${0}'`";
	printf "%s sets up alacast's environmental settings\n%s should be sourced and not run directly.\nUsage:\n\tsource %s" "${source}" "${source_file}" "${cwd}/${source_file}";
	cd "${owd}"
	unset source_file;
	exit -1;
endif

setenv ALACAST_PATH "/projects/cli/alacast";
setenv PATH "${PATH}:${ALACAST_PATH}/bin:${ALACAST_PATH}/scripts:${ALACAST_PATH}/helpers/gpodder-0.11.3-hacked/bin:${ALACAST_PATH}/helpers/gpodder-0.11.3-hacked/helper-scripts";


# $ALACAST_OPTIONS acts like arguments to alacast.php when no command line arguments are given:
setenv ALACAST_OPTIONS '--logging --titles-append-pubdate --strip-characters=#;!';

# when no option are given alacast:cli uses the environmental variable: $ALACAST_OPTIONS.
alias "alacast.php:sync" "${ALACAST_PATH}/alacast.php --with-defaults=sync";
# --with-defaults prepends $ALACAST_OPTIONS
alias "alacast.php:update" "${ALACAST_PATH}/alacast.php --with-defaults=update";

