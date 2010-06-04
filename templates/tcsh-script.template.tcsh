#!/bin/tcsh -f
setenv:
	onintr exit_script;
	
	set strict;
	set supports_being_sourced;
	
	set supports_multiple_files;
	#set supports_hidden_files;
	set scripts_supported_extensions="mp3|ogg|m4a";
	
	#set auto_read_stdin;
	#set scripts_interactive;
	set process_each_filename;
	
	set scripts_basename="tcsh-script.template.tcsh";
	set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	set scripts_alias="`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)"\$"/\1/'`";
	set usage_message="Usage: ${scripts_basename} [options]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.\n\n\t\t\t-\tTells ${scripts_basename} to read all further arguments/filenames from standard input (-! disables this).\n\n\t\t\t--\tThis will cause the script to process any further filenames as they're reached(--! disables this).\n";
	
	@ minimum_options=-1;
	@ maximum_options=-1;
	
	if( ${?SSH_CONNECTION} ) then
		set stdout=/dev/null;
		set stderr=/dev/null;
	else
		set stdout=/dev/stdout;
		set stderr=/dev/stdout;
	endif
	
	if( "`alias cwdcmd`" != "" ) then
		set original_cwdcmd="`alias cwdcmd`";
		unalias cwdcmd;
	endif
	
	if( ${?GREP_OPTIONS} ) then
		set grep_options="${GREP_OPTIONS}";
		unsetenv GREP_OPTIONS;
	endif
	
	if( "`alias grep`" != "" ) then
		set original_grep="`alias grep`";
		unalias grep;
	endif
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	#alias ${download_command} "${download_command_with_options}";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --continue --quiet --output-document";
	#alias ${download_command} "${download_command_with_options}";
	
	alias ex "ex -E -X -n --noplugin";
	
	set label_current="init";
	goto callback_stack_update;
#goto setup;


exit_script:
	onintr scripts_main_quit;
	
	set label_current="exit_script";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ${?arg} ) \
		unset arg;
	
	if( ${?filename_list} ) then
		if(! ${?supports_multiple_files} ) then
			@ errno=-505;
			goto exception_handler;
		endif
		
		set callback="filename_list_post_process";
		goto callback_handler;
	endif
	
	set callback="scripts_main_quit";
	goto callback_handler;
#exit_script:


scripts_main_quit:
	set label_current="scripts_main_quit";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ${?confirmation} ) \
		unset confirmation;
	if( ${?disable_interupt_prompt} ) \
		unset disable_interupt_prompt;
	
	if( ${?supports_multiple_files} ) then
		if( ${?filename_list} ) then
			set callback="filename_list_post_process";
			goto callback_handler
		endif
		unset supports_multiple_files;
	else if( ${?filename_list} ) then
		@ errno=-505;
		goto exception_handler;
	endif
	
	if( ${?file_count_all} ) \
		unset file_count_all;
	if( ${?filenames_processed} ) \
		unset filenames_processed;
	if( ${?file_count} ) \
		unset file_count;

	
	if( ${?diagnosis} ) then
		set callback="diagnosis";
		goto callback_handler;
	endif
	
	if( ${?minimum_options} ) \
		unset minimum_options;
	if( ${?meximum_options} ) \
		unset meximum_options;
	if( ${?argc} ) \
		unset argc;
	
	if( ${?arg} ) \
		unset arg;
	if( ${?escaped_argument} ) \
		unset escaped_argument;
	if( ${?argument} ) \
		unset argument;
	if( ${?dashes} ) \
		unset dashes;
	if( ${?option} ) \
		unset option;
	if( ${?equals} ) \
		unset equals;
	if( ${?value} ) \
		unset value;
	if( ${?escaped_value} ) \
		unset escaped_value;
	
	if( ${?escaped_test_argument} ) \
		unset escaped_test_argument;
	if( ${?test_argument} ) \
		unset test_argument;
	if( ${?test_dashes} ) \
		unset test_dashes;
	if( ${?test_option} ) \
		unset test_option;
	if( ${?test_equals} ) \
		unset test_equals;
	if( ${?test_value} ) \
		unset test_value;
	
	if( ${?parsed_arg} ) \
		unset parsed_arg;
	if( ${?parsed_argv} ) \
		unset parsed_argv;
	if( ${?parsed_argc} ) \
		unset parsed_argc;
	
	if( ${?reading_stdin} ) \
		unset reading_stdin;
	if( ${?stdin_read} ) \
		unset stdin_read;
	
	if( ${?argument} ) \
		unset argument;
	if( ${?argument_file} ) then
		if( -e "${argument_file}" ) \
			rm -f "${argument_file}";
		unset argument_file;
	endif
	
	if( ${?directory_file} ) then
		if( -e "${directory_file}" ) \
			rm -f "${directory_file}";
		unset directory_file;
	endif
	
	if( ${?value_file} ) then
		if( -e "${value_file}" ) \
			rm -f "${value_file}";
		unset value_file;
	endif
	
	if( ${?find_result_file} ) then
		if( -e "${find_result_file}" ) \
			rm -f "${find_result_file}";
		unset find_result_file;
	endif
	
	if( ${?being_sourced} ) \
		unset being_sourced;
	if( ${?supports_being_sourced} ) \
		unset supports_being_sourced;
	
	if( ${?script} ) \
		unset script;
	if( ${?scripts_alias} ) \
		unset scripts_alias;
	if( ${?scripts_basename} ) \
		unset scripts_basename;
	if( ${?scripts_dirname} ) \
		unset scripts_dirname;
	
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
	if( ${?nodeps} ) \
		unset nodeps;
	if( ${?dependency} ) \
		unset dependency;
	if( ${?dependencies} ) \
		unset dependencies;
	if( ${?missing_dependency} ) \
		unset missing_dependency;
	if( ${?execs} ) \
		unset execs;
	
	if( ${?usage_message} ) \
		unset usage_message;
	if( ${?usage_displayed} ) \
		unset usage_displayed;
	if( ${?no_exit_on_usage} ) \
		unset no_exit_on_usage;
	if( ${?last_exception_handled} ) \
		unset last_exception_handled;
	
	if( ${?label_current} ) \
		unset label_current;
	if( ${?label_previous} ) \
		unset label_previous;
	if( ${?labels_previous} ) \
		unset labels_previous;
	
	if( ${?callback} ) \
		unset callback;
	if( ${?last_callback} ) \
		unset last_callback;
	if( ${?callback_stack} ) \
		unset callback_stack;
	
	if( ${?argc_required} ) \
		unset argc_required;
	if( ${?arg_shifted} ) \
		unset arg_shifted;
	
	if( ${?current_cwd} ) \
		unset current_cwd;
	if( ${?escaped_cwd} ) \
		unset escaped_cwd;
	if( ${?escaped_home_dir} ) \
		unset escaped_home_dir;
	if( ${?escaped_starting_cwd} ) \
		unset escaped_starting_cwd;
	
	if( ${?starting_cwd} ) then
		if( "${starting_cwd}" != "${cwd}" ) \
			cd "${starting_cwd}";
		unset starting_cwd;
	endif
	
	if( ${?old_owd} ) then
		if( "${old_owd}" != "${owd}" ) \
			set owd="${old_owd}";
		unset old_owd;
	endif
	
	if( ${?starting_owd} ) then
		if( "${starting_owd}" != "${owd}" ) \
			set owd="${starting_owd}";
		unset starting_owd;
	endif
	
	if( ${?original_cwdcmd} ) then
		alias cwdcmd "${original_cwdcmd}";
		unset original_cwdcmd;
	endif
	
	if( ${?grep_options} ) then
		setenv GREP_OPTIONS "${grep_options}";
		unset grep_options;
	endif
	
	if( ${?original_grep} ) then
		alias grep "${original_grep}";
		unset original_grep;
	endif
	
	if( ${?scripts_supported_extensions} ) \
		unset scripts_supported_extensions;
	if( ${?supports_hidden_files} ) \
		unset supports_hidden_files;
	
	if( ${?debug} ) \
		unset debug;
	if( ${?debug_stdin} ) \
		unset debug_stdin;
	if( ${?debug_logged} ) \
		unset debug_logged;
	if( ${?debug_dependencies} ) \
		unset debug_dependencies;
	if( ${?debug_arguments} ) \
		unset debug_arguments;
	if( ${?debug_filenames} ) \
		unset debug_filenames;
	if( ${?scripts_diagnosis_log} ) \
		unset scripts_diagnosis_log;
	
	if( ${?original_filename} ) \
		unset original_filename;
	if( ${?filename} ) \
		unset filename;
	if( ${?extension} ) \
		unset extension;
	if( ${?filename_for_exec} ) \
		unset filename_for_exec;
	if( ${?filename_for_regexp} ) \
		unset filename_for_regexp;
	if( ${?filename_for_editor} ) \
		unset filename_for_editor;
	if( ${?grep_test} ) \
		unset grep_test;
	
	if( ${?strict} ) \
		unset strict;
	if( ${?arg_shifted} ) \
		unset arg_shifted;
	if( ${?value_used} ) \
		unset value_used;
	if( ${?dashes} ) \
		unset dashes;
	if( ${?option} ) \
		unset option;
	if( ${?equals} ) \
		unset equals;
	if( ${?value} ) \
		unset value;
	if( ${?argv_parsed} ) \
		unset argv_parsed;
	
	if( ${?stdout} ) \
		unset stdout;
	if( ${?stderr} ) \
		unset stderr;
	
	if(! ${?errno} ) \
		@ errno=0;
	
	@ status=$errno;
	exit ${errno}
#set callback="scripts_main_quit";
#goto callback_handler;


init:
	set label_current="init";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	set starting_owd="${owd}";
	set starting_cwd="${cwd}";
	set escaped_starting_cwd="${escaped_cwd}";
	
	set directory_file="${scripts_tmpdir}/.escaped.dir.`date '+%s'`.file";
	printf "%s" "${HOME}" >! "${directory_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${directory_file}";
	set escaped_home_dir="`cat "\""${directory_file}"\"" | sed -r 's/([\[\/])/\\\1/g'`";
	rm -f "${directory_file}";
	unset directory_file;
#set callback="init";
#goto callback_handler;


debug_check:
	set label_current="debug_check";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	@ arg=0;
	@ argc=${#argv};
	
	if( ${?minimum_options} ) then
		if( ${minimum_options} > 0 && ${argc} < ${minimum_options} ) then
			@ errno=-503;
			goto exception_handler;
		endif
	endif
	
	if( ${?maximum_options} ) then
		if( ${maximum_options} > 0 && ${argc} > ${maximum_options} ) then
			@ errno=-504;
			goto exception_handler;
		endif
	endif
	
	while( $arg < $argc )
		@ arg++;
		
		switch( "$argv[${arg}]" )
			case "<":
				if(! ${?auto_read_stdin} ) \
					set auto_read_stdin;
			continue;
			
			case "<!":
				if( ${?auto_read_stdin} ) \
					unset auto_read_stdin;
			continue;
			
			case "-":
				if(! ${?scripts_interactive} ) \
					set scripts_interactive;
			continue;
			
			case "-!":
				if( ${?scripts_interactive} ) \
					unset scripts_interactive;
			continue;
			
			case "--":
				if(! ${?process_each_filename} ) \
					set process_each_filename;
			continue;
			
			case "--!":
				if( ${?process_each_filename} ) \
					unset process_each_filename;
			continue;
		endsw
		
		if( -e "$argv[${arg}]" ) \
			continue;
		
		set argument_file="${scripts_tmpdir}/.escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg";
		printf "%s" "$argv[${arg}]" >! "${argument_file}";
		ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
		set escaped_argument="`cat "\""${argument_file}"\""`";
		rm -f "${argument_file}";
		unset argument_file;
		set argument="`printf "\""%s"\"" "\""${escaped_argument}"\""`";
		
		set option="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
		if( "${option}" == "${argument}" ) \
			set option="";
		
		set value="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
		if( -e "${value}" ) \
			continue;
		
		if( ${?debug} || ${?debug_arguments} ) \
			printf "**${scripts_basename} debug_check:**"\$"option: [${option}]; "\$"value: [${value}].\n" > ${stdout};
		
		switch("${option}")
			case "h":
			case "help":
				set callback="usage";
				goto callback_handler;
				breaksw;
			
			case "nodeps":
				if( ${?nodeps} ) \
					breaksw;
				
				set nodeps;
				
				if( "${value}" != "" ) \
					set value="";
				
				breaksw;
			
			case "diagnosis":
			case "diagnostic-mode":
				if( ${?diagnosis} ) \
					continue;
				
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode:\t[enabled].\n\n" "${scripts_basename}" ${arg} > ${stdout};
				set diagnosis;
				if(! ${?debug} ) \
					set debug;
				
				if( "${value}" != "" ) \
					set value="";
				
				breaksw;
			
			case "debug":
				switch("${value}")
					case "logged":
						if( ${?debug_logged} ) \
							continue;
						
						set debug_logged;
						breaksw;
					
					case "dependencies":
						if( ${?debug_dependencies} ) \
							continue;
						
						set debug_dependencies;
						breaksw;
					
					case "arguments":
						if( ${?debug_arguments} ) \
							continue;
						
						set debug_arguments;
						breaksw;
					
					case "stdin":
						if( ${?debug_stdin} ) \
							continue;
						
						set debug_stdin;
						breaksw;
					
					case "filenames":
						if(! ${?supports_multiple_files} ) then
							printf "**%s notice:** does not support handling or processing multiple files.\n" "${scripts_basename}" > ${stderr};
							printf "**%s notice:**, via "\$"argv[%d], debugging %s:\t[unsupported].\n" "${scripts_basename}" ${arg} "${value}" > ${stderr};
							continue;
						endif
						
						if( ${?debug_filenames} ) \
							continue;
						
						set debug_filenames;
						breaksw;
					
					default:
						if( ${?debug} ) \
							continue;
						
						if( "${value}" != "" ) \
							set value="";
						
						set debug;
						breaksw;
				endsw
			default:
				continue;
		endsw
		
		printf "**%s notice:**, via "\$"argv[%d], %s mode" "${scripts_basename}" ${arg} "${option}" > ${stdout};
		if( "${value}" != "" ) \
			printf " %s" "${value}" > ${stdout};
		
		if( "${option}" == "debug" ) \
			printf " debugging" > ${stdout};
		
		printf ":\t[enabled].\n\n" > ${stdout};
	end
	
	set callback="dependencies_check";
	goto callback_handler;
#set callback="debug_check";
#goto callback_handler;


dependencies_check:
	set label_current="dependencies_check";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ! ${?debug} && ${?debug_dependencies} ) \
		set debug debug_set;
	
	set dependencies=("${scripts_basename}" "find" "sed" "ex");# "${scripts_alias}");
	@ dependencies_index=0;
	
	set callback="dependency_check";
	goto callback_handler;
#set callback="dependencies_check";
#goto callback_handler;


dependency_check:
	set label_current="dependency_check";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		
		if( ${?nodeps} && $dependencies_index > 1 ) then
			set callback="dependencies_check_complete";
			goto callback_handler;
		endif
		
		set dependency=$dependencies[$dependencies_index];
		if( ${?debug} ) \
			printf "\n**${scripts_basename} debug:** looking for dependency: ${dependency}.\n\n" > ${stdout};
			
		foreach program("`where '${dependency}'`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		if(! ${?program} ) then
			@ errno=-501;
			goto exception_handler;
		endif
		
		if( ${?debug} ) then
			switch(`printf "%d" "${dependencies_index}" | sed -r 's/^[0-9]*[^1]?([0-9])$/\1/'` )
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
			
			printf "**%s debug:** %d%s dependency: %s ( binary: %s )\t[found]\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${program}" > ${stdout};
			unset suffix;
		endif
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?scripts_dirname} ) \
					breaksw;
				
			if( ${?debug} ) \
				printf "\n**${scripts_basename} debug:** looking for dependency: ${dependency}.\n\n" > ${stdout};
				set old_owd="${cwd}";
				cd "`dirname '${program}'`";
				set scripts_dirname="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_dirname}/${scripts_basename}";
				breaksw;
			
			default:
				if(! ${?execs} ) \
					set execs=()
				set execs=(${execs} "${program}");
				breaksw;
		endsw
		
		unset program;
	end
	
	set callback="dependencies_check_complete";
	goto callback_handler;
#set callback="dependency_check";
#goto callback_handler;


dependencies_check_complete:
	set label_current="dependencies_check_complete";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ${?debug_set} ) \
		unset debug;
	
	unset dependency dependencies dependencies_index;
	
	set callback="parse_argv_init";
	goto callback_handler;
#set callback="dependencies_check_complete";
#goto callback_handler;


if_sourced:
	set label_current="if_sourced";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	@ errno=0;
	
	if( ${?0} ) then
		set callback="main";
	else if( ${?supports_being_sourced} ) then
		set callback="sourcing_main";
	else
		@ errno=-502;
		goto exception_handler;
	endif
	
	if(! ${?filenames_processed} ) then
		if(! ${?filename_list} ) \
			set filename_list="${scripts_tmpdir}/.filenames.${scripts_basename}.@`date '+%s'`";
		
		if(! -e "${filename_list}" ) then
			if(!( ${?scripts_interactive} || ${?auto_read_stdin} )) then
				@ errno=-506;
				goto exception_handler;
			endif
			
			set callback="read_stdin_init";
			goto callback_handler;
		endif
	endif
	
	if(! ${?filename_list} ) \
		set filename_list="${scripts_tmpdir}/.filenames.${scripts_basename}.@`date '+%s'`";
	
	if(! -e "${filename_list}" ) then
		set callback="exit_script";
		goto callback_handler;
	endif
	
	cat "${filename_list}" | sort | uniq > "${filename_list}.swp";
	mv -f "${filename_list}.swp" "${filename_list}";
	#ex -s '+1,$s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${filename_list}";
	if(! -e "${filename_list}.all" ) then
		#cp -f "${filename_list}" "${filename_list}.all";
	else
		#cat "${filename_list}" >> "${filename_list}.all";
	endif
	
	goto callback_handler;
	# END: disable source scripts_basename.
#set callback="if_sourced";
#goto callback_handler;


sourcing_main:
	set label_current="sourcing_main";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	set callback="sourcing_exec";
	goto callback_handler;
#set callback="sourcing_main";
#goto callback_handler;


sourcing_exec:
	set label_current="sourcing_exec";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	# START: special handler for when this file is sourced.
	if( ${?debug} ) \
		printf "Setting up aliases so [%s]; executes: <file://%s>.\n" "${scripts_alias}" "${script}";
	
	alias "${scripts_alias}" "${script}";
	# FINISH: special handler for when this file is sourced.
	
	set callback="exit_script";
	goto callback_handler;
#set callback="sourcing_exec";
#goto callback_handler;


main:
	set label_current="main";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	printf "Executing ${scripts_basename}'s main.\n" > ${stdout};
	
	onintr exec_interupted;
	
	if(!( ${?filename_list} && ${?supports_multiple_files} )) then
		set callback="exec";
	else if( ${?filename_list} && ! ${?supports_multiple_files} ) then
		@ errno=-505;
		goto exception_handler;
	else if( ${?filename_list} && ${?supports_multiple_files} ) then
		if( -e "${filename_list}.all" ) then
			set file_count="`wc -l "\""${filename_list}.all"\"" | sed -r 's/^([0-9]+)(.*)"\$"/\1/'`";
		else if( -e "${filename_list}" ) then
			set file_count="`wc -l "\""${filename_list}"\"" | sed -r 's/^([0-9]+)(.*)"\$"/\1/'`";
		else if( ${?original_filename} ) then
			if( -e "`printf "\""%s"\"" "\""${original_filename}"\""`" ) then
				if(! ${?file_count} ) then
					@ file_count=1;
				else
					set file_count="`printf "\""%d+1\n"\"" ${file_count} | bc`";
				endif
			endif
		endif
		if(! ${?file_count} ) \
			@ file_count=0;
		
		if(!( ${file_count} > 0 )) then
			@ errno=-506;
			goto exception_handler;
		endif
	else if(!( ${?scripts_interactive} || ${?auto_read_stdin} )) then
		@ errno=-999;
		set callback="exit_script";
		goto exception_handler;
	endif
	
	set callback="exec";
	goto callback_handler;
#set callback="main";
#goto callback_handler;


read_stdin_init:
	set label_current="read_stdin_init";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if(!( ${?scripts_interactive} || ${?auto_read_stdin} )) then
		set callback="exit_script";
		goto callback_handler;
	endif
	
	if( ( ${?debug_options} || ${?debug_stdin} ) && ! ${?debug} ) \
		set debug debug_set;
	
	if(! ${?filename_list} ) \
		set filename_list="${scripts_tmpdir}/.filenames.${scripts_basename}.@`date '+%s'`";
	
	if(! -e "${filename_list}" ) \
		touch "${filename_list}";
	
	set reading_stdin;
	
	if(! ${?stdin_read} ) then
		set callback="read_stdin";
	else
		set callback="exit_script";
	endif
	goto callback_handler;
#set callback="read_stdin_init";
#goto callback_handler;


read_stdin:
	set label_current="read_stdin";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	set value="$<";
	#set value=$<:q;
	set value_file="${scripts_tmpdir}/.escaped.${scripts_basename}.stdin.value.`date '+%s'`.arg";
	printf "%s" "$value" >! "${value_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
	set escaped_value="`cat "\""${value_file}"\""`";
	rm -f "${value_file}";
	unset value_file;
	set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
	unset escaped_value;
	
	while( "${value}" != "" )
		if( ${?debug} ) \
			printf "Processing stdin value: [%s].\n" "${value}";
		
		switch("${value}")
			default:
				if( -e "${value}" && ${?supports_multiple_files} ) then
					set callback="filename_list_append_value";
					goto callback_handler;
				endif
				
				@ errno=-498;
				set callback="read_stdin";
				goto exception_handler;
			breaksw;
		endsw
	end
	unset value;
	
	set callback="read_stdin_quit";
	goto callback_handler;
#set callback="read_stdin";
#goto callback_handler;


read_stdin_quit:
	set label_current="read_stdin_quit";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ${?reading_stdin} ) \
		unset reading_stdin;
	
	set stdin_read;
	
	if( ${?debug_set} ) \
		unset debug debug_set;
	
	if( ${?filename_list} ) then
		if( -e "${filename_list}.all" ) then
			set file_count="`wc -l "\""${filename_list}.all"\"" | sed -r 's/^([0-9]+)(.*)"\$"/\1/'`";
		endif
	endif
	
	set callback="if_sourced";
	goto callback_handler;
#set callback="read_stdin_quit";
#goto callback_handler;


exec_interupted:
	set label_current="exec_interupted";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	onintr exit_script;
	if( ${?original_filename} ) then
		printf "\n\tProcessing: <file://%s>\t[cancelled]\n\n" "`printf "\""%s"\"" "\""${original_filename}"\""`" > ${stdout};
	endif
	
	if( ! ${?reading_stdin} && ! ${?disable_interupt_prompt} ) then
		printf "\tWould you like %s to continue? [Yes/No/Always]" "${scripts_basename}" > ${stdout};
		set confirmation="$<";
		#set rconfirmation=$<:q;
		printf "\n";
		
		switch(`printf "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
			case "n":
				printf "\t[%s] will now exit\n" "${scripts_basename}" > ${stdout};
				set callback="exit_script";
				goto callback_handler;
				breaksw;
			
			case "a":
				set disable_interupt_prompt;
			case "y":
			default:
				unset confirmation;
				breaksw;
		endsw
	else
		sleep 2;
	endif
	
	set callback="filename_next";
	goto callback_handler;
#exec_interupted;

exec:
	set label_current="exec";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	onintr exec_interupted;
	
	if( ${?original_filename} ) \
		printf "\t" > ${stdout};
	
	printf "Executing ${scripts_basename}'s exec.\n" > ${stdout};
	
	if( ${?filename_list} && ! ${?supports_multiple_files} ) then
		@ errno=-505;
		goto exception_handler;
	endif
	
	if(! ${?filename_list} ) \
		set filename_list="${scripts_tmpdir}/.filenames.${scripts_basename}.@`date '+%s'`";
	
	if(! -e "${filename_list}" ) \
		touch "${filename_list}";
	
	if( -e "${filename_list}.all" && ${?original_filename} ) then
		@ line=0;
		foreach filename_old( "`cat "\""${filename_list}.all"\""`")# | sed -r 's/(["\"\$\!\`"])/"\""\\"\\1""\""/g'`" )# | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`" )
			@ line++;
			if( "${original_filename}" == "${filename_old}" ) then
				printf "\n\t**Skipping:** <file://%s> its already been processed.\n\n" "${filename_old}";
				ex -s "+${line}d" '+wq!' "${filename_list}";
				unset original_filename;
				break;
			endif
			unset filename_old;
		end
		unset line;
	endif
	
	if(! ${?original_filename} ) then
		set callback="filename_next";
		goto callback_handler;
	endif
	
	if(! ${?filenames_processed} ) \
		@ filenames_processed=0;
	
	@ filenames_processed++;
	if( ${?process_each_filename} ) \
		set file_count="`printf "\""%d+1\n"\"" ${file_count} | bc`";
	printf "\tProcessing: <file://%s>" "`printf "\""%s"\"" "\""${original_filename}"\""`" > ${stdout};
	if( ${?file_count} ) then
		if( ${file_count} > 1 ) \
			printf " ( file #%d out of %d )" ${filenames_processed} ${file_count} > ${stdout};
	endif
	printf "\t[started]\n" > ${stdout};
	set extension="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/^(.*)(\.[^\.]+)"\$"/\2/g'`";
	if( "${extension}" == "`printf "\""${original_filename}"\""`" ) \
		set extension="";
	set original_extension="${extension}";
	set filename="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/^(.*)(\.[^\.]+)"\$"/\1/g'`";
	if(! -e "${filename}${extension}" ) then
		@ errno=-301;
		set callback="filename_next";
		goto exception_handler;
	endif
	
	if(! -e "${filename_list}.all" ) \
		touch "${filename_list}.all";
	printf "%s%s\n" "${filename}" "${extension}" >> "${filename_list}.all";
	
	set filename_for_exec="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	set filename_for_regexp="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/([\ \\\*\[\/.])/\\\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	set filename_for_editor="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/(["\"\$\!"'\''\[\]\(\)\ \<\>])/\\\1/g'`";
	if( ${?edit_all_files} ) \
		${EDITOR} "+0r ${filename_for_editor}";
	
	
	if( -d "${filename}${extension}" ) then
		printf "\n\tDirectory" > ${stdout};
	else if( -l "${filename}${extension}" ) then
		printf "\n\tSymbolic link" > ${stdout};
	else
		printf "\n\tFile" > ${stdout};
	endif
	printf " data of: <file://%s%s>\n\t\t%s\n" "${filename}" "${extension}" "`/bin/ls -d -l "\""${filename_for_exec}"\"" | grep -v --perl-regexp '^[\s\ \t\r\n]+"\$"'`" > ${stdout};
	
	set grep_test="`grep "\""^${filename_for_regexp}"\"\$" "\""${filename_list}.all"\""`";
	printf "\tgrep " > ${stdout};
	if( "${grep_test}" != "" ) then
		printf "found:\n\t\t${grep_test}\n" > ${stdout};
	else
		printf "couldn't find:\n\t\t${filename}${extension}.\n" > ${stdout};
	endif
	printf "\n" > ${stdout};
	
	printf "\tProcessing: <file://%s>\t[finished]\n" "`printf "\""%s"\"" "\""${original_filename}"\""`" > ${stdout};
	unset original_filename filename extension;
	unset filename_for_exec filename_for_regexp filename_for_editor;
	unset grep_test;
	
	set callback="filename_next";
	goto callback_handler;
#set callback="exec";
#goto callback_handler;


filename_next:
	set label_current="filename_next";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if(!( ${?filename_list} && ${?supports_multiple_files} )) then
		@ errno=-505;
		goto exception_handler;
	endif
	
	if(! -e "${filename_list}.all" ) \
		cp "${filename_list}" "${filename_list}.all";
	
	foreach original_filename("`cat "\""${filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
		ex -s '+1d' '+wq!' "${filename_list}";
		if( "${original_filename}" == "" ) \
			continue;
		
		if(! -e "`printf "\""%s"\"" "\""${original_filename}"\""`" ) then
			@ errno=-302;
			set callback="filename_next";
			goto exception_handler;
		endif
		
		set callback="exec";
		goto callback_handler;
	end
	rm -f "${filename_list}";
	
	if(! ${?reading_stdin} ) then
		if( ${?arg} && ${?process_each_filename} ) then
			if( $arg < $argc ) then
				set callback="parse_argv";
			else
				set callback="parse_argv_quit";
			endif
		else if(! ${?argv_parsed} ) then
			set callback="parse_argv_quit";
		else if( ${?scripts_interactive} || ${?auto_read_stdin} ) then
			set callback="read_stdin_init";
		endif
	else if(!( ${?scripts_interactive} || ${?auto_read_stdin} )) then
		@ errno=-505;
		goto exception_handler;
	else if( ${?reading_stdin} ) then
		set callback="read_stdin";
	else if(! ${?stdin_read} ) then
		set callback="read_stdin_quit";
	else
		set callback="exit_script";
	endif
	goto callback_handler;
#set callback="filename_next";
#goto callback_handler;

filename_list_post_process:
	set label_current="filename_list_post_process";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if(!( ${?filename_list} && ${?supports_multiple_files} )) then
		@ errno=-505;
		goto exception_handler;
	endif
	
	#unset supports_multiple_files;
	
	if( -e "${filename_list}.all" ) \
		set file_count_all="`wc -l "\""${filename_list}.all"\"" | sed -r 's/^([0-9]+)(.*)"\$"/\1/'`";
	if( -e "${filename_list}" ) \
		set file_count="`wc -l "\""${filename_list}"\"" | sed -r 's/^([0-9]+)(.*)"\$"/\1/'`";
	if( ${?file_count_all} && ${?file_count} ) then
		if( ${?file_count_all} != ${?file_count} ) then
			cat "${filename_list}.all" >> "${filename_list}";
			#set file_count="`wc -l "\""${filename_list}.all"\"" | sed -r 's/^([0-9]+)(.*)"\$"/\1/'`";
			set file_count="`printf "\""%d+%d\n"\"" ${file_count_all} ${file_count}`";
		endif
	else if(! ${?file_count} ) then
		@ file_count=0;
	endif
	
	if( ${?file_count_all} ) \
		unset file_count_all;
	
	if(! ${?filenames_processed} ) \
		@ filenames_processed=0;
	
	if(!( ${file_count} > 0 && ${filenames_processed} > 0 )) then
		@ errno=-497;
		goto exception_handler;
	endif
	
	printf "Post-Processing %s's processed %d out of %d files\t[" "${scripts_basename}" ${filenames_processed} ${file_count} > ${stdout};
	
	if( ${filenames_processed} != ${file_count} ) then
		printf "failed]]\n\t\t\t\t\t\t[only %d out %d files where" ${filenames_processed} ${file_count} > ${stdout};
	else
		# any post processing that's only to be done
		# after the filename_list has been fully processed.
		printf "finished" > ${stdout};
	endif
	
	printf "]\n" > ${stdout};
	
	unset filenames_processed file_count;
	
	if( -e "${filename_list}" ) \
		rm -f "${filename_list}";
	if( -e "${filename_list}.all" ) \
		rm -f "${filename_list}.all";
	unset filename_list;
	
	set callback="exit_script";
	goto callback_handler;
#set callback="filename_list_post_process";
#goto callback_handler;


usage:
	set label_current="usage";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ${?errno} ) then
		if( ${errno} != 0 ) then
			if(! ${?last_exception_handled} ) \
				@ last_exception_handled=0;
			if( ${last_exception_handled} != ${errno} ) then
				if(! ${?callback} ) \
					set callback="usage";
				goto exception_handler;
			endif
		endif
	endif
	
	if(!( ${?script} && ${?program} )) then
		printf "${usage_message}\n" > ${stdout};
	else
		if( "${program}" != "${script}" ) then
			${program} --help;
		else
			printf "${usage_message}\n" > ${stdout};
		endif
	endif
	
	if(! ${?usage_displayed} ) \
		set usage_displayed;
	
	if(!( ${?no_exit_on_usage} && ${?callback} )) \
		set callback="exit_script";
	
	goto callback_handler;
#set callback="$!";
#goto usage;


exception_handler:
	set label_current="exception_handler";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if(! ${?errno} ) \
		@ errno=-999;
	
	if( $errno < -400 && ${?strict} ) then
		if( ${?exit_on_exception} ) \
			set exit_on_exception;
	else if( $errno > -400 && $errno < -100 ) then
		if( ${?exit_on_exception} ) then
			set exit_on_exception_unset;
			unset exit_on_exception;
		endif
	endif
	
	if( $errno > -400 ) \
		printf "\t" > ${stderr};
	printf "**%s error("\$"errno:%d):**\n\t" "${scripts_basename}" ${errno} > ${stderr};
	switch( $errno )
		case -300:
			printf "Cannot process: <file://%s> is an unsupported file" "${value}" > ${stderr};
			unset value;
			breaksw;
		
		case -301:
			printf "Skipping:\n\t\t<file://%s%s>\n\t\t\tit no longer exists\t[skipped]" "${scripts_basename}" "${filename}" "${extension}" > ${stderr};
			unset filename extension;
			breaksw;
		
		case -302:
			printf "Cannot process:\n\t\t<file://%s>\n\t\t\tit no longer exists\t[skipped]" "${original_filename}" > ${stderr};
			unset original_filename;
			breaksw;
		
		case -497:
			printf "No files have been processed" > ${stderr};
			if( ${?filename_list} ) then
				if( -e "${filename_list}" ) \
					rm -f "${filename_list}";
				if( -e "${filename_list}.all" ) \
					rm -f "${filename_list}.all";
				unset filename_list;
			endif
			breaksw;
		
		case -498:
			printf "The value/file specified: <%s> is invalid and cannot be processed\t[stdin failed]" "${value}" > ${stderr};
			unset file;
			breaksw;
		
		case -499:
			printf "${dashes}${option}${equals}${value} is an unsupported option" > ${stderr};
			unset dashes option equals value;
			breaksw;
		
		case -500:
			printf "diagnostic mode has completed.\n\tFor detailed information please see all above output and the diagnosis log:\n\t<file://%s>" "${scripts_diagnosis_log}" > ${stderr};
			breaksw;
		
		case -501:
			printf "One or more of [%s] dependencies couldn't be found.\n\t%s requires: [%s] and [%s] couldn't be found." "${scripts_basename}" "${dependencies}" "${scripts_basename}" "${dependency}" > ${stderr};
			breaksw;
		
		case -502:
			printf "Sourcing is not supported. ${scripts_basename} may only be executed" > ${stderr};
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided" > ${stderr};
			breaksw;
		
		case -504:
			printf "To many options have been provided" > ${stderr};
			breaksw;
		
		case -505:
			printf "handling and/or processing multiple files isn't supported" > ${stderr};
			if( ${?filename_list} ) then
				if( -e "${filename_list}" ) \
					rm -f "${filename_list}";
				if( -e "${filename_list}.all" ) \
					rm -f "${filename_list}.all";
				unset filename_list;
			endif
			breaksw;
		
		case -506:
			printf "No processable file have been provide, nor could any be found" > ${stderr};
			if(!( ${?scripts_interactive} || ${?auto_read_stdin} )) then
				printf ".\n\t\tRun: "\`"%s -"\`" or "\`"%s "\""<"\"\`" if you want to pipe options into this script" "${scripts_basename}" "${scripts_basename}" > ${stderr};
			else
				set callback="filename_next";
				if( ${?exit_on_exception} ) \
					unset exit_on_exception;
			endif
			if( ${?filename_list} ) then
				if( -e "${filename_list}" ) \
					rm -f "${filename_list}";
				if( -e "${filename_list}.all" ) \
					rm -f "${filename_list}.all";
				unset filename_list;
			endif
			breaksw;
		
		case -602:
			printf "${dashes}${option} must be followed by a valid number greater than zero" > ${stderr};
			breaksw;
		
		case -603:
			printf "Invalid length specified for: [${dashes}${option}]: ${value} must be formatted as: 'hh:mm:ss'" > ${stderr};
			breaksw;
		
		case -604:
			printf "%s %s is not supported" "`printf "\""%s"\"" "\""${option}"\"" | sed -r 's/^(.*)e"\$"/\1ing/`" "${value}" "${scripts_basename}" > ${stderr};
			breaksw;
		
		case -901:
			printf "initialization was not completed correctly.  Please make sure label_starck_set is called at the beginning of the script." > ${stderr};
			breaksw;
		
		case -999:
		default:
			printf "An internal script error has caused an exception.  Please see any output above" > ${stderr};
			breaksw;
	endsw
	printf ".\n\n" > ${stderr};
	@ last_exception_handled=$errno;
	printf "\tPlease see: "\`"${scripts_basename} --help"\`" for more information and supported options.\n" > ${stderr};
	if(! ${?debug} ) \
		printf "\tOr run: "\`"${scripts_basename} --debug"\`" to diagnose where ${scripts_basename} failed.\n" > ${stderr};
	printf "\n" > ${stderr};
	
	if( ! ${?callback} || ${?exit_on_exception} ) \
		set callback="exit_script";
	
	if( ${?exit_on_exception_unset} ) then
		unset exit_on_exception_unset;
		set exit_on_exception;
	endif
	
	goto callback_handler;
#goto exception_handler;


parse_argv_init:
	set label_current="parse_argv_init";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	@ argc=${#argv};
	@ arg=0;
	@ parsed_argc=0;
	
	if( ( ${?debug_options} || ${?debug_arguments} ) && ! ${?debug} ) \
		set debug debug_set;
	
	if( ${?debug} ) \
		printf "**${scripts_basename} debug:** checking argv.  ${argc} total arguments.\n\n" > ${stdout};
	
	set callback="parse_argv";
	goto callback_handler;
#set callback="parse_argv_init";
#goto callback_handler;


parse_argv:
	set label_current="parse_argv";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	while( $arg < $argc )
		if(! ${?arg_shifted} ) then
			@ arg++;
		else
			if( ${?value_used} ) \
				@ arg++;
			unset arg_shifted;
		endif
		
		if( ${?value_used} ) \
			unset value_used;
		
		if( ${?debug} ) \
			printf "**%s parse_argv:** Checking argv #%d (%s).\n" "${scripts_basename}" ${arg} "$argv[${arg}]" > ${stdout};
		
		switch( "$argv[${arg}]" )
			case "<":
				if(! ${?auto_read_stdin} ) \
					set auto_read_stdin;
			continue;
			
			case "<!":
				if( ${?auto_read_stdin} ) \
					unset auto_read_stdin;
			continue;
			
			case "-":
				if(! ${?scripts_interactive} ) \
					set scripts_interactive;
			continue;
			
			case "-!":
				if( ${?scripts_interactive} ) \
					unset scripts_interactive;
			continue;
			
			case "--":
				if(! ${?process_each_filename} ) \
					set process_each_filename;
			continue;
			
			case "--!":
				if( ${?process_each_filename} ) \
					unset process_each_filename;
			continue;
		endsw
		
		set argument_file="${scripts_tmpdir}/.escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg";
		printf "%s" "$argv[${arg}]" >! "${argument_file}";
		ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
		set escaped_argument="`cat "\""${argument_file}"\""`";
		rm -f "${argument_file}";
		unset argument_file;
		set argument="`printf "\""%s"\"" "\""${escaped_argument}"\""`";
		
		set dashes="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
		if( "${dashes}" == "${argument}" ) \
			set dashes="";
		
		set option="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
		if( "${option}" == "${argument}" ) \
			set option="";
		
		set equals="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
		if( "${equals}" == "${argument}" ) \
			set equals="";
		
		set value="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
		
		if( ${?debug} ) \
			printf "\tparsed "\$"argument: [%s]; "\$"argv[%d] (%s)\n\t\t"\$"dashes: [%s];\n\t\t"\$"option: [%s];\n\t\t"\$"equals: [%s];\n\t\t"\$"value: [%s]\n\n" "${argument}" "${arg}" "$argv[${arg}]" "${dashes}" "${option}" "${equals}" "${value}" > ${stdout};
		
		if(!( "${dashes}" != "" && "${option}" != "" && "${equals}" != "" && "${value}" != "" )) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				if( ${?debug} ) \
					printf "**%s debug:** Looking for replacement value.  Checking argv #%d (%s).\n" "${scripts_basename}" ${arg} "$argv[${arg}]" > ${stdout};
				
				set argument_file="${scripts_tmpdir}/.escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg";
				printf "%s" "$argv[${arg}]" >! "${argument_file}";
				ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
				set escaped_test_argument="`cat "\""${argument_file}"\""`";
				rm -f "${argument_file}";
				unset argument_file;
				set test_argument="`printf "\""%s"\"" "\""${escaped_test_argument}"\""`";
				
				set test_dashes="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
				if( "${test_dashes}" == "${test_argument}" ) \
					set test_dashes="";
				
				set test_option="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
				if( "${test_option}" == "${test_argument}" ) \
					set test_option="";
				
				set test_equals="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
				if( "${test_equals}" == "${test_argument}" ) \
					set test_equals="";
				
				set test_value="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
				
				if( ${?debug} ) \
					printf "\t\tparsed argument for possible replacement value:\n\t\t\t"\$"test_argument: [%s]; "\$"argv[%d] (%s)\n\t\t\t"\$"test_dashes: [%s];\n\t\t\t"\$"test_option: [%s];\n\t\t\t"\$"test_equals: [%s];\n\t\t\t"\$"test_value: [%s]\n\n" "${test_argument}" "${arg}" "$argv[${arg}]" "${test_dashes}" "${test_option}" "${test_equals}" "${test_value}" > ${stdout};
				if(!( "${test_dashes}" == "" && "${test_option}" == "" && "${test_equals}" == "" && "${test_value}" == "${test_argument}" )) then
					@ arg--;
				else
					set equals=" ";
					set value="${test_value}";
					set arg_shifted;
				endif
				unset escaped_test_argument test_argument test_dashes test_option test_equals test_value;
			endif
		endif
		
		if( "${value}" != "" ) then
			set value_file="${scripts_tmpdir}/.escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg";
			printf "%s" "${value}" >! "${value_file}";
			ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
			set escaped_value="`cat "\""${value_file}"\""`";
			rm -f "${value_file}";
			unset value_file;
			set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
		endif
		
		@ parsed_argc++;
		if( "${option}" == "${value}" ) \
			set option="";
		set parsed_arg="${dashes}${option}${equals}${value}";
		if(! ${?parsed_argv} ) then
			set parsed_argv=("${value}");
		else
			set parsed_argv=("${parsed_argv}" "\n" "${value}");
		endif
		
		if( ${?debug} ) \
			printf "\tparsed option "\$"parsed_argv[%d]:\t%s\n\n" ${parsed_argc} "${parsed_arg}" > ${stdout};
		
		switch("${option}")
			case "numbered_option":
				if(!( "${value}" != "" && ${value} > 0 )) then
					@ errno=-602;
					set callback="parse_argv";
					goto exception_handler;
					breaksw;
				endif
			
				set numbered_option="${value}";
				set value_used;
			breaksw;
			
			case "option-array":
				if(! ${?array_options} ) then
					set array_options=("${value}");
				else
					set array_options=( "${array_options}" "\n" "${value}" );
				endif
			breaksw;
			
			case "length_option":
				if( "`printf "\""${escaped_value}"\"" | sed -r 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}"\$"//'`" != "" ) then
					@ errno=-603;
					set callback="parse_argv";
					goto exception_handler;
					breaksw;
				endif
				
				set length="${value}";
				set value_used;
			breaksw;
			
			case "h":
			case "help":
				if( ${?callback} ) \
					unset callback;
				
				goto usage;
			breaksw;
			
			case "verbose":
				if(! ${?be_verbose} ) \
					set be_verbose;
			breaksw;
			
			case "nodeps":
			case "debug":
			case "diagnosis":
			case "diagnostic-mode":
				# these are all caught above. See: [debug_check:]
			breaksw;
			
			case "switch-option":
				switch("${value}")
					case "iv":
					case "verbose":
					case "interactive":
						set switch_option="${dashes}${value}";
						set value_used;
					breaksw;
					
					default:
						set switch_option;
					breaksw;
				endsw
				
				if( ${?debug} ) \
					printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], ${option}:\t[enabled].\n\n" > ${stdout};
			breaksw;
			
			case "enable":
				switch("${value}")
					case "switch-option":
						if( ${?switch_option} ) \
							breaksw;
						
						if( ${?debug} ) \
							printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], ${value} mode:\t[${option}d].\n\n" > ${stdout};
						set switch_option;
					breaksw;
					
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], verbose output:\t[${option}d].\n\n" > ${stdout};
						set be_verbose;
					breaksw;
					
					default:
						@ errno=-604;
						set callback="parse_argv";
						goto exception_handler;
					breaksw;
				endsw
				breaksw;
			
			case "disable":
				switch("${value}")
					case "switch-option":
						if(! ${?switch_option} ) \
							breaksw;
						
						if( ${?debug} ) \
							printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], ${value} mode:\t[${option}d].\n\n" > ${stdout};
						unset switch_option;
					breaksw;
					
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], verbose output:\t[${option}d].\n\n" > ${stdout};
						unset be_verbose;
					breaksw;
					
					default:
						@ errno=-604;
						set callback="parse_argv";
						goto exception_handler;
					breaksw;
				endsw
			breaksw;
			
			case "":
			default:
				if( -e "${value}" && ${?supports_multiple_files} ) then
					set value_used;
					set callback="filename_list_append_value";
					goto callback_handler;
					breaksw;
				endif
				
				if(! ${?strict} ) then
					if(! ${?exit_on_exception} ) \
						set exit_on_exception;
					set callback="parse_argv";
				else if( ${?exit_on_exception} ) then
					unset exit_on_exception;
					set exit_on_exception_unset;
				endif
				
				@ errno=-499;
				set callback="parse_argv";
				goto exception_handler;
			breaksw;
		endsw
		
		if( ${?arg_shifted} ) then
			if(! ${?value_used} ) \
				@ arg--;
			unset arg_shifted;
		endif
		
		if( ${?value_used} ) \
			unset value_used;
		
		unset escaped_argument argument dashes option equals escaped_value value parsed_arg;
	end
	
	set callback="parse_argv_quit";
	goto callback_handler;
#set callback="parse_argv";
#goto callback_handler;


parse_argv_quit:
	set label_current="parse_argv_quit";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ${?debug_set} ) \
		unset debug debug_set;
	
	if( ${?arg} ) then
		if( $arg >= $argc ) \
			set argv_parsed;
		unset arg;
	endif
	
	#if( ${?parsed_argc} && ${?parsed_argv} ) then
	#	if( ${parsed_argc} > 0 ) then
	# 		set parsed_argv_file="${scripts_tmpdir}/.escaped.parsed_argv.${scripts_basename}.`date '+%s'`";
	#		printf "%s" "$parsed_argv" >! "${parsed_argv_file}";
	#		ex -s '+1,$s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${parsed_argv_file}";
	#		set escaped_parsed_argv="`cat "\""${parsed_argv_file}"\""`";
	#		@ parsed_argc=0;
	#		foreach parsed_arg("`cat "\""${parsed_argv_file}"\""`")
	#			@ parsed_argc++;
	#			if(! ${?parsed_argv} ) then
	#				set parsed_argv=("`printf "\""${parsed_arg}"\""`");
	#			else
	#				set parsed_argv=("${parsed_argv}" "`printf "\""${parsed_arg}"\""`");
	#			endif
	#		end
	#		rm -f "${parsed_argv_file}";
	#		unset parsed_argv_file;
	#		printf "-->%s\n" "${parsed_argv}";
	#		foreach parsed_arg( ${escaped_parsed_argv} )
	#			printf "-->%s\n" "${parsed_arg}";
	#		end
	#	endif
	#endif
	
	if( ${?debug_set} ) \
		unset debug debug_set;
	
	if(! ${?auto_read_stdin} ) then
		set callback="if_sourced";
	else
		set callback="read_stdin_init";
	endif
	goto callback_handler;
#set callback="parse_argv_quit";
#goto callback_handler;


filename_list_append_value:
	set label_current="filename_list_append_value";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if(! ${?supports_multiple_files} ) then
		@ errno=-505;
		goto exception_handler;
	endif
	
	if( ! ${?0} && "${value}" == "${scripts_basename}" ) then
		set callback="parse_argv";
		goto callback_handler;
	endif
	
	if(! ${?filename_list} ) \
		set filename_list="${scripts_tmpdir}/.filenames.${scripts_basename}.@`date '+%s'`";
	
	if(! -e "${filename_list}" ) \
		touch "${filename_list}";
	
	if(! ${?scripts_supported_extensions} ) then
		if( ${?debug} || ${?debug_filenames} ) then
			printf "Adding [${value}] to [${filename_list}].\nBy running:\n\tfind -L "\""${value}"\""" > ${stdout};
			if(! ${?supports_hidden_files} ) \
				printf  \! -iregex '.*\/\..*' > ${stdout};
			printf "| sort >> "\""${filename_list}"\""\n\n";
		endif
		if(! ${?supports_hidden_files} ) then
			find -L "${value}" \! -iregex '.*\/\..*' | sort >> "${filename_list}";
		else
			find -L "${value}" | sort >> "${filename_list}";
		endif
		
		if( ${?process_each_filename} ) then
			set callback="if_sourced";
		else
			if(! ${?argv_parsed} ) then
				set callback="parse_argv";
			else if ${?scripts_interactive} || ${?auto_read_stdin} ) then
				set callback="read_stdin";
			else
				set callback="if_sourced";
			endif
		endif
		goto callback_handler;
	endif
	
	#if( "${scripts_supported_extensions}" == "mp3|ogg|m4a" && ! ${?ltrim} && ! ${?rtrim} ) \
	#	set scripts_supported_extensions="mp3|m4a";
	
	if( ${?debug}  || ${?debug_filenames} ) then
		if(! -d "$value" ) then
			printf "Adding [${value}] to [${filename_list}] if its a supported file type.\nSupported extensions are:\n\t`printf '${scripts_supported_extensions}' | sed -r 's/\|/,\ /g'`.\n" > ${stdout};
		else
			printf "Adding any supported files found under [${value}] to [${filename_list}].\nSupported extensions are:\n\t`printf '${scripts_supported_extensions}' | sed -r 's/\|/,\ /g'`.\n" > ${stdout};
		endif
		printf "By running:\n\tfind -L "\""${value}"\"" -regextype posix-extended -iregex "\"".*\.(${scripts_supported_extensions})"\"""\$"" > ${stdout};
		if(! ${?supports_hidden_files} ) \
			printf " \! -iregex '.*\/\..*'" > ${stdout};
		printf " | sort >> "\""${filename_list}"\""\n\n";
	endif
	
	if(! ${?supports_hidden_files} ) then
		find -L "${value}" -regextype posix-extended -iregex ".*\.(${scripts_supported_extensions})"\$ \! -iregex '.*\/\..*'  | sort >> "${filename_list}";
	else
		find -L "${value}" -regextype posix-extended -iregex ".*\.(${scripts_supported_extensions})"\$ | sort >> "${filename_list}";
	endif
	
	if( ${?process_each_filename} ) then
		set callback="if_sourced";
	else
		if(! ${?argv_parsed} ) then
			set callback="parse_argv";
		else if ${?scripts_interactive} || ${?auto_read_stdin} ) then
			set callback="read_stdin";
		else
			set callback="if_sourced";
		endif
	endif
	goto callback_handler;
#set callback="filename_list_append_value";
#goto callback_handler;


diagnosis:
	set label_current="diagnosis";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	set scripts_diagnosis_log="`mktemp --tmpdir diagnosis.${scripts_basename}.log.XXXXXX";
	
	printf "----------------${scripts_basename} debug.log-----------------\n" >> "${scripts_diagnosis_log}";
	printf \$"argv:\n\t${argv}\n\n" >> "${scripts_diagnosis_log}";
	printf \$"parsed_argv:\n\t${parsed_argv}\n\n" >> "${scripts_diagnosis_log}";
	printf \$"{0} == [${0}]\n" >> "${scripts_diagnosis_log}";
	@ arg=0;
	while( "${1}" != "" )
		@ arg++;
		printf \$"{${arg}} == ${1}\n" >> "${scripts_diagnosis_log}";
		shift;
	end
	printf "\n\n----------------<${scripts_basename}> environment-----------------\n" >> "${scripts_diagnosis_log}";
	env >> "${scripts_diagnosis_log}";
	printf "\n\n----------------<${scripts_basename}> variables-----------------\n" >> "${scripts_diagnosis_log}";
	set >> "${scripts_diagnosis_log}";
	printf "Create's %s diagnosis log:\n\t<file://%s>\n" "${scripts_basename}" "${scripts_diagnosis_log}" > ${stdout};
	unset diagnosis;
	@ errno=-500;
	goto exception_handler;
#set callback="diagnosis";
#goto callback_handler;


return:
	if(! ${?label_current} ) then
		if(! ${?labels_previous} ) then
			@ errno=-901;
			goto exception_handler;
		endif
		
		set label_current=$labels_previous[${#labels_previous}];
	endif
	
	if(! ${?labels_previous} ) then
		set labels_previous=("${label_current}");
		set label_previous=$labels_previous[${#labels_previous}];
	else
		if("${label_current}" != "$labels_previous[${#labels_previous}]") then
			set labels_previous=($labels_previous "${label_current}");
			set label_previous=$labels_previous[${#labels_previous}];
		else
			set label_previous=$labels_previous[${#labels_previous}];
			unset labels_previous[${#labels_previous}];
		endif
	endif
	
	if( ${?debug} ) \
		printf "handling label_current: [%s]; label_previous: [%s].\n" "${label_current}" "${label_previous}" > ${stdout};
	
	goto ${label_previous};
#goto return;


callback_stack_update:
	if( ${?old_owd} && ${?current_cwd} ) then
		if( "${old_owd}" == "${owd}" && "${current_cwd}" == "${cwd}" ) then
			goto return;
		endif
	endif
	
	if(! ${?old_owd} ) \
		set old_owd="";
	
	if( "${old_owd}" != "${owd}" ) \
		set owd="${old_owd}";
	
	if(! ${?current_cwd} ) \
		set current_cwd="";
	
	if( "${current_cwd}" != "${cwd}" ) then
		set old_owd="${owd}";
		set current_cwd="${cwd}";
		set directory_file="${scripts_tmpdir}/.escaped.dir.`date '+%s'`.file";
		printf "%s" "${cwd}" >! "${directory_file}";
		ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${directory_file}";
		set escaped_cwd="`cat "\""${directory_file}"\""`";
		rm -f "${directory_file}";
		unset directory_file;
	endif
	
	goto return;
#set label_current="$!";
#if(! ${?label_previous} ) then
#	goto callback_stack_update;
#else if("${label_current}" != "${label_previous}") then
#	goto callback_stack_update;
#endif


callback_handler:
	if(! ${?callback} ) \
		set callback="exit_script";
	
	if(! ${?callback_stack} ) then
		set callback_stack=("${callback}");
		set last_callback="$callback_stack[${#callback_stack}]";
	else
		if("${callback}" != "$callback_stack[${#callback_stack}]" ) then
			set callback_stack=($callback_stack "${callback}");
			set last_callback="$callback_stack[${#callback_stack}]";
		else
			set last_callback="$callback_stack[${#callback_stack}]";
			unset callback_stack[${#callback_stack}];
		endif
	endif
	
	unset callback;
	
	if( ${?debug} ) \
		printf "handling callback to [${last_callback}].\n" > ${stdout};
	
	goto $last_callback;
#goto callback_handler;


