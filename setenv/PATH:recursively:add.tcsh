#!/usr/bin/tcsh -f
set source_file="PATH:recursively:add.tcsh";
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
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

set maxdepth="";
set mindepth="";
set find_name_argv="";
next_argv:
while("${1}" != "" )
	set status=0;
	set option="`printf "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`";
	set value="`printf "\""${1}"\"" | sed -r 's/[\-]{1,2}([^=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/'`";
	switch("${option}")
		case "sub-directory-name-restriction":
		case "filter":
		case "f":
			set find_name_argv=" -name '${value}'";
			shift;
			breaksw;
		
		case "maxdepth":
			set maxdepth=" -maxdepth ${value}";
			shift;
			breaksw;
		
		case "mindepth":
			set mindepth=" -mindepth ${value}";
			shift;
			breaksw;
		
		case "h":
		case "help":
			goto usage;
			breaksw;
		default:
			breaksw;
	endsw
	unset option value;
	
	if(!( "${1}" != "" && -d "${1}" )) then
		if( "${2}" != "" ) then
			shift;
			goto next_argv;
		endif
		set status=-1;
		printf "[%s] is not an existing directory.\n\n" "${1}" > /dev/stderr;
		shift;
		continue;
	endif
	
	set new_path="";
	set search_dir="`echo '${1}' | sed -r 's/(.*)\/?"\$"/\1/'`";
	shift;
	if( ${?TCSH_RC_DEBUG} ) echo "\nRecusively looking for possible paths is: <${search_dir}> using:\n\t/usr/bin/find '${search_dir}'${maxdepth}${mindepth}${find_name_argv} -type d\n";
	
	set escaped_recusive_dir="`echo '${search_dir}' | sed -r 's/\//\\\//g'`";
	foreach dir ( "`/usr/bin/find '${search_dir}'${maxdepth}${mindepth}${find_name_argv} -type d`" )
		if( "${dir}" == "" ) continue;
		if( "`echo '${dir}' | sed -r 's/${escaped_recusive_dir}(\.).*/\1/'`" == "." ) continue;
		set escaped_dir="`echo '${dir}' | sed -r 's/.*\/([^\/]+)/\1/'`";
		switch( "${escaped_dir}" )
			case "tmp":
			case "lost+found":
			#case "reference":
			#case "templates":
				continue;
				breaksw;
			
			default:
				if( ${?TCSH_RC_DEBUG} )	\
					printf "Attempting to add: [file://%s] to your PATH:\t\t" "${dir}";
				set dir="`echo '${dir}' | sed -r 's/([\:])/\\\1/g'`";
				set escaped_dir="`echo '${dir}' | sed -r 's/\//\\\//g'`";
				if( "`echo '${PATH}' | sed 's/.*:\(${escaped_dir}\).*/\1/g'`" == "${dir}" ) then
					if( ${?TCSH_RC_DEBUG} )	\
						printf "[skipped]\n\t\t\t<file://%s> is already in your PATH\n" "${dir}";
					continue;
				endif
				
				if( ${?TCSH_RC_DEBUG} )	\
					printf "[added]\n" "${dir}";
				set new_path="${new_path}:${dir}";
				breaksw;
		endsw
	end
	
	if( "${new_path}" != "" ) then
		set new_path="`printf '%s' '${new_path}' | sed -r 's/::/:/g' | sed -r 's/:"\$"//'`";
		setenv PATH "${PATH}:${new_path}";
	endif
	unset dir escaped_dir new_path find_name_argv;
end

	if( ${status} != 0 ) goto usage;

main_quit:
	set source_file="PATH:recursively:add.tcsh";
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";
	
	exit ${status};

usage:
	printf "Usage: PATH:recursively:add.tcsh directory_to_recursively search and add sub-directory.\n";
	if( ${?option} ) goto next_argv:
	goto main_quit;
