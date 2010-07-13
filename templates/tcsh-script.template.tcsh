#!/bin/tcsh -f
setup:
	onintr exit_script;
	
	if(! -o /dev/$tty ) then
		set stdout=/dev/null;
		set stderr=/dev/null;
	else
		set stdout=/dev/stdout;
		set stderr=/dev/stderr;
	endif
	
	set supports_being_sourced;
	
	set supports_multiple_files;
	#set supports_hidden_files;
	set scripts_supported_extensions="mp3|ogg|m4a";
	set scripts_supported_extensions_defaults="${scripts_supported_extensions}";
	
	#set auto_read_stdin;
	#set scripts_interactive;
	set process_each_filename;
	
	set scripts_basename="tcsh-script.template.tcsh";
	set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	set scripts_alias="`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc|init)"\$"/\1/'`";
	set usage_message="Usage: ${scripts_basename} [options]\n\tA template for advanced tcsh shell scripts.\n\t\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.\n\n\t\t\t-\tTells ${scripts_basename} to read all further arguments/filenames from standard input (-! disables this).\n\n\t\t\t--\tThis will cause the script to process any further filenames as they're reached(--! disables this).";
	
	if( ${?script} ) \
		unset script;
	if( ${?scripts_exec} ) \
		unset scripts_exec;
	
	set starting_owd="${owd}";
	set starting_cwd="${cwd}";
	
	@ minimum_options=-1;
	if( ${?minimum_options} ) then
		if( ${minimum_options} > 0 && ${#argv} < ${minimum_options} ) then
			@ errno=-503;
			goto exception_handler;
		endif
	endif
		
	@ maximum_options=-1;
	if( ${?maximum_options} ) then
		if( ${maximum_options} > 0 && ${#argv} > ${maximum_options} ) then
			@ errno=-504;
			goto exception_handler;
		endif
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
	#alias "curl" "curl --location --fail --show-error --silent --output";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --continue --quiet --output-document";
	#alias ${download_command} "${download_command_with_options}";
	#alias "wget" "wget --no-check-certificate --continue --quiet --output-document";
	
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
	
	set callback="scripts_main_quit";
	goto callback_handler;
#exit_script:


scripts_main_quit:
	onintr -;
	
	set label_current="scripts_main_quit";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ${?arg} ) \
		unset arg;
	
	if( ${?filename_list} ) then
		if( -e "${filename_list}.all" ) then
			set file_count=`wc -l "${filename_list}.all" | sed -r 's/^([0-9]+).*$/\1/'`;
		else if( -e "${filename_list}" ) then
			set file_count=`wc -l "${filename_list}" | sed -r 's/^([0-9]+).*$/\1/'`;
		endif
		
		if( `printf "%s" "${file_count}" | sed -r 's/^[0-9]+$//g'` == "" ) then
			if(! ${?supports_multiple_files} ) then
				@ errno=-506;
				goto exception_handler;
			endif
			
			set callback="filename_list_post_process";
			goto callback_handler;
		endif
	endif
	
	if( ! ${?0} && ${?supports_being_sourced} ) then
		# FINISHED: special handler for when this file is sourced.
		if( -d "${scripts_path}/../tcshrc" && -f "${scripts_path}/../tcshrc/argv:clean-up" ) \
			source "${scripts_path}/argv:clean-up" "${scripts_basename}";
		# END: source support
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
		@ errno=-506;
		goto exception_handler;
	endif
	
	if( ${?file_count} ) \
		unset file_count;
	if( ${?filenames_processed} ) \
		unset filenames_processed;

	
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
	if( ${?scripts_path} ) \
		unset scripts_path;
	
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
	if( ${?exit_on_usage} ) \
		unset exit_on_usage;
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
	
	if( ${?starting_owd} ) then
		if( "${starting_owd}" != "${owd}" ) \
			set owd="${starting_owd}";
		unset starting_owd;
	endif
	
	if( ${?old_owd} ) \
		unset old_owd;
	
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
	if( ${?filename_for_grep} ) \
		unset filename_for_grep;
	if( ${?filename_for_editor} ) \
		unset filename_for_editor;
	if( ${?grep_test} ) \
		unset grep_test;
	
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
	
	set escaped_starting_cwd="${escaped_cwd}";
	
	set directory_file="${scripts_tmpdir}/.escaped.dir.`date '+%s'`.file";
	printf "%s" "${HOME}" >! "${directory_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${directory_file}";
	set escaped_home_dir="`cat "\""${directory_file}"\"" | sed -r 's/([\[\/])/\\\1/g'`";
	rm -f "${directory_file}";
	unset directory_file;
	
	set callback="debug_check_init";
	goto callback_handler;
#set callback="init";
#goto callback_handler;


debug_check_init:
	set label_current="debug_check_init";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	set arg_handler="check_mode";
	set arg_parse_complete="debug_check_quit";
	
	set callback="parse_argv";
	goto callback_handler;
#set callback="debug_check_init";
#goto callback_handler;


debug_check_quit:
	set label_current="debug_check_quit";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if( ${?arg_handler} ) \
		unset arg_handler;
	if( ${?arg_parse_complete} ) \
		unset arg_parse_complete;
	
	if( ${?debug_set} ) \
		unset debug debug_set;
	
	if( ${?arg} ) then
		if( $arg >= $argc ) \
			set argv_parsed;
		unset arg argc;
	endif
	unset argc arg;
	
	set callback="dependencies_check";
	goto callback_handler;
#set callback="debug_check_quit";
#goto callback_handler;


check_mode:
	set label_current="check_mode";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	switch("${option}")
		case "h":
		case "help":
			if(! ${?exit_on_usage} ) \
				set exit_on_usage;
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
			if( ${?diagnosis} ) then
				set callback="parse_argv";
				goto callback_handler;
			endif
		
			set diagnosis;
			if(! ${?debug} ) \
				set debug;
			
			if( "${value}" != "" ) \
				set value="";
			
			breaksw;
		
		case "debug":
			switch("${value}")
				case "logged":
					if( ${?debug_logged} )then
						set callback="parse_argv";
						goto callback_handler;
					endif
					
					set debug_logged;
					breaksw;
				
				case "dependencies":
					if( ${?debug_dependencies} )then
						set callback="parse_argv";
						goto callback_handler;
					endif
					
					set debug_dependencies;
					breaksw;
				
				case "arguments":
					if( ${?debug_arguments} )then
						set callback="parse_argv";
						goto callback_handler;
					endif
					
					set debug_arguments;
					breaksw;
				
				case "stdin":
					if( ${?debug_stdin} )then
						set callback="parse_argv";
						goto callback_handler;
					endif
					
					set debug_stdin;
					breaksw;
				
				case "filenames":
					if( ${?debug_filenames} )then
						set callback="parse_argv";
						goto callback_handler;
					endif
					set debug_filenames;
					breaksw;
				
				default:
					if( ${?debug} )then
						set callback="parse_argv";
						goto callback_handler;
					endif
					if( "${value}" != "" ) \
						set value="";
					set debug;
					breaksw;
			endsw
			breaksw;
		
		default:
			set callback="parse_argv";
			goto callback_handler;
			breaksw;
	endsw
	
	printf "**%s notice:**, via "\$"argv[%d], " "$scripts_basename" $arg;
	if( "${option}" != "debug" ) \
		printf " %s" "${option}";
	if( "${value}" != "" ) \
		printf " debugging";
	
	printf ":\t[enabled].\n\n";
	
	set callback="parse_argv";
	goto callback_handler;
#set callback="check_mode";
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
	
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		
		if( ${?nodeps} && $dependencies_index > 1 ) then
			break;
		endif
		
		set dependency=$dependencies[$dependencies_index];
		
		set which_dependency=`printf "%d" "${dependencies_index}" | sed -r 's/^[0-9]*[^1]?([0-9])$/\1/'`;
		if( $which_dependency == 1 ) then
			set suffix="st";
		else if( $which_dependency == 2 ) then
			set suffix="nd";
		else if( $which_dependency == 3 ) then
			set suffix="rd";
		else
			set suffix="th";
		endif
		unset which_dependency;
		
		if( ${?debug} ) \
			printf "\n**dependencies:** looking for <%s>'s %d%s dependency: %s.\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}";
		
		foreach program("`where "\""${dependency}"\""`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		if(! ${?program} ) then
			@ errno=-501;
			goto exception_handler;
		endif
		
		if( ${?debug} ) \
			printf "\n**dependencies:** <%s>'s %d%s dependency: %s ( binary: %s )\t[found]\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${program}";
		
		unset suffix;
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?script} ) then
					set old_owd="${cwd}";
					cd "`dirname "\""${program}"\""`";
					set scripts_path="${cwd}";
					cd "${owd}";
					set owd="${old_owd}";
					unset old_owd;
					set script="${scripts_path}/${scripts_basename}";
					breaksw;
				endif
			
			default:
				if(! ${?execs} ) \
					set execs=()
				set execs=(${execs} "${program}");
				breaksw;
		endsw
		
		unset program dependency;
	end
	
	if( ${?debug_set} ) \
		unset debug;
	
	unset dependencies dependencies_index;
	
	set callback="parse_argv_init";
	goto callback_handler;
#set callback="dependencies_check";
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
		onintr exit_script;
		set callback="main";
	else if( ${?supports_being_sourced} ) then
		onintr scripts_main_quit;
		set callback="sourced";
	else
		@ errno=-502;
		goto exception_handler;
	endif
	
	if(! ${?filenames_processed} ) then
		if(! ${?filename_list} ) \
			set filename_list="${scripts_tmpdir}/.filenames.${scripts_basename}.@`date '+%s'`";
		
		if(! -e "${filename_list}" ) then
			if(!( ${?scripts_interactive} || ${?auto_read_stdin} )) then
				@ errno=-507;
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


sourced:
	set label_current="sourced";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	# START: special handler for when this file is sourced.
	if( -d "${scripts_path}/../tcshrc" && -f "${scripts_path}/../tcshrc/argv:check" ) \
		source "${scripts_path}/argv:check" "${scripts_basename}" ${argv};
	
	if( ${?debug} ) \
		printf "Setting up aliases so [%s]; executes: <file://%s>.\n" "${scripts_alias}" "${script}";
	
	alias "${scripts_alias}" "${script}";
	
	# FINISHED: special handler for when this file is sourced.
	
	set callback="scripts_main_quit";
	goto callback_handler;
#set callback="sourced";
#goto callback_handler;


main:
	set label_current="main";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	printf "Executing %s's main.\n" "${scripts_basename}";
	
	onintr exec_interupted;
	
	if(!( ${?filename_list} && ${?supports_multiple_files} )) then
		set callback="exec";
	else if( ${?filename_list} && ! ${?supports_multiple_files} ) then
		@ errno=-506;
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
			@ errno=-507;
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


exec_interupted:
	set label_current="exec_interupted";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	onintr exit_script;
	if( ${?original_filename} ) then
		printf "\n\tProcessing: <file://%s>\t[cancelled]\n\n" "`printf "\""%s"\"" "\""${original_filename}"\""`";
	endif
	
	if( ! ${?reading_stdin} && ! ${?disable_interupt_prompt} ) then
		printf "\tWould you like %s to continue? [Yes/No/Always]" "${scripts_basename}";
		set confirmation="$<";
		#set rconfirmation=$<:q;
		printf "\n";
		
		switch(`printf "%s" "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
			case "n":
				printf "\t[%s] will now exit\n" "${scripts_basename}";
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
		printf "\t";
	
	printf "Executing %s's exec.\n" "${scripts_basename}";
	
	if( ${?filename_list} && ! ${?supports_multiple_files} ) then
		@ errno=-506;
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
	printf "\tProcessing: <file://%s>" "`printf "\""%s"\"" "\""${original_filename}"\""`";
	if( ${?file_count} ) then
		if( ${file_count} > 1 ) \
			printf " ( file #%d out of %d )" ${filenames_processed} ${file_count};
	endif
	printf "\t[started]\n";
	set extension="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/^(.*)(\.[^\.]+)"\$"/\2/g'`";
	if( "${extension}" == "`printf "\""%s"\"" "\""${original_filename}"\""`" ) \
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
	set filename_for_grep="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/([ \\*+[/.()])/\\\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	set filename_for_editor="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/(["\"\$\!"'\''[\]() <>\\])/\\\1/g'`";
	if( ${?edit_all_files} ) \
		${EDITOR} "+0r ${filename_for_editor}";
	
	
	if( -d "${filename}${extension}" ) then
		printf "\n\tDirectory";
	else if( -l "${filename}${extension}" ) then
		printf "\n\tSymbolic link";
	else
		printf "\n\tFile";
	endif
	printf " data of: <file://%s%s>\n\t\t%s\n" "${filename}" "${extension}" "`/bin/ls -d -l "\""${filename_for_exec}"\"" | grep -v --perl-regexp '^[\s\ \t\r\n]+"\$"'`";
	
	set grep_test="`grep "\""^${filename_for_grep}"\"\$" "\""${filename_list}.all"\""`";
	printf "\tgrep ";
	if( "${grep_test}" != "" ) then
		printf "found:\n\t\t%s\n" "${grep_test}";
	else
		printf "couldn't find:\n\t\t%s%s.\n" "${filename}" "${extension}";
	endif
	printf "\n";
	
	printf "\tProcessing: <file://%s>\t[finished]\n" "`printf "\""%s"\"" "\""${original_filename}"\""`";
	unset original_filename filename extension;
	unset filename_for_exec filename_for_grep filename_for_editor;
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
		@ errno=-506;
		goto exception_handler;
	endif
	
	#if(! -e "${filename_list}.all" ) \
	#	cp "${filename_list}" "${filename_list}.all";
	
	foreach original_filename("`cat "\""${filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`")
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
		@ errno=-506;
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
	
	if( ${?filename_list} && ! ${?supports_multiple_files} ) then
		@ errno=-506;
		goto exception_handler;
	endif
	
	if( -e "${filename_list}.all" ) then
		set file_count=`wc -l "${filename_list}.all" | sed -r 's/^([0-9]+).*$/\1/'`;
	else if( -e "${filename_list}" ) then
		set file_count=`wc -l "${filename_list}" | sed -r 's/^([0-9]+).*$/\1/'`;
	endif
	
	if( ${?file_count} ) then
		if( `printf "%s" "${file_count}" | sed -r 's/^[0-9]+$//g'` != "" ) \
			@ file_count=0;
	endif
	
	if(! ${?filenames_processed} ) \
		@ filenames_processed=0;
	
	if(!( ${file_count} > 0 && ${filenames_processed} > 0 )) then
		@ errno=-497;
		goto exception_handler;
	endif
	
	printf "Post-Processing %s's processed %d out of %d files\t[" "${scripts_basename}" ${filenames_processed} ${file_count};
	
	if( ${filenames_processed} != ${file_count} ) then
		printf "failed]]\n\t\t\t\t\t\t[only %d out of %d files where" ${filenames_processed} ${file_count};
	else
		# any post processing that's only to be done
		# after the filename_list has been fully processed.
		printf "finished";
	endif
	
	printf "]\n";
	
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
	
	if( ${?script} && ${?program} ) then
		if( "${program}" != "${script}" && -x ${?program} ) then
			${program} --help;
			set usage_displayed;
		endif
	endif
	
	if( ! ${?usage_displayed} ) then
		printf "\n";
		if(! ${?usage_message} ) then
			printf "Usage:\t%s [-h|--help]...\n\t[-h|--help]\tDisplays this screen." "${scripts_basename}";
		else
			printf "${usage_message}";
		endif
		printf "\n\n";
		set usage_displayed;
	endif
	
	if( ${?exit_on_usage} || ! ${?callback} ) \
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
	
	if(! ${?errno} ) then
		if( ${?callback} ) \
			goto callback_handler;
		@ errno=-999;
	else if( `printf "%s" "$errno" | sed -r 's/^[0-9]+$/\1/'` != "" ) then
		@ errno=-999;
	endif
	
	if( $errno < -400 ) then
		if(! ${?exit_on_exception} ) \
			set exit_on_exception;
	else if( $errno > -400 && $errno < -100 ) then
		if( ${?exit_on_exception} ) then
			set exit_on_exception_unset;
			unset exit_on_exception;
		endif
	endif
	
	printf "\n" > ${stderr};
	if( $errno > -400 ) \
		printf "\t" > ${stderr};
	printf "**%s error:**, "\$"errno:%d, " "${scripts_basename}" ${errno} > ${stderr};
	switch( $errno )
		case -300:
			printf "Cannot process: <file://%s> is an unsupported file." "${value}" > ${stderr};
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
			printf "No files have been processed." > ${stderr};
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
			unset value;
			breaksw;
		
		case -500:
			printf "diagnostic mode has completed.\n\tFor detailed information please see all above output and the diagnosis log:\n\t<file://%s>" "${scripts_diagnosis_log}" > ${stderr};
			breaksw;
		
		case -501:
			printf "<%s>'s %d%s dependency: <%s> couldn't be found.\n\t%s requires: [%s]." "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${scripts_basename}" "${dependencies}" > ${stderr};
			unset suffix dependency dependencies dependencies_index;
			breaksw;
		
		case -502:
			printf "Sourcing is not supported. %s may only be executed" "${scripts_basename}" > ${stderr};
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided." > ${stderr};
			breaksw;
		
		case -504:
			printf "To many options have been provided." > ${stderr};
			breaksw;
		
		case -505:
			printf "%s%s%s%s is an unsupported option." "${dashes}" "${option}" "${equals}" "${value}" > ${stderr};
			unset dashes option equals value;
			breaksw;
		
		case -506:
			printf "handling and/or processing multiple files isn't supported." > ${stderr};
			if( ${?filename_list} ) then
				if( -e "${filename_list}" ) \
					rm -f "${filename_list}";
				if( -e "${filename_list}.all" ) \
					rm -f "${filename_list}.all";
				unset filename_list;
			endif
			breaksw;
		
		case -507:
			printf "No processable file have been provide, nor could any be found." > ${stderr};
			if(!( ${?scripts_interactive} || ${?auto_read_stdin} )) then
				printf ".\n\t\tRun: "\`"%s -"\`" or "\`"%s "\""<"\"\`" if you want to pipe options into this script." "${scripts_basename}" "${scripts_basename}" > ${stderr};
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
			printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}" > ${stderr};
			breaksw;
		
		case -603:
			printf "Invalid length specified for: [%s%s]: %s must be formatted as: 'hh:mm:ss'." "${dashes}" "${option}" "${value}" > ${stderr};
			breaksw;
		
		case -604:
			printf "%sing %s is not supported." "`printf "\""%s"\"" "\""${option}"\"" | sed -r 's/^(.*)e"\$"/\1/`" "${value}" "${scripts_basename}" > ${stderr};
			breaksw;
		
		case -901:
			printf "initialization was not completed correctly.  Please make sure label_stack_set is called at the beginning of the script." > ${stderr};
			breaksw;
		
		case -999:
		default:
			printf "An unknown error has occured." > ${stderr};
			breaksw;
	endsw
	printf "\n\n";
	printf "\tPlease see: "\`"${scripts_basename} --help"\`" for more information and supported options.\n" > ${stderr}
	if(! ${?debug} ) \
		printf "\tOr run: "\`"${scripts_basename} --debug"\`" to diagnose where ${scripts_basename}'s failed.\n" > ${stderr}
	printf "\n" > ${stderr}
	
	if( ! ${?callback} || ${?exit_on_exception} ) \
		set callback="exit_script";
	
	if( ${?exit_on_exception_unset} ) then
		unset exit_on_exception_unset;
		set exit_on_exception;
	endif
	
	goto callback_handler;
#@ errno=-101;
#set callback="$!";
#goto exception_handler;


parse_argv_init:
	set label_current="parse_argv_init";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	#set argz;
	set arg_handler="check_arg";
	set arg_parse_complete="parse_argv_quit";
	
	set callback="parse_argv";
	goto callback_handler;
#set callback="parse_argv_init";
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
	
	if( ${?debug_set} ) \
		unset debug debug_set;
	goto exit_script;
	
	if(! ${?auto_read_stdin} ) then
		set callback="if_sourced";
	else
		set callback="read_stdin_init";
	endif
	goto callback_handler;
#set callback="parse_argv_quit";
#goto callback_handler;


parse_argv:
	set label_current="parse_argv";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if(!( ${?argc} && ${?arg} )) then
		@ argc=${#argv};
		@ arg=0;
		@ parsed_argc=0;
		
		if( ( ${?debug_options} || ${?debug_arguments} ) && ! ${?debug} ) \
			set debug debug_set;
		
		if( ${?debug} ) \
			printf "**%s debug:** parsing "\$"argv's %d options.\n" "${scripts_basename}" "${argc}";
	else if( $arg <= $argc ) then
		@ parsed_argc++;
		set parsed_arg="${dashes}${option}${equals}${value}";
		
		if(! ${?parsed_argv} ) then
			set parsed_argv=("${parsed_arg}");
		else
			set parsed_argv=("${parsed_argv}" "\n" "${parsed_arg}");
		endif
		
		if( ${?debug} ) \
			printf "\t**debug:** parsed "\$"argv[%d]: %s%s%s%s\n" $arg "${dashes}" "${option}" "${equals}" "${value}";
		
		if( ${?value} ) \
			unset escaped_argument argument dashes option equals escaped_value value parsed_arg;
	endif
	
	while( $arg < $argc )
		@ arg++;
		
		if( ${?debug} ) \
			printf "**%s parse_argv:** Checking argv #%d (%s).\n" "${scripts_basename}" ${arg} "$argv[${arg}]";
		set callback="parse_arg";
		goto callback_handler;
	end
	
	unset argc arg;
	set callback=$arg_parse_complete;
	goto callback_handler;
#set callback="parse_argv";
#goto callback_handler;


parse_arg:
	set label_current="parse_arg";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	switch( "$argv[${arg}]" )
		case "<":
			if(! ${?auto_read_stdin} ) \
				set auto_read_stdin;
			set callback="parse_argv";
			goto calllback_handler;
		
		case "<!":
			if( ${?auto_read_stdin} ) \
				unset auto_read_stdin;
			set callback="parse_argv";
			goto calllback_handler;
		
		case "-":
			if(! ${?scripts_interactive} ) \
				set scripts_interactive;
			set callback="parse_argv";
			goto calllback_handler;
		
		case "-!":
			if( ${?scripts_interactive} ) \
				unset scripts_interactive;
			set callback="parse_argv";
			goto calllback_handler;
				
		case "--":
			if(! ${?process_each_filename} ) \
				set process_each_filename;
			set callback="parse_argv";
			goto calllback_handler;
		
		case "--!":
			if( ${?process_each_filename} ) \
				unset process_each_filename;
			set callback="parse_argv";
			goto calllback_handler;
	endsw
	
	set argument_file="${scripts_tmpdir}/.escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg";
	printf "%s" "$argv[${arg}]" >! "${argument_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
	set escaped_argument="`cat "\""${argument_file}"\""`";
	rm -f "${argument_file}";
	unset argument_file;
	set argument="`printf "\""%s"\"" "\""${escaped_argument}"\""`";
	
	set dashes="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
	if( "${dashes}" == "${argument}" ) \
		set dashes="";
	
	set option="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
	if( "${option}" == "${argument}" ) \
		set option="";
	
	set equals="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
	if( "${equals}" == "${argument}" ) \
		set equals="";
	
	set value="`printf "\""%s"\"" "\""${escaped_argument}"\"" | sed -r 's/^([-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
	
	if( ${?debug} ) \
		printf "\tparsed "\$"argument: [%s]; "\$"argv[%d] (%s)\n\t\t"\$"dashes: [%s];\n\t\t"\$"option: [%s];\n\t\t"\$"equals: [%s];\n\t\t"\$"value: [%s]\n\n" "${argument}" "${arg}" "$argv[${arg}]" "${dashes}" "${option}" "${equals}" "${value}";
	
	if( "${dashes}" != "" && "${option}" != "" && "${equals}" == "" && "${value}" == "" ) then
	#if( "${value}" != "${argument}" && !( "${dashes}" != "" && "${option}" != "" && "${equals}" != "" && "${value}" != "" )) then
		@ arg++;
		if( ${arg} > ${argc} ) then
			@ arg--;
		else
			if( ${?debug} ) \
				printf "**%s debug:** Looking for replacement value.  Checking argv #%d (%s).\n" "${scripts_basename}" ${arg} "$argv[${arg}]";
			
			set argument_file="${scripts_tmpdir}/.escaped.argument.${scripts_basename}.argv[${arg}].`date '+%s'`.arg";
			printf "%s" "$argv[${arg}]" >! "${argument_file}";
			ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
			set escaped_test_argument="`cat "\""${argument_file}"\""`";
			rm -f "${argument_file}";
			unset argument_file;
			set test_argument="`printf "\""%s"\"" "\""${escaped_test_argument}"\""`";
			
			set test_dashes="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
			if( "${test_dashes}" == "${test_argument}" ) \
				set test_dashes="";
			
			set test_option="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
			if( "${test_option}" == "${test_argument}" ) \
				set test_option="";
			
			set test_equals="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
			if( "${test_equals}" == "${test_argument}" ) \
				set test_equals="";
			
			set test_value="`printf "\""%s"\"" "\""${escaped_test_argument}"\"" | sed -r 's/^([-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
			
			if( ${?debug} ) \
				printf "\t\tparsed argument for possible replacement value:\n\t\t\t"\$"test_argument: [%s]; "\$"argv[%d] (%s)\n\t\t\t"\$"test_dashes: [%s];\n\t\t\t"\$"test_option: [%s];\n\t\t\t"\$"test_equals: [%s];\n\t\t\t"\$"test_value: [%s]\n\n" "${test_argument}" "${arg}" "$argv[${arg}]" "${test_dashes}" "${test_option}" "${test_equals}" "${test_value}";
			
			@ arg--;
			if( "${test_dashes}" == "" && "${test_option}" == "" && "${test_equals}" == "" && "${test_value}" == "${test_argument}" ) then
				set equals=" ";
				set value="${test_value}";
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
		#set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
	endif
	
	if( "${option}" == "${value}" ) \
		set option="";
	
	set callback=$arg_handler;
	goto callback_handler;
#called-by-label: parse_argv;


check_arg:
	switch("${option}")
		case "nodeps":
		case "debug":
		case "diagnosis":
		case "diagnostic-mode":
			# these are all caught above. See: [debug_check:]
			breaksw;
		
		case "any-file":
		case "all-files":
			if(! ${?scripts_supported_extensions} ) \
				breaksw;
			
			set scripts_supported_extensions_defaults="${scripts_supported_extensions}";
			unset scripts_supported_extensions;
			breaksw;
		
		case "default-files":
			if( ${?scripts_supported_extensions} && ${?scripts_supported_extensions_defaults} ) then
				if( "${scripts_supported_extensions}" == "${scripts_supported_extensions_defaults}" ) \
					breaksw;
			endif
			
			set scripts_supported_extensions="${scripts_supported_extensions_defaults}";
			breaksw;
		
		case "extension":
		case "extensions":
			if( ${?scripts_supported_extensions} ) then
				set scripts_supported_extensions_defaults="${scripts_supported_extensions}";
				unset scripts_supported_extensions;
			endif
			breaksw;
		
		case "with-extension":
		case "with-extensions":
		case "include-extension":
		case "include-extensions":
			if(! ${?scripts_supported_extensions} ) then
				set scripts_supported_extensions="${value}";
			else
				set scripts_supported_extensions=`printf "(%s|%s)" "${scripts_supported_extensions}" "${value}" | sed -r 's/[()]//g'`;
			endif
			breaksw;
		
		case "numbered_option":
			if(!( "${value}" != "" && ${value} > 0 )) then
				@ errno=-602;
				set callback="parse_argv";
				goto exception_handler;
				breaksw;
			endif
		
			set numbered_option="${value}";
		breaksw;
		
		case "option-array":
			if(! ${?array_options} ) then
				set array_options=("${value}");
			else
				set array_options=( "${array_options}" "\n" "${value}" );
			endif
		breaksw;
		
		case "length_option":
			if( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}"\$"//'`" != "" ) then
				@ errno=-603;
				set callback="parse_argv";
				goto exception_handler;
				breaksw;
			endif
			
			set length="${value}";
		breaksw;
		
		case "verbose":
			if(! ${?be_verbose} ) \
				set be_verbose;
			breaksw;
		
		case "switch-option":
			switch("${value}")
				case "iv":
				case "verbose":
				case "interactive":
					set switch_option="${dashes}${value}";
				breaksw;
				
				default:
					set switch_option;
				breaksw;
			endsw
			
			if( ${?debug} ) \
				printf "**%s debug:**, via "\$"argv[${arg}], ${option}:\t[enabled].\n\n" "${scripts_basename}";
			breaksw;
		
		case "enable":
			switch("${value}")
				case "switch-option":
					if( ${?switch_option} ) \
						breaksw;
					
					if( ${?debug} ) \
						printf "**%s debug:**, via "\$"argv[${arg}], ${value} mode:\t[${option}d].\n\n" "${scripts_basename}";
					set switch_option;
					breaksw;
				
				case "verbose":
					if(! ${?be_verbose} ) \
						breaksw;
					
					printf "**%s debug:**, via "\$"argv[${arg}], verbose output:\t[${option}d].\n\n" "${scripts_basename}";
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
						printf "**%s debug:**, via "\$"argv[${arg}], ${value} mode:\t[${option}d].\n\n" "${scripts_basename}";
					unset switch_option;
					breaksw;
				
				case "verbose":
					if(! ${?be_verbose} ) \
						breaksw;
					
					printf "**%s debug:**, via "\$"argv[${arg}], verbose output:\t[${option}d].\n\n" "${scripts_basename}";
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
				set callback="filename_list_append_value";
				goto callback_handler;
				breaksw;
			endif
			
			if( ${?argz} ) then
				if( ${dashes} != "" ) then
					set argz="${argz} $argv[$arg]";
				else
					set argz="${argz}$argv[$arg]";
				endif
				breaksw;
			endif
			
			@ errno=-505;
			set callback="parse_argv";
			goto exception_handler;
			breaksw;
	endsw
	
	set callback="parse_argv";
	goto callback_handler;
#set callback="check_arg";
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
	#set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
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


filename_list_append_value:
	set label_current="filename_list_append_value";
	if(! ${?label_previous} ) then
		goto callback_stack_update;
	else if("${label_current}" != "${label_previous}") then
		goto callback_stack_update;
	endif
	
	if(! ${?supports_multiple_files} ) then
		@ errno=-506;
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
	
	set value_file="`mktemp --tmpdir .escaped.${scripts_basename}.filename.value.XXXXXXXX`";
	printf "%s" "$value" >! "${value_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
	set escaped_value="`cat "\""${value_file}"\""`";
	rm -f "${value_file}";
	unset value_file;
	set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/)(\/)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\/)(.*)"\$"/\2/'`" == "/./" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/\.\/)/\//' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\.\/)(.*)"\$"/\2/'`" == "/../" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(.*)(\/[^/.]{2}.+)(\/\.\.\/)(.*)"\$"/\1\/\4/' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
	if( `printf "%s" "${value}" | sed -r 's/^(\/).*$/\1/'` != "/" ) \
		set value="${cwd}/${value}";
	unset escaped_value;
	
	if(! ${?scripts_supported_extensions} ) then
		if( ${?debug} || ${?debug_filenames} ) then
			printf "Adding [%s] to [%s].\nBy running:\n\tfind -L "\""${value}"\""" "${value}" "${filename_list}";
			if(! ${?supports_hidden_files} ) \
				printf  " \\\! -iregex '.*\/\..*'";
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
			printf "Adding [%s] to [%s] if its a supported file type.\nSupported extensions are:\n\t`printf '%s' | sed -r 's/\|/,\ /g'`.\n" "${value}" "${filename_list}" "${scripts_supported_extensions}";
		else
			printf "Adding any supported files found under [%s] to [%s].\nSupported extensions are:\n\t`printf '%s' | sed -r 's/\|/,\ /g'`.\n" "${value}" "${filename_list}" "${scripts_supported_extensions}";
		endif
		printf "By running:\n\tfind -L "\""${value}"\"" -regextype posix-extended -iregex "\"".*\.(${scripts_supported_extensions})"\"""\$"";
		if(! ${?supports_hidden_files} ) \
			printf  " \\\! -iregex '.*\/\..*'";
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
	
	printf "----------------%s debug.log-----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	printf \$"argv:\n\t${argv}\n\n" >> "${scripts_diagnosis_log}";
	printf \$"parsed_argv:\n\t${parsed_argv}\n\n" >> "${scripts_diagnosis_log}";
	printf \$"{0} == [${0}]\n" >> "${scripts_diagnosis_log}";
	@ arg=0;
	while( "${1}" != "" )
		@ arg++;
		printf \$"{${arg}} == ${1}\n" >> "${scripts_diagnosis_log}";
		shift;
	end
	printf "\n\n----------------<%s> environment-----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	env >> "${scripts_diagnosis_log}";
	printf "\n\n----------------<%s> variables-----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	set >> "${scripts_diagnosis_log}";
	printf "Create's %s diagnosis log:\n\t<file://%s>\n" "${scripts_basename}" "${scripts_diagnosis_log}";
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
		printf "handling label_current: [%s]; label_previous: [%s].\n" "${label_current}" "${label_previous}";
	
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
		printf "handling callback to [%s].\n" "${last_callback}";
	
	goto $last_callback;
#goto callback_handler;


