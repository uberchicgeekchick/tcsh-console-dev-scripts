#!/bin/tcsh -f
if( $?0 ) then
	cd "`dirname '${0}'`";
	set scripts_name="`basename '${0}'`";
	printf "%s sets up alacast's environmental settings\n%s should be sourced and not run directly.\nUsage:\n\t%ssource %s%s" "${source}" "${scripts_name}" '`' "${cwd}/${scripts_name}" '`';
	cd "${owd}"
	exit -1;
endif

if( ${?TCSH_RC_DEBUG} )	\
	printf "Setting up Alacast v1's and v2's environment @ %s\n" `date "+%I:%M:%S%P"`;


clean_alacasts_path:
	setenv PATH "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/\/projects\/(cli|gtk)\/alacast(\/[^\:]*\:)?//g'`";
	if( ${?alacasts_path} )	\
		unset alacasts_path;
#clean_alacasts_path:

set_perl_modules:
	#the PERLLIB environment variable
	#export PERLLIB=/path/to/my/dir
	
	#the PERL5LIB environment variable
	#export PERL5LIB=/path/to/my/dir
#set_perl_modules:

set_gtk_path:
	setenv ALACAST_GTK_PATH "/projects/gtk/alacast";
	set alacast_gtk_paths=("bin" "scripts" "scripts/auto-updaters" "scripts/playlist-manager" "scripts/validators" "scripts/user-scripts");
	foreach alacast_gtk_path(${alacast_gtk_paths})
		if( ${?TCSH_RC_DEBUG} )	\
			printf "Attempting to add: [file://%s] to your PATH:\t\t" "${alacast_gtk_path}";
		set alacast_gtk_path="${ALACAST_GTK_PATH}/${alacast_gtk_path}";
		set escaped_alacast_gtk_path="`printf "\""%s"\"" "\""${alacast_gtk_path}"\"" | sed -r 's/\//\\\//g'`";
		if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:(${escaped_alacast_gtk_path}).*/\1/g'`" == "${alacast_gtk_path}" ) then
			continue;
		endif
		
		if( ${?TCSH_RC_DEBUG} )	\
			printf "[added]\n";
		
		if(! ${?alacasts_path} ) then
			set alacasts_path="${alacast_gtk_path}";
		else
			set alacasts_path="${alacasts_path}:${alacast_gtk_path}";
		endif
		
		unset escaped_alacast_gtk_path;
	end
	unset alacast_gtk_path alacast_gtk_paths;
#set_gtk_path:


set_cli_path:
	setenv ALACAST_CLI_PATH "/projects/cli/alacast";
	set alacast_cli_paths=("bin" "scripts" "helpers/gpodder-0.11.3-hacked/bin" "helpers/gpodder-0.11.3-hacked/scripts");
	foreach alacast_cli_path(${alacast_cli_paths})
		if( ${?TCSH_RC_DEBUG} )	\
			printf "Attempting to add: [file://%s] to your PATH:\t\t" "${alacast_cli_path}";
		set alacast_cli_path="${ALACAST_CLI_PATH}/${alacast_cli_path}";
		set escaped_alacast_cli_path="`printf "\""%s"\"" "\""${alacast_cli_path}"\"" | sed -r 's/\//\\\//g'`";
		if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:(${escaped_alacast_cli_path}).*/\1/g'`" == "${alacast_cli_path}" ) then
			if( ${?TCSH_RC_DEBUG} )	\
				printf "[skipped]\n\t\t\t<file://%s> is already in your PATH\n" "${alacast_cli_path}";
			continue;
		endif
		
		if( ${?TCSH_RC_DEBUG} )	\
			printf "[added]\n";
		
		if(! ${?alacasts_path} ) then
			set alacasts_path="${alacast_cli_path}";
		else
			set alacasts_path="${alacasts_path}:${alacast_cli_path}";
		endif
		
		unset escaped_alacast_cli_path;
	end
	unset alacast_cli_path alacast_cli_paths;
#set_cli_path:


set_alacast_environment:
	if(! ${?alacasts_path} ) then
		rehash;
	else
		setenv PATH "${PATH}:${alacasts_path}";
		unset alacasts_path;
	endif
	
	alias "alacast:feed:fetch:all:enclosures.tcsh" "${ALACAST_GTK_PATH}/scripts/alacast:feed:fetch:all:enclosures.tcsh --disable=logging"
	
	# when no option are given alacast:cli uses the environmental variable: $ALACAST_OPTIONS.
	alias "alacast.php:sync" "${ALACAST_CLI_PATH}/bin/alacast.php --with-defaults=sync";
	# --with-defaults prepends $ALACAST_OPTIONS
	alias "alacast.php:update" "${ALACAST_CLI_PATH}/bin/alacast.php --with-defaults=update";
#set_alacast_environment:


setup_ini:
	if( -e "${HOME}/.alacast/alacast.ini" ) then
		set alacast_ini="${HOME}/.alacast/alacast.ini";
	else if( -e "${HOME}/.alacast/profiles/${USER}/alacast.ini" ) then
		set alacast_ini="${HOME}/.alacast/profiles/${USER}/alacast.ini";
	else if( -e "${ALACAST_GTK_PATH}/data/profiles/${USER}/alacast.ini" ) then
		set alacast_ini="${ALACAST_GTK_PATH}/data/profiles/${USER}/alacast.ini";
	else if( -e "${ALACAST_GTK_PATH}/data/profiles/default/alacast.ini" ) then
		set alacast_ini="${ALACAST_GTK_PATH}/data/profiles/default/alacast.ini";
	else if( -e "${ALACAST_CLI_PATH}/data/profiles/${USER}/alacast.ini" ) then
		set alacast_ini="${ALACAST_CLI_PATH}/data/profiles/${USER}/alacast.ini";
	else if( -e "${ALACAST_CLI_PATH}/data/profiles/default/alacast.ini" ) then
		set alacast_ini="${ALACAST_CLI_PATH}/data/profiles/default/alacast.ini";
	endif
	
	if( ${?alacast_ini} ) then
		if( -e "${alacast_ini}" )	\
			setenv ALACAST_INI "${alacast_ini}";
		unset alacast_ini;
	endif
#setup_ini:

