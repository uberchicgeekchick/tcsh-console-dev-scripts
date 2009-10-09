#!/bin/tcsh -f
source /projects/cli/tcshrc/debug:check aliases:sudo:services.tcsh ${argv};

complete sudo "p/1/c/";

set services_paths=( "/etc/init.d" );
foreach services_path( ${services_paths} )
	if(! ${?TCSH_SESSION_PATH_SET} ) setenv PATH "${PATH}:${services_path}";
	foreach service ( "`/usr/bin/find -H ${services_path} -maxdepth 1 -xtype f -perm -u+x -printf '%f\n'`" )
		if( ${?TCSHRC_DEBUG} ) printf "Setting sudo service alias for %s @ %s\n" ${service} `date "+%I:%M:%S%P"`;
		alias		"${service}"			"sudo ${services_path}/${service}";
		complete	"${service}"			"p/1/(start|stop|restart|status)/";
		
		alias		"${services_path}/${service}"	"sudo ${services_path}/${service}";
		complete	"${services_path}/${service}"	"p/1/(start|stop|restart|status)/";
	end
end
unset services_paths services_path service;

source /projects/cli/tcshrc/debug:clean-up aliases:sudo:srevices.tcsh;
