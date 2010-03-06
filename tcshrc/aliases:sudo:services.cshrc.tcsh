#!/bin/tcsh -f
if( ${uid} == 0 ) exit 0;

if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "aliases:sudo:services.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

complete sudo "p/1/c/";

set services_paths=( "/etc/init.d" );
foreach services_path( ${services_paths} )
	setenv PATH "${PATH}:${services_path}";
	foreach service ( "`/usr/bin/find -H ${services_path} -maxdepth 1 -xtype f -perm -u+x -printf '%f\n'`" )
		set service_path="${services_path}";
		if( ${?TCSH_RC_DEBUG} ) printf "Setting sudo service alias for %s/%s @ %s\n" "${service_path}" "${service}" "`date '+%I:%M:%S%P'`";
		if( "`alias '${service}'`" == "" ) then
			alias		"${service}"			"sudo ${service_path}/${service}";
			complete	"${service}"			"p/1/(start|stop|restart|status)/";
		endif
		
		alias		"${service_path}/${service}"	"sudo ${service_path}/${service}";
		complete	"${service_path}/${service}"	"p/1/(start|stop|restart|status)/";
		
		set service_path="`echo '${service_path}' | sed -r 's/(\/etc\/)init(\.d)/\1rc\2/g'`";
		if( ${?TCSH_RC_DEBUG} ) printf "Setting sudo service alias for %s/%s @ %s\n" "${service_path}" "${service}" "`date '+%I:%M:%S%P'`";
		alias		"${service_path}/${service}"	"sudo ${service_path}/${service}";
		complete	"${service_path}/${service}"	"p/1/(start|stop|restart|status)/";
	end
end

unset services_paths services_path service_path service;

setenv TCSH_SESSION_SERVICES_PATH_SET;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "aliases:sudo:services.cshrc.tcsh";

