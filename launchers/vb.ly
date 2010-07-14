#!/bin/tcsh -f
launcher_init:
	set this_program="wget";
	foreach browser ( "`which '${this_program}'`" )
		if( "${browser}" != "${0}" && -x "${browser}" ) break
	end
	
	if(! ${?browser} ) \
		goto noexec;
	if(! -x "${browser}" ) \
		goto noexec;
	goto launcher_main;

noexec:
	printf "Unable to find %s.\n" "${browser}";
	if( ${?browser} ) \
		unset browser;
	unset browser;
	exit -1;


launcher_main:
	set uri_shortener_domain="http://vb.ly/";
	set status=0;

next_uri:
	while( "${1}" != "" )
		set uri_to_shorten="${1}";
		shift;
		goto shorten_uri;
	end

shorten_uri:
	if(! ${?uri_to_shorten} ) then
		if(! ${?uri_shortener_data} ) \
			set status=-1;
		goto exit_script;
	endif
	
	set uri_shortener_data="action=showten&format=simple&url=${uri_to_shorten}";
	
	${browser} -o /dev/null -O - --post-data="${uri_shortener_data}" "${uri_shortener_domain}" | grep '<p>Short URL' | sed -r 's/.*<a href="([^"]+)">.*/\1/';
	unset uri_to_shorten;
	goto next_uri;

exit_script:
	if( ${status} != 0 ) \
		printf "%s uri://address.to/shorten" "`basename '${0}'`";
	exit ${status};
