#!/usr/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "PATH:recursively:add.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
@ arg=$args_handled;
@ argc=${#argv};
unset args_handled;

set maxdepth;
set mindepth;
set find_subdirs;
set follow_symlinks="-L";
set no_other_fs;
next_argv:
	while( $arg < $argc )
		@ arg++;
		set status=0;
		set option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/[\-]{1,2}([^=]+)=?(.*)/\1/'`";
		set value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/[\-]{1,2}([^=]+)=?(.*)/\2/'`";
		switch("${option}")
			case "sub-directory-name-restriction":
			case "filter":
			case "f":
				set find_subdirs=" -name '${value}'";
				continue;
			
			case "follow":
			case "follow-symlinks":
				set follow_symlinks="-L";
				continue;
			
			case "no-follow":
				set follow_symlinks="-H";
				continue;
			
			case "maxdepth":
				set maxdepth=" -maxdepth ${value}";
				continue;
			
			case "mindepth":
				set mindepth=" -mindepth ${value}";
				continue;
			
			case "all-fs":
				set no_other_fs;
				continue;
			
			case "no-other-fs":
				set no_other_fs=" -xdev";
				continue;
			
			case "h":
			case "help":
				goto usage;
				continue;
			
			default:
				breaksw;
		endsw
		
		if(!( "${value}" != "" && -d "${value}" )) then
			set status=-1;
			if( ${?TCSH_RC_DEBUG} ) \
				printf "**Skipping:** <file://%s> is not an existing directory.\n\n" "${value}" > /dev/stderr;
			continue;
		endif
		
		set new_path="";
		
		set old_owd="${owd}";
		cd "${value}";
		set search_dir="${cwd}";
		cd "${owd}";
		set owd="${old_owd}";
		
		if( ${?TCSH_RC_DEBUG} ) \
			printf "\nRecusively looking for possible paths in: <%s> using:\n\tfind %s "\""${search_dir}"\""${no_other_fs} -ignore_readdir_race${maxdepth}${mindepth}${find_subdirs} -type d \\\! -iregex '.*\/\..*'\n" "${search_dir}" "${follow_symlinks}";
		
		set escaped_search_dir="`printf "\""%s"\"" "\""${search_dir}"\"" | sed -r 's/\//\\\//g'`";
		foreach dir ( "`find ${follow_symlinks} "\""${search_dir}"\""${no_other_fs} -ignore_readdir_race${maxdepth}${mindepth}${find_subdirs} -type d \! -iregex '.*\/\..*'`" )
			if( "${dir}" == "" ) continue;
			if( "`printf "\""%s"\"" "\""${dir}"\"" | sed -r 's/${escaped_search_dir}(\.).*/\1/'`" == "." ) \
				continue;
			set escaped_dir="`printf "\""%s"\"" "\""${dir}"\"" | sed -r 's/.*\/([^\/]+)/\1/'`";
			switch( "`basename "\""${dir}"\""`" )
				case "tmp":
				case "lost+found":
				#case "reference":
				#case "templates":
					if( ${?TCSH_RC_DEBUG} ) \
						printf "Skipping <file://%s/%s>\n" "${search_dir}" "${dir}"
					continue;
					breaksw;
				
				default:
					if( ${?TCSH_RC_DEBUG} ) \
						printf "Attempting to add: [file://%s] to your PATH:\t\t" "${dir}";
					
					if( `${TCSH_RC_SESSION_PATH}/../setenv/PATH:add:test.tcsh "${dir}"` != 0 ) then
						if( ${?TCSH_RC_DEBUG} ) \
							printf "[skipped]\n\t\t\t<file://%s> is already in your PATH\n" "${dir}";
						continue;
					endif
					
					if( ${?TCSH_RC_DEBUG} ) \
						printf "[added]\n";
					if(! ${?new_path} ) then
						set new_path="${dir}";
					else
						set new_path="${new_path}:${dir}";
					endif
					breaksw;
			endsw
		end
		
		if( "${new_path}" != "" ) then
			set new_path="`printf '%s' '${new_path}' | sed -r 's/::/:/g' | sed -r 's/^://' | sed -r 's/:"\$"//'`";
			setenv PATH "${PATH}:${new_path}";
		endif
	end
#next_argv:

main_quit:
	unset option value arg argc;
	unset dir escaped_dir new_path escaped_search_dir;
	unset follow_symlinks search_dir no_other_fs maxdepth mindepth find_subdirs;
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "PATH:recursively:add.tcsh";
	
	exit ${status};

usage:
	printf "Usage: PATH:recursively:add.tcsh directory_to_recursively search and add sub-directory.\n";
	if( ${?option} ) \
		goto next_argv:
	goto main_quit;
