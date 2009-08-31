#!/bin/tcsh -f
if( ! ${?SSH_CONNECTION} && ! ${?TCSHRC_DEBUG} && ${?1} && "${1}" != "" && "${1}" == "--debug" ) setenv TCSHRC_DEBUG;
complete sudo "p/1/c/";

set services_paths=( "/etc/init.d" );
foreach services_path( ${services_paths} )
	foreach service ( "`/usr/bin/find -H ${services_path} -maxdepth 1 -xtype f -perm -u+x -printf '%f\n'`" )
		if( ${?TCSHRC_DEBUG} ) printf "Setting sudo alias for %s @ %s\n" ${service} `date "+%I:%M:%S%P"`;
		alias		"${service}"			"sudo ${services_path}/${service}";
		complete	"${service}"			"p/1/(start|stop|restart|status)/";
		
		alias		"${services_path}/${service}"	"sudo ${services_path}/${service}";
		complete	"${services_path}/${service}"	"p/1/(start|stop|restart|status)/";
	end
end
unset services_paths services_path service;

