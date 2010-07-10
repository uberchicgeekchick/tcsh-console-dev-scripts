if( ${uid} == 0 ) \
	exit 0;

if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
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

set dirs=( "/etc/init.d" "/etc/rc.d" );
foreach dir( ${dirs} )
	set escaped_dir="`printf "\""%s"\""  "\""${dir}"\"" | sed -r 's/\//\\\//g'`";
	if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:?(${escaped_dir})\:?.*/\1/g'`" != "${dir}" ) \
		setenv "${PATH}:${dir}";
	foreach service("`/usr/bin/find -L ${dir} -maxdepth 1 -xtype f -printf '%f\n'`")
		if( ${?TCSH_RC_DEBUG} ) \
			printf "Setting sudo service alias for %s/%s @ %s\n" "${dir}" "${service}" "`date '+%I:%M:%S%P'`";
		if( "`alias "\""${service}"\""`" != "sudo ${dir}/${service}" ) then
			alias ${service} "sudo ${dir}/${service}";
			complete ${service} p/1/"(start stop restart reload unload status --help)"/;
		endif
		
		alias ${dir}/${service} sudo ${dir}/${service};
		complete ${dir}/${service} p/1/"(start stop restart reload unload status --help)"/;
		unset service;
	end
	unset dir;
end

unset dirs;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "aliases:sudo:services.cshrc.tcsh";

