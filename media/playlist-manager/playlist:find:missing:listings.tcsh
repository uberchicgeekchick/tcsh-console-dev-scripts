#!/bin/tcsh -f
init:
	set scripts_basename="playlist:find:missing:listings.tcsh";
	#set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	
	if(! ${?0} ) then
		@ errno=-501;
		goto exception_handler;
	endif
	
	set argc=${#argv};
	if( ${argc} < 1 ) then
		@ errno=-503;
		goto exception_handler;
	endif
	
	set extensions="";
#init:


check_dependencies:
	set dependencies=("${scripts_basename}");# "`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)$/\1/'`");
	@ dependencies_index=0;
	foreach dependency(${dependencies})
		@ dependencies_index++;
		unset dependencies[$dependencies_index];
		if( ${?debug} || ${?debug_dependencies} ) \
			printf "\n**${scripts_basename} debug:** looking for dependency: ${dependency}.\n\n"; 
			
		foreach program("`where '${dependency}'`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		if(! ${?program} ) then
			@ errno=-501;
			printf "One or more required dependencies couldn't be found.\n\t[${dependency}] couldn't be found.\n\t${scripts_basename} requires: ${dependencies}\n";
			goto exit_script;
		endif
		
		if( ${?debug} || ${?debug_dependencies} ) then
			switch( "`printf "\""%d"\"" "\""${dependencies_index}"\"" | sed -r 's/^[0-9]*[^1]?([1-3])"\$"/\1/'`" )
				case "1":
					set suffix="st";
					breaksw;
				
				case "2":
					set suffix="nd";
					breaksw;
				
				case "3":
					set suffix="rd";
					breaksw;
				
				default:
					set suffix="th";
					breaksw;
			endsw
			
			printf "**${scripts_basename} debug:** found ${dependencies_index}${suffix} dependency: ${dependency}.\n";
			unset suffix;
		endif
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?scripts_dirname} ) \
					breaksw;
				
				set old_owd="${cwd}";
				cd "`dirname '${program}'`";
				set scripts_dirname="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_dirname}/${scripts_basename}";
				breaksw;
			
			default:
				breaksw;
			
		endsw
		
		unset program;
	end
	
	unset dependency dependencies dependencies_index;
	goto parse_argv;
#check_dependencies:


main:
	if(! ${?playlist} ) then
		@ errno=-4;
		goto exception_handler;
	endif
	
	if(! ${?maxdepth} ) \
		set maxdepth=" -maxdepth 2";
	
	if(! ${?mindepth} ) \
		set mindepth=" ";
	
	if(! ${?extensions} ) \
		set extensions="";
	
	if(! ${?regextype} ) \
		set regextype="posix-extended";
	
	if(! ${?append} ) \
		goto find_missing_media;
#main:


setup_playlist_new:
	playlist:new:create.tcsh "${playlist}";
#setup_playlist_new:


find_missing_media:
	set escaped_cwd="`printf "\""%s"\"" "\""${cwd}"\"" | sed -r 's/\//\\\//g'`";
	if( ${?debug} ) then
		printf "Searching for missing multimedia files using:\n\t";
		printf "find -L "\""${cwd}"\""${maxdepth}${mindepth}-regextype ${regextype} -iregex '.*${extensions}"\$"' -type f | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\\\\1/g' | sed -r 's/(\[)/\\\\\\1/g' | sed -r 's/([*])/\\\\\\1/g'\n";
	endif
	@ errno=0;
	@ removed_podcasts=0;
	foreach podcast("`find -L "\""${cwd}"\""${maxdepth}${mindepth}-regextype ${regextype} -iregex '.*${extensions}"\$"' -type f | sed -r 's/(\\)/\\\\/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/(\[)/\\\[/g' | sed -r 's/([*])/\\\1/g'`")
		#printf "-->%s\n" "${podcast}";
		#continue;
		if( ${?skip_subdirs} ) then
			foreach skip_subdir ( "`printf "\""${skip_subdirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
				if( "`printf "\""${podcast}"\"" | sed -r "\""s/^${escaped_cwd}\/(${skip_subdir})\/.*/\1/"\""`" == "${skip_subdir}" ) \
					break;
				unset skip_subdir;
			end
			if( ${?skip_subdir} ) \
				continue;
		endif
		
		set status=0;
		set grep_test="`/bin/grep "\""${podcast}"\"" "\""${playlist}"\""`";
		#if( ${status} != 0 ) then
			#printf "**error:** searching for: %s\n" "/bin/grep ${podcast} "\""${playlist}"\""";
		#	continue;
		#endif
		if( "${grep_test}" != "" ) then
			if( ${status} != 0 ) \
				printf "**error: %s** searching for: %s\n" "${grep_test}" ${podcast};
			continue;
		endif
		
		if( ${?debug} || ${?debug_grep} ) then
			printf "Searching for podcast using:\n\t/bin/grep "\""${podcast}"\"" "\""${playlist}"\""\n\n";
			printf "grep's output:\n\t%s\n\n" "${grep_test}";
		endif
		
		if( ${?append} ) then
			set this_podcast="`printf "\""${podcast}"\"" | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
			printf "Adding:\n\t<file://%s>\n\t\tto\n\t<file://%s>\n" "${this_podcast}" "${playlist}";
			printf "%s\n" "${this_podcast}" >> "${playlist}.new";
			continue;
		endif
		
		if(! ${?remove} ) then
			set this_podcast="`printf "\""${podcast}"\"" | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
			if(! -e "${this_podcast}" ) \
				continue;
			
			printf "${this_podcast}\n";
			
			if( ${?create_script} ) then
				printf "%s\n" "${this_podcast}" >> "${create_script}";
			endif
			
			if(! ${?duplicates_subdirs} ) \
				continue;
			
			foreach duplicates_subdir ( "`printf "\""${duplicates_subdirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
				set duplicate_podcast="`printf "\""${podcast}"\"" | sed -r "\""s/^${escaped_cwd}\//${escaped_cwd}\/${duplicates_subdir}\//"\"" | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
				
				if(! -e "${duplicate_podcast}" ) \
					continue;
				
				printf "${duplicate_podcast}\n";
				if( ${?create_script} ) then
					printf "%s\n" "${duplicate_podcast}\n" >> "${create_script}";
				endif
			end
			unset duplicate_podcast;
			continue;
		endif
		
		set this_podcast="`printf "\""${podcast}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
		if(! -e "`printf "\""${podcast}"\"" | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`" ) \
			continue;
		
		if( ${?message} && ! ${?message_displayed} ) then
			printf "${message}";
			set message_displayed;
		endif
		
		set status=0;
		set rm_confirmation="`rm -vf${remove} "\""${this_podcast}"\""`";
		if(!( ${status} == 0 && "${rm_confirmation}" != "" )) \
			continue;
		
		@ removed_podcasts++;
		if( ${?create_script} ) then
			printf "rm -vf${remove} "\""${this_podcast}"\"";\n" >> "${create_script}";
		endif
		
		set podcast_dir="`dirname "\""${this_podcast}"\""`";
		set podcast_dir_for_ls="`dirname "\""${this_podcast}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
		while( "${podcast_dir}" != "/" )
			if( "`/bin/ls -A "\""${podcast_dir_for_ls}"\""`" != "" ) \
				break;
			
			rm -r -v "${podcast_dir}";
			if( ${?create_script} ) then
				printf "rm -rv "\""${podcast_dir}"\"";\n" >> "${create_script}";
			endif
			
			set podcast_cwd="`printf "\""${podcast_dir_for_ls}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
			set podcast_dir="`dirname "\""${podcast_cwd}"\""`";
			set podcast_dir_for_ls="`dirname "\""${podcast_cwd}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
		end
		
		if(! ${?duplicates_subdirs} ) then
			if( ${?podcast_cwd} ) \
				unset podcast_cwd;
			unset rm_confirmation podcast_dir podcast_dir_for_ls duplicate_podcast;
			continue;
		endif
		
		foreach duplicates_subdir ( "`printf "\""${duplicates_subdirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ "\$"//'`" )
			set duplicate_podcast="`printf "\""${podcast}"\"" | sed -r "\""s/^${escaped_cwd}\//${escaped_cwd}\/${duplicates_subdir}\//"\"" | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
			if(! -e "${duplicate_podcast}" ) \
				continue;
			
			set duplicate_podcast="`printf "\""${podcast}"\"" | sed -r "\""s/^${escaped_cwd}\//${escaped_cwd}\/${duplicates_subdir}\//"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g' | sed -r 's/\\\[/\[/g' | sed -r 's/\\([*])/\1/g'`";
			
			set status=0;
			set rm_confirmation="`rm -vf${remove} "\""${duplicate_podcast}"\""`";
			if(!( ${status} == 0 && "${rm_confirmation}" != "" )) \
				continue;
			
			@ removed_podcasts++;
			if( ${?create_script} ) then
				printf "rm -vf${remove} "\""${duplicate_podcast}"\"";\n" >> "${create_script}";
			endif
			
			set podcast_dir="`dirname "\""${duplicate_podcast}"\""`";
			set podcast_dir_for_ls="`dirname "\""${duplicate_podcast}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
			while( "${podcast_dir}" != "/" )
				if( "`/bin/ls -A "\""${podcast_dir_for_ls}"\""`" != "" ) \
					break;
				
				rm -r -v "${podcast_dir}";
				if( ${?create_script} ) then
					printf "rm -rv "\""${podcast_dir}"\"";\n" >> "${create_script}";
				endif
				
				set podcast_cwd="`printf "\""${podcast_dir_for_ls}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
				set podcast_dir="`dirname "\""${podcast_cwd}"\""`";
				set podcast_dir_for_ls="`dirname "\""${podcast_cwd}"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`";
			end
		end
		
		if(${?podcast_cwd}) \
			unset podcast_cwd;
		unset rm_confirmation duplicates_subdir podcast_dir podcast_dir_for_ls duplicate_podcast;
	end
	goto script_main_quit;
#find_missing_media:



script_main_quit:
	if( ${?append} ) then
		playlist:new:save.tcsh "${playlist}";
		unset append;
	endif
	
	if(! ${?removed_podcasts} ) \
		@ removed_podcasts=0;
	if( $removed_podcasts == 0 && ${?create_script} ) then
		rm "${create_script}";
	endif
	
	if( ${?old_owd} ) then
		cd "${owd}";
		set owd="${old_owd}";
		unset old_owd;
	endif
	
	if( ${?duplicates_subdir} ) \
		unset duplicates_subdir;
	if( ${?duplicate_podcast} ) \
		unset duplicate_podcast;
	if( ${?podcast_dir} ) \
		unset podcast_dir;
	if( ${?podcast} ) \
		unset podcast;
	if( ${?playlist} ) \
		unset playlist;
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
	if(! ${?errno} ) \
		@ errno=0;
	
	@ status=$errno;
	exit ${errno};
#script_main_quit:


usage:
	printf "\nUsage:\n\t%s playlist [directory] [--(extension|extensions)=] [--maxdepth=] [--recursive] [--search-all] [--skip-subdir=<sub-directory>] [--check-for-duplicates-in-subdir=<sub-directory>] [--remove[=(interactive|force)]]\n\tfinds any files in [directory], or its sub-directories, up to files of --maxdepth.  If the file is not not found in playlist,\n\tThe [directory] that's searched is [./] by default unless another absolute, or relative, [directory] is specified.\n\t[--(extension|extensions)=] is optional and used to search for files with extension(s) matching the string or escaped, posix-extended, regular expression, e.g. --extensions='(mp3|ogg)' only. Otherwise all files are searched for.\n--remove is also optional.  When this option is given %s will remove podcasts which aren't in the specified playlist.  Unless --remove is set to force you'll be prompted before each file is actually deleted.  If, after the file(s) are deleted, the parent directory is empty it will also be removed.\n" "`basename '${0}'`" "`basename '${0}'`";
	if( ${?no_exit_on_usage} ) \
		goto next_option;
	
	goto script_main_quit;
#usage:


default_callback:
	printf "handling callback to [%s].\n", "${last_callback}";
	unset last_callback;
	goto script_main_quit;
#default_callback:


exception_handler:
	if(! ${?errno} ) \
		@ errno=-599;
	printf "\n**%s error("\$"errno:%d):**\n\t" "${scripts_basename}"  $errno;
	switch( $errno )
		case -4:
			if(! ${?exit_on_error} ) \
				set exit_on_error;
			printf "An existing playlist must be specified" > /dev/stderr;
			breaksw;
		
		case -5:
			if(! ${?exit_on_error} ) \
				set exit_on_error;
			printf "An existing directory must be specified as the location to search for missing podcasts" > /dev/stderr;
			breaksw;
		
		case -501:
			printf "Sourcing is not supported and may only be executed" > /dev/stderr;
			breaksw;
		
		case -502:
			printf "One or more required dependencies couldn't be found.\n\n[%s] couldn't be found.\n\n%s requires: %s" "${dependency}" "${scripts_basename}" "${dependencies}";
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided" > /dev/stderr;
			breaksw;
		
		case -504:
			printf "[%s%s%s%s] is an unsupported option" "${dashes}" "${option}" "${equals}" "${value}" > /dev/stderr;
			breaksw;
		
		case -599:
		default:
			printf "An unknown error "\$"errno: %s has occured" "${errno}" > /dev/stderr;
			breaksw;
	endsw
	printf ".\n\nPlease see: %s%s --help%s for more information and supported options\n" \` "${scripts_basename}" \` > /dev/stderr;
	
	if( ${?callback} ) then
		set last_callback=$callback;
		unset callback;
		goto $last_callback;
	endif
	
	if(! ${?exit_on_error} ) \
		goto usage;
	
	goto script_main_quit;
#exception_handler:


parse_argv:
	@ argc=${#argv};
	
	if( ${argc} == 0 ) \
		goto main;
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		if( "$argv[$arg]" != "--debug" ) \
			continue;
		printf "Enabling debug mode (via "\$"argv[%d])\n" $arg;
		set debug;
		@ arg++;
		break;
	end
	
	if(!( ${?debug} && $arg == 2 )) \
		@ arg=1;
	
	if( ${?debug} ) \
		printf \$"argv[%d]: %s\n" $arg "$argv[$arg]";
	
	if(! -e "$argv[$arg]" ) then
		@ errno=-4;
		goto exception_handler;
	endif
	
	set playlist="$argv[$arg]";
	@ arg++;
	
	if( $arg > $argc ) \
		goto main;
	if(!( "$argv[$arg]" != "" && -d "$argv[$arg]" )) then
		@ errno=-5;
		goto exception_handler;
	else if( "$argv[$arg]" != "${cwd}" ) then
		set old_owd="${owd}";
		cd "$argv[$arg]";
	endif
	
	if( ${?debug} ) \
		printf "Checking %s's argv options.  %d total.\n" "$argv[1]" "${argc}";
#parse_argv:

parse_arg:
	while( $arg < $argc )
		if(! ${?arg_shifted} ) then
			@ arg++;
		else
			unset arg_shifted;
		endif
		
		if( ${?debug} ) \
			printf "Checking argv #%d (%s).\n" "${arg}" "$argv[$arg]";
		
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) \
			set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?/\2/'`";
		if( "${option}" == "$argv[$arg]" ) \
			set option="";
		
		set equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\3/'`";
		if( "${equals}" == "$argv[$arg]" ) \
			set equals="";
		
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\4/' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		if( "${value}" == "" || ( "${option}" == "" && "${value}" == "$argv[$arg]" )  ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				set test_dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\1/'`";
				set test_option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\2/'`";
				set test_equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\3/'`";
				set test_value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\4/' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
				
				if(!("${test_dashes}" == "$argv[$arg]" && "${test_option}" == "$argv[$arg]" && "${test_equals}" == "$argv[$arg]" && "${test_value}" == "$argv[$arg]")) then
					@ arg--;
				else
					set arg_shifted;
					set equals="=";
					set value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
				endif
				unset test_dashes test_option test_equals test_value;
			endif
		endif
		
		if( "`printf "\""${value}"\"" | sed -r "\""s/^(~)(.*)/\1/"\""`" == "~" ) then
			set value="`printf "\""${value}"\"" | sed -r "\""s/^(~)(.*)/${escaped_home_dir}\2/"\"" | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		endif
		
		if( "`printf "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/\1/"\""`" == "." ) then
			set value="`printf "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/${escaped_starting_cwd}\2/"\"" | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
		endif
		
		if( "`printf "\""${value}"\"" | sed -r "\""s/^.*(\*)/\1/"\""`" == "*" ) then
			set dir="`printf "\""${value}"\"" | sed -r "\""s/^(.*)\*"\$"/\1/"\""`";
			set value="`/bin/ls --width=1 "\""${dir}"\""*`";
		endif
		
		if( ${?debug} ) \
			printf "**debug** parsed %sargv[%d] (%s).\n\tParsed option: %s%s%s%s\n" ""\$"" "${arg}" "$argv[$arg]" "${dashes}" "${option}" "${equals}" "${value}";
		
		switch( "${option}" )
			case "help":
				goto usage;
				breaksw;
			
			case "check-for-duplicates-in-subdir":
			case "skip-files-in-subdir":
			case "skip-subdir":
			case "dups-subdir":
				set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/^\///' | sed -r 's/\/"\$"//'`";
				if( ! -d "${value}" && ! -L "${value}" ) then
					printf "--%s must specify a sub-directory of %s.\n" "${option}" "${cwd}" > /dev/stderr;
					continue;
				endif
				
				switch("${option}")
					case "skip-files-in-subdir":
					case "skip-subdir":
						#set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/\//\\\//g'`";
						if(! ${?skip_subdirs} ) then
							set skip_subdirs=("${value}");
						else
							set skip_subdirs=( "${skip_subdirs}" "\n" "${value}" );
						endif
						breaksw;
					case "dups-subdir":
					case "check-for-duplicates-in-subdir":
						if(! ${?duplicates_subdirs} ) then
							set duplicates_subdirs=("${value}");
						else
							set duplicates_subdirs=( "${duplicates_subdirs}" "\n" "${value}");
						endif
						breaksw;
				endsw
				breaksw;
			
			case "regextype":
			case "regex-type":
				switch("${value}")
					case "posix-extended":
					case "posix-awk":
					case "posix-basic":
					case "posix-egrep":
					case "emacs":
						set regextype="${value}";
						breaksw;
					
					default:
						printf "Invalid %s specified.  Supported %s values are: posix-extended (this is the default), posix-awk, posix-basic, posix-egrep and emacs.\n" "${option}" "${option}" > /dev/stderr;
						breaksw;
				endsw
			
			case "enable":
				switch("${value}")
					case "logging":
						breaksw;
					
					default:
						printf "%s cannot be enabled.\n" "${value}" > /dev/stderr;
						shfit;
						continue;
						breaksw;
					
				endsw
			case "create-script":
			case "mk-script":
				if("${value}" != "" &&  "${value}" != "logging") then
					set create_script="${value}";
				else
					set create_script="clean-up:script.tcsh";
				endif
				if(! -e "${create_script}" ) then
					printf "#\!/bin/tcsh -f\n" > "${create_script}";
					chmod u+x "${create_script}";
				endif
				breaksw;
			
			case "extension":
			case "extensions":
				if( "${value}" != "" ) \
					set extensions="${value}";
				breaksw;
			
			case "debug":
				switch("${value}")
					case "grep":
						if( ${?debug_grep} ) \
							breaksw;
						set debug_grep;
					breaksw;
					
					default:
						if( ${?debug} ) \
							breaksw;
						set debug;
					breaksw;
				endsw
				breaksw;
			
			case "remove":
				switch("${value}")
					case "force":
						set remove="";
						set message="\t**Files found in\n\t\t[${cwd}]\n\twhich are not in the playlist\n\t\t[${playlist}]\n\twill be removed.**\n\n";
					breaksw;
					
					case "interactive":
					default:
						set remove="i";
						set message="\t**Files found in\n\t\t[${cwd}]\n\twhich are not in the playlist\n\t\t[${playlist}]\n\twill be prompted for removal.**\n\n";
					breaksw;
				endsw
				breaksw;
			
			case "recursive":
				set maxdepth="";
				breaksw;
			
			case "append":
				set append;
				breaksw;
			
			case "maxdepth":
				if( ${value} != "" && `printf "%s" "${value}" | sed -r 's/^([\-]).*/\1/'` != "-" ) then
					set value=`printf "%s" "${value}" | sed -r 's/.*([0-9]+).*/\1/'`
					if( ${value} > 0 ) \
						set maxdepth=" -maxdepth ${value}";
				endif
				if(! ${?maxdepth} ) \
					printf "--maxdepth must be an integer value that is gretter than 0." > /dev/stderr;
				breaksw;
			
			case "mindepth":
				if( ${value} != "" && `printf "%s" "${value}" | sed -r 's/^([\-]).*/\1/'` != "-" ) then
					set value=`printf "%s" "${value}" | sed -r 's/.*([0-9]+).*/\1/'`
					if( ${value} > 0 ) \
						set mindepth=" -mindepth ${value} ";
				endif
				if(! ${?mindepth} ) \
					printf "--maxdepth must be an integer gretter than 0." > /dev/stderr
				breaksw;
			
			case "search-subdirs-only":
				set mindepth=" -mindepth 2 ";
				breaksw;
			
			case "all":
			case "search-all":
			case "search-all-subdirs":
				set mindepth=" ";
				set maxdepth="";
				breaksw;
			
			case "":
				breaksw;
			
			default:
				@ errno=-504;
				set callback="parse_arg";
				goto exception_handler;
				breaksw;
			
		endsw
		if( ${?arg_shifted} ) then
			unset arg_shifted;
			@ arg--;
		endif
	end
	goto main;
#parse_arg:
