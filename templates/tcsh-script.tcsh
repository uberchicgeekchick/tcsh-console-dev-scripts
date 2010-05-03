#!/bin/tcsh -f
set label_current="setenv";
goto label_stack_set;
setenv:
	if(! ${?noglob} ) then
		set noglob;
		set noglob_set;
	endif
	
	if(! ${?nohup} ) then
		set nohup;
		set nohup_set;
	endif
	
	if( "`alias cwdcmd`" != "" ) then
		set original_cwdcmd="`alias cwdcmd`";
		unalias cwdcmd;
	endif
	
	if( ${?GREP_OPTIONS} ) then
		set grep_options="${GREP_OPTIONS}";
		unsetenv GREP_OPTIONS;
	endif
	
	set scripts_basename="tcsh-script.tcsh";
	set scripts_alias="`echo -n "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)"\$"/\1/'`";
	
	set strict;
	set supports_being_source;
	
	#set supports_hidden_files;
	set scripts_supported_extensions="mp3|ogg|m4a|wav";
	
	if(! ${?echo_style} ) then
		set echo_style_set;
		set echo_style=both;
	else
		if( "${echo_style}" != "both" ) then
			set original_echo_style="${echo_style}";
			set echo_style_set;
			set echo_style=both;
	endif
#setenv:


init:
	set label_current="init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set usage_message="Usage: ${scripts_basename} [options]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.";
	
	set original_owd=${owd};
	set starting_dir=${cwd};
	set escaped_starting_cwd=${escaped_cwd};
	
	set escaped_home_dir=`echo -n ${HOME}  | sed -r 's/([\!\$\"])/"\\\1"/g' | sed -r 's/([\[\/])/\\\1/g'`;
#init:


debug_check:
	set label_current="debug_check";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ arg=0;
	@ argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		if( -e "$argv[$arg]" ) \
			continue;
		
		set argument=`echo -n $argv[$arg] | sed -r 's/([\!\$\"])/"\\\1"/g'`;
		set option=`echo -n $argument | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(['\''"])?(.*)(['\''"])?$/\2/'`;
		set value=`echo -n $argument | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(['\''"])?(.*)(['\''"])?$/\5/'`;
		if( -e "`echo -n "\""${value}"\""`" ) \
			continue;
		
		if( ${?debug} || ${?debug_arguments} ) \
			echo -n "**${scripts_basename} [debug_check:]**"\$"option: [${option}]; "\$"value: [${value}].\n";
		
		switch("${option}")
			case "diagnosis":
			case "diagnostic-mode":
				echo -n "**${scripts_basename} debug:**, via "\$"argv[$arg], diagnostic mode:\t[enabled].\n\n";
				set diagnostic_mode;
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "debug":
				switch("${value}")
					case "logged":
						if( ${?logging} ) \
							breaksw;
						
						echo -n "**${scripts_basename}**, via "\$"argv[${arg}], debug logging:\t[enabled].\n\n";
						set debug_logging;
						breaksw;
					
					case "argv":
					case "parse_argv":
					case "arguments":
						if( ${?debug_arguments} ) \
							breaksw;
						
						echo -n "**${scripts_basename}**, via "\$"argv[${arg}], debugging arguments:\t[enabled].\n\n";
						set debug_arguments;
						breaksw;
					
					case "filelist":
						if( ${?debug_filelist} ) \
							breaksw;
						
						echo -n "**${scripts_basename}**, via "\$"argv[${arg}], filelist debugging:\t[enabled].\n\n";
						set debug_filelist;
						breaksw;
					
					default:
						if( ${?debug} ) \
							breaksw;
						
						echo -n "**${scripts_basename}**, via "\$"argv[${arg}], debug mode:\t[enabled].\n\n";
						set debug="${value}";
						breaksw;
				endsw
				breaksw;
			
			default:
				continue;
		endsw
	end
#debug_check:


check_dependencies:
	set label_current="check_dependencies";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set dependencies=("${scripts_basename}" "find" "sed" "ex");# "${scripts_alias}");
	@ dependencies_index=0;
	
	foreach dependency(${dependencies})
		@ dependencies_index++;
		unset dependencies[$dependencies_index];
		if( ${?debug} ) \
			echo -n "\n**${scripts_basename} debug:** looking for dependency: ${dependency}.\n\n"; 
			
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
			switch( `echo -n ${dependencies_index} | sed -r 's/^[0-9]*[^1]?([1-3])$/\1/'` )
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
			
			echo -n "**${scripts_basename} debug:** found ${dependencies_index}${suffix} dependency: ${dependency}.\n";
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
			
			case "find":
				set find_exec="${program}";
				breaksw;
			
			case "sed":
				set sed_exec="${program}";
				breaksw;
			
			case "ex":
				set ex_exec="${program}";
				breaksw;
			
			case "":
				breaksw;
		endsw
		
		unset program;
	end
	
	unset dependency dependencies;
	
	set callback="parse_argv";
	goto callback_handler;
#check_dependencies:


if_sourced:
	set label_current="if_sourced";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ errno=0;
	
	alias	ex	"ex -E -X -n --noplugin -s";
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	#alias	"curl"	"${download_command_with_options}";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --quiet --continue --output-document";
	#alias	"wget"	"${download_command_with_options}";
	
	if( ${?0} ) then
		set callback="scripts_main";
		goto callback_handler;
	endif
	
	if( ${?supports_being_source} ) then
		set callback="scripts_sourcing_main";
		goto callback_handler;
	endif
	
	@ errno=-502;
	goto exception_handler;
	# END: disable source scripts_basename.
#if_sourced:


scripts_sourcing_main:
	set label_current="scripts_sourcing_main";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	# BEGIN: source scripts_basename support.
	if(! ${?TCSH_RC_SESSION_PATH} ) \
		setenv TCSH_RC_SESSION_PATH "${scripts_dirname}/../tcshrc";
	source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
	
	# START: special handler for when this file is sourced.
	alias ${scripts_alias} \$"{TCSH_LAUNCHER_PATH}/${scripts_basename}";
	# FINISH: special handler for when this file is sourced.
#scripts_sourcing_main:


scripts_sourcing_quit:
	set label_current="scripts_sourcing_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_basename}";
	# END: source scripts_basename support.
	
	set callback="scripts_main_quit";
	goto callback_handler;
#scripts_sourcing_quit:


scripts_main:
	set label_current="scripts_main";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	echo -n "Executing ${scripts_basename}'s main.\n";
	
	@ required_options=1;
	
	if( ${argc} < ${required_options} ) then
		@ errno=-503;
		set callback="parse_argv_quit";
		goto exception_handler;
	endif
	
	if(! ${?filename_list} ) then
		set callback="scripts_exec";
		goto callback_handler;
	endif
	
	set callback="process_filename_list_init";
	goto callback_handler;
#scripts_main:


process_filename_list_init:
	set label_current="process_filename_list_init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	cat "${filename_list}" | sort | uniq > "${filename_list}.swp";
	mv -f "${filename_list}.swp" "${filename_list}";
	
	set file_count=`cat "${filename_list}" | wc -l | sed -r 's/^(.*)[\r\n]*/\1/'`;
	
	if(! ${file_count} > 0 ) then
		if( ${?no_exit_on_exception} ) \
			unset no_exit_on_exception;
		
		if(! ${?display_usage_on_exception} ) \
			unset display_usage_on_exception;
		
		@ errno=-503;
		set callback="scripts_main_quit";
		goto exception_handler;
	endif
	
	@ files_processed=0;
	cp "${filename_list}" "${filename_list}.all";
#process_filename_list_init:


process_filename_list:
	set label_current="process_filename_list";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	foreach filename("`cat "\""${filename_list}"\""`")
		ex -s '+1d' '+wq!' "${filename_list}";
		@ files_processed++;
		if( ${?debug} ) \
			echo -n "Attempting to process_file: [${filename}] (file: #${files_processed} of ${file_count})\n";
		set callback="process_file";
		goto callback_handler;
	end
	if( ${files_processed} > 0 ) then
		set callback="scripts_main_quit";
	else
		set callback="usage";
	endif
	goto callback_handler;
#process_filename_list:


scripts_exec:
	set label_current="scripts_exec";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	echo -n "Executing ${scripts_basename}'s exec.\n";
	
	set callback="scripts_main_quit";
	goto callback_handler;
#scripts_exec:

process_file:
	set label_current="process_file";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set callback="process_filename_list";
	set extension=`echo -n ${filename} | sed -r 's/^(.*)(\.[^\.]+)$/\2/g'`;
	if( "${extension}" == "${filename}" ) \
		set extension="";
	set original_extension="${extension}";
	set filename=`echo -n ${filename} | sed -r 's/^(.*)(\.[^\.]+)$/\1/g'`;
	if(! -e "${filename}${extension}" ) then
		if( ! ${?no_exit_on_usage} ) \ 
			set no_exit_on_usage;
		echo -n "**${scripts_basename} error:** filename: ${filename}${extension} can no longer be found.\n";
		set callback="process_filename_list";
		goto usage;
	endif
	
	set filename_for_regexp=`echo -n ${filename}${extension} | sed -r 's/([*\[\/])/\\\1/g'`;
	set filename_for_editor=`echo -n ${filename}${extension} | sed -r 's/([\(\)\ ])/\\\1/g'`;
	echo -n "\nFile info for:\n\t<file://${filename}${extension}>\n";
	
	if( -d "${filename}${extension}" ) \
		/bin/ls -d -l "${filename}${extension}" | grep -v --perl-regexp '^[\s\ \t\r\n]+$';
	
	/bin/ls -l "${filename}${extension}" | grep -v --perl-regexp '^[\s\ \t\r\n]+$';
	
	set grep_test=`grep "^${filename_for_regexp}"\$ "${filename_list}.all"`;
	echo -n "grep ";
	if( "${grep_test}" != "" ) then
		echo -n "found:\n\t${grep_test}\n";
	else
		echo -n "couldn't find:\n\t${filename}${extension}.\n";
	endif
	
	goto callback_handler;
#process_file:


scripts_main_quit:
	set label_current="scripts_main_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?label_current} ) \
		unset label_current;
	if( ${?label_previous} ) \
		unset label_previous;
	if( ${?labels_previous} ) \
		unset labels_previous;
	if( ${?label_next} ) \
		unset label_next;
	
	if( ${?arg} ) \
		unset arg;
	if( ${?argc} ) \
		unset argc;
	if( ${?parsed_arg} ) \
		unset parsed_arg;
	if( ${?parsed_argv} ) \
		unset parsed_argv;
	if( ${?parsed_argc} ) \
		unset parsed_argc;
	
	if( ${?noglob_set} ) \
		unset noglob noglob_set;
	if( ${?nohup_set} ) \
		unset nohup nohup_set;
	
	if( ${?supports_being_source} ) \
		unset supports_being_source;
	
	if( ${?script} ) \
		unset script;
	if( ${?scripts_alias} ) \
		unset scripts_alias;
	if( ${?scripts_basename} ) \
		unset scripts_basename;
	if( ${?scripts_dirname} ) \
		unset scripts_dirname;
	
	if( ${?dependency} ) \
		unset dependency;
	if( ${?dependencies} ) \
		unset dependencies;
	if( ${?missing_dependency} ) \
		unset missing_dependency;
	
	if( ${?usage_displayed} ) \
		unset usage_displayed;
	if( ${?no_exit_on_usage} ) \
		unset no_exit_on_usage;
	
	if(! ${?no_exit_on_exception} ) \
		set no_exit_on_exception;
	if( ${?display_usage_on_exception} ) \
		unset display_usage_on_exception;
	if( ${?last_exception_handled} ) \
		unset last_exception_handled;
	
	if( ${?label_previous} ) \
		unset label_previous;
	if( ${?label_next} ) \
		unset label_next;
	
	if( ${?callback} ) \
		unset callback;
	if( ${?last_callback} ) \
		unset last_callback;
	if( ${?callback_stack} ) \
		unset callback_stack;
	
	if( ${?argc_required} ) \
		unset argc_required;
	if( ${?arg_shifted} ) 				 \
		unset arg_shifted;
	
	if( ${?escaped_cwd} ) \
		unset escaped_cwd;
	if( ${?escaped_home_dir} ) \
		unset escaped_home_dir;
	if( ${?escaped_starting_cwd} ) \
		unset escaped_starting_cwd;
	
	if( ${?old_owd} ) then
		if( ${old_owd} != ${owd} ) \
			set owd=${old_owd};
		unset old_owd;
	endif
	
	if( ${?original_owd} ) then
		cd "${owd}";
		set owd="${original_owd}";
		unset original_owd;
	endif
	
	if( ${?starting_cwd} ) then
		if( "${starting_cwd}" != "${cwd}" ) \
			cd "${starting_cwd}";
	endif
	
	if( ${?original_cwdcmd} ) then
		alias cwdcmd "${original_cwdcmd}";
		unset original_cwdcmd;
	endif
	
	if( ${?grep_options} ) then
		setenv GREP_OPTIONS "${grep_options}";
		unset grep_options;
	endif
	
	if( ${?original_echo_style} ) then
		set echo_style="${original_echo_style}";
		unset original_echo_style;
	else if( ${?echo_style_set} ) then
		unset echo_style;
	endif
	
	if( ${?scripts_supported_extensions} ) \
		unset scripts_supported_extensions;
	if( ${?supports_hidden_files} ) \
		unset supports_hidden_files;
	
	if( ${?filename_list} ) then
		if( ${?filename} ) \
			unset filename;
		if( ${?filename_for_regexp} ) \
			unset filename_for_regexp;
		if( ${?filename_for_editor} ) \
			unset filename_for_editor;
		if( ${?extension} ) \
			unset extension;
		if( ${?original_extension} ) \
			unset original_extension;
		if( ${?file_count} ) \
			unset file_count;
		if( ${?files_processed} ) \
			unset files_processed;
		
		if( -e "${filename_list}" ) \
			rm "${filename_list}";
		if( -e "${filename_list}.all" ) \
			rm "${filename_list}.all";
		unset filename_list;
	endif
	
	if( ${?debug} ) \
		unset debug;
	if( ${?scripts_diagnosis_log} ) \
		unset scripts_diagnosis_log;
	
	if( ${?strict} ) \
		unset strict;
	
	if(! ${?errno} ) \
		@ errno=0;
	
	@ status=$errno;
	exit ${errno}
#scripts_main_quit:


usage:
	set label_current="usage";
	if( "${label_next}" != "${label_current}" ) \
		goto label_stack_set;
	
	if( ${?errno} ) then
		if( ${errno} != 0 ) then
			if(! ${?last_exception_handled} ) \
				set last_exception_handled=0;
			if( ${last_exception_handled} != ${errno} ) then
				if(! ${?callback} ) \
					set callback="usage";
				goto exception_handler;
			endif
		endif
	endif
	
	if(!( ${?script} && ${?program} )) then
		echo -n "${usage_message}\n";
	else
		if( "${program}" != "${script}" ) then
			${program} --help;
		else
			echo -n "${usage_message}\n";
		endif
	endif
	
	if(! ${?usage_displayed} ) \
		set usage_displayed;
	
	if(! ${?no_exit_on_usage} ) then
		if(! ${0} ) then
			set callback="scripts_sourcing_quit";
		else
			set callback="scripts_main_quit";
		endif
	else if(! ${?callback} ) then
		set callback="scripts_main_quit";
	endif
	
	goto callback_handler;
#usage:


exception_handler:
	set label_current="exception_handler";
	if( "${label_next}" != "${label_current}" ) \
		goto label_stack_set;
	
	if(! ${?errno} ) \
		@ errno=-599;
	echo -n "\n**${scripts_basename} error("\$"errno:$errno):**\n\t";
	switch( $errno )
		case -500:
			echo -n "Debug mode has triggered an exception for diagnosis.  Please see any output above" > /dev/stderr;
			breaksw;
		
		case -501:
			echo -n "One or more required dependencies couldn't be found.\n\t[${dependency}] couldn't be found.\n\t${scripts_basename} requires: ${dependencies}";
			breaksw;
		
		case -502:
			echo -n "Sourcing is not supported. ${scripts_basename} may only be executed" > /dev/stderr;
			breaksw;
		
		case -503:
			echo -n "One or more required options have not been provided" > /dev/stderr;
			breaksw;
		
		case -504:
			echo -n  "${dashes}${option} is an unsupported option" > /dev/stderr;
			breaksw;
		
		case -599:
		default:
			echo -n "An internal script error has caused an exception.  Please see any output above" > /dev/stderr;
			if(! ${?debug} ) \
				echo -n " or run: %s%s --debug%s to find where %s failed" '`' "${scripts_basename}" '`' "${scripts_basename}" > /dev/stderr;
			breaksw;
	endsw
	set last_exception_handled=$errno;
	echo -n ".\n";
	
	if( ! ${?no_exit_on_exception} || ! ${?callback} ) then
		if(! ${?0} ) then
			set callback="scripts_main_quit";
		else
			set callback="scripts_sourcing_quit";
		endif
		if( ${?display_usage_on_exception} ) \
			goto usage;
		
		goto callback_handler;
	endif
	
	echo -n "\tPlease see: "\`"${scripts_basename} --help"\`" for more information and supported options.\n" > /dev/stderr;
	
	if(! ${?callback} ) \
		set callback="scripts_main_quit";
	
	if( ${?display_usage_on_exception} ) \
		goto usage;
	
	goto callback_handler;
#exception_handler:

parse_argv:
	set label_current="parse_argv";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ arg=0;
	
	@ arg=0;
	@ parsed_argc=0;
	@ argc=${#argv};
	
	if( ${?debug_arguments} && ! ${?debug} ) \
		set debug debug_set;
	
	if( ${?debug} ) \
		echo -n "**${scripts_basename} debug:** checking argv.  ${argc} total arguments.\n\n";
#parse_argv:

parse_arg:
	set label_current="parse_arg";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	while( $arg < $argc )
		if(! ${?arg_shifted} ) \
			@ arg++;
		
		if( ${?debug} ) \
			echo -n "**${scripts_basename} debug:** Checking argv #${arg} ($argv[$arg]).\n";
		
		set argument=`echo -n $argv[$arg] | sed -r 's/([\!\$\"])/"\\\1"/g'`;
		
		set dashes=`echo -n $argument | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)$/\1/'`;
		if( "${dashes}" == "${argument}" ) \
			set dashes="";
		
		set option=`echo -n $argument | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)$/\2/'`;
		if( "${option}" == "${argument}" ) \
			set option="";
		
		set equals=`echo -n $argument | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)$/\3/'`;
		
		set value=`echo -n $argument | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)$/\4/'`;
		
		if( ${?debug} ) \
			echo -n "\tparsed "\$"argument: [${argument}]; "\$"argv[${arg}] ($argv[$arg])\n\t"\$"dashes: [${dashes}];\n\t"\$"option: [${option}];\n\t"\$"equals: [${equals}];\n\t"\$"value: [${value}]\n\n";
		
		if( ( "${option}" != "${argument}" && "${option}" != "" ) && "${equals}" == "" && ( "${value}" == "" || "${value}" == "${argument}" ) ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				if( ${?debug} ) \
					echo -n "**${scripts_basename} debug:** Looking for replacement value.  Checking argv #${arg} ($argv[$arg]).\n";
				
				set test_argument=`echo -n $argv[$arg] | sed -r 's/([\!\$\"])/"\\\1"/g'`;
				
				set test_dashes=`echo -n ${test_argument} | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)$/\1/'`;
				set test_option=`echo -n ${test_argument} | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)$/\2/'`;
				set test_equals=`echo -n ${test_argument} | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)$/\3/'`;
				set test_value=`echo -n ${test_argument} | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)$/\4/'`;
				
				if( "${test_dashes}" != "${test_argument}" && "${test_option}" != "${test_argument}" && ( "${test_value}" == "" || "${test_value}" == "${argument}" ) ) then
					@ arg--;
				else
					if( ${?debug} ) \
						echo -n "\tparsed replacement value from "\$"test_argument: [${test_argument}]; "\$"argv[${arg}] ($argv[$arg])\n\t"\$"test_dashes: [${test_dashes}];\n\t"\$"test_option: [${test_option}];\n\t"\$"test_equals: [${test_equals}];\n\t"\$"test_value: [${test_value}]\n\n";
					
					set equals="=";
					set value="${test_argument}";
					set arg_shifted;
				endif
				unset test_argument test_dashes test_option test_equals test_value;
			endif
		endif
		
		@ parsed_argc++;
		if( "${option}" == "${value}" ) \
			set option="";
		set parsed_arg="${dashes}${option}${equals}${value}";
		if(! ${?parsed_argv} ) then
			set parsed_argv="${parsed_arg}";
		else
			set parsed_argv="${parsed_argv} ${parsed_arg}";
		endif
		
		if( ${?debug} ) \
			echo -n "\tparsed option "\$"parsed_argv[${parsed_argc}]: ${parsed_arg}\n\n" "";
		
		switch("${option}")
			case "numbered_option":
				if(! ( "${value}" != "" && ${value} > 0 )) then
					echo -n "${dashes}${option} must be followed by a valid number greater than zero.";
					@ errno=-601;
					goto exception_handler;
					breaksw;
				endif
			
				set numbered_option="${value}";
				breaksw;
			
			case "length_option":
				if( `echo -n ${value} | sed -r 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}$//'` != "" ) then
					echo -n "Invalid ${dashes}${option}: ${value} specified, lenth must be formatted as: hh:mm:ss\n" > /dev/stderr;
					@ errno=-602;
					goto exception_handler;
					breaksw;
				endif
				
				set rtrim="${value}";
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
						breaksw;
					
					default:
						set switch_option;
						breaksw;
				endsw
				
				if( ${?debug} ) \
					echo -n "**${scripts_basename} debug:**, via "\$"argv[${arg}], ${option}:\t[disabled].\n\n";
				breaksw;
			
			case "enable":
				switch("${value}")
					case "switch-option":
						if( ${?switch_option} ) \
							breaksw;
						
						if( ${?debug} ) \
							echo -n "**${scripts_basename} debug:**, via "\$"argv[${arg}], ${value} mode:\t[${option}d].\n\n";
						set switch_option;
						breaksw;
					
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						echo -n "**${scripts_basename} debug:**, via "\$"argv[${arg}], verbose output:\t[${option}d].\n\n";
						set be_verbose;
						breaksw;
					
					default:
						echo -n "enabling ${value} is not supported.  See "\`"${scripts_basename} --help"\`"\n";
						breaksw;
				endsw
				breaksw;
			
			case "disable":
				switch("${value}")
					case "switch-option":
						if(! ${?switch_option} ) \
							breaksw;
						
						if( ${?debug} ) \
							echo -n "**${scripts_basename} debug:**, via "\$"argv[${arg}], ${value} mode:\t[${option}d].\n\n";
						unset switch_option;
						breaksw;
					
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						echo -n "**${scripts_basename} debug:**, via "\$"argv[${arg}], verbose output:\t[${option}d].\n\n";
						unset be_verbose;
						breaksw;
					
					default:
						echo -n "disabling ${value} is not supported.  See "\`"${scripts_basename} --help"\`"\n";
						breaksw;
				endsw
				breaksw;
			
			default:
				if( -e "`echo -n "\""${value}"\""`" ) then
					set callback="filename_list_append_value";
					goto callback_handler;
				endif
				
				if(! ${?strict} ) \
					breaksw;
				
				if(! ${?no_exit_on_exception} ) \
					set no_exit_on_exception;
				
				@ errno=-504;
				set callback="parse_arg";
				goto exception_handler;
				breaksw;
		endsw
		
		if( ${?arg_shifted} ) then
			unset arg_shifted;
			@ arg--;
		endif
		
		unset dashes option equals value parsed_arg;
	end
#parse_arg:


parse_argv_quit:
	set label_current="parse_argv_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?debug_set} ) \
		unset debug debug_set;
	
	if(! ${?callback} ) then
		unset arg;
	else
		if( "${callback}" != "parse_arg" ) then
			unset arg;
		endif
	endif
	
	if( ${?diagnostic_mode} ) then
		set callback="diagnostic_mode";
	else if(! ${?callback} ) then
		set callback="if_sourced";
	endif
	
	goto callback_handler;
#parse_argv_quit:


filename_list_append_value:
	set label_current="filename_list_append_value";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set value="`echo -n "\""${value}"\""`";
	if(! ${?filename_list} ) then
		set filename_list="./.${scripts_basename}.filenames@`date '+%s'`";
		touch "${filename_list}";
	endif
	
	if(! ${?scripts_supported_extensions} ) then
		if( ${?debug} || ${?debug_filelist}  ) then
			echo -n "Adding [${value}] to [${filename_list}].\nBy running:\n\tfind -L "\""$value"\""";
			if(! ${?supports_hidden_files} ) \
				echo -n  \! -iregex '.*\/\..*';
			echo -n "| sort >> "\""${filename_list}"\""\n\n";
		endif
		if(! ${?supports_hidden_files} ) then
			find -L "$value" \! -iregex '.*\/\..*' | sort >> "${filename_list}";
		else
			find -L "$value" | sort >> "${filename_list}";
		endif
		
		set callback="parse_arg";
		goto callback_handler;
	endif
	
	if( "${scripts_supported_extensions}" == "mp3|ogg|m4a|wav" && ! ${?ltrim} && ! ${?rtrim} ) \
		set scripts_supported_extensions="mp3|m4a|wav";
	
	if( ${?debug}  || ${?debug_filelist} ) then
		if(! -d "$value" ) then
			echo -n "Adding [${value}] to [${filename_list}] if its a supported file type.\nSupported extensions are:\n\t`echo -n '${scripts_supported_extensions}' | sed -r 's/\|/,\ /g'`.\n";
		else
			echo -n "Adding any supported files found under [${value}] to [${filename_list}].\nSupported extensions are:\n\t`echo -n '${scripts_supported_extensions}' | sed -r 's/\|/,\ /g'`.\n";
		endif
		echo -n "By running:\n\tfind -L "\""$value"\"" -regextype posix-extended -iregex "\"".*\.(${scripts_supported_extensions})"\"""\$"";
		if(! ${?supports_hidden_files} ) \
			echo -n " \! -iregex '.*\/\..*'";
		echo -n " | sort >> "\""${filename_list}"\""\n\n";
	endif
	
	if(! ${?supports_hidden_files} ) then
		find -L "$value" -regextype posix-extended -iregex ".*\.(${scripts_supported_extensions})"\$ \! -iregex '.*\/\..*'  | sort >> "${filename_list}";
	else
		find -L "$value" -regextype posix-extended -iregex ".*\.(${scripts_supported_extensions})"\$ | sort >> "${filename_list}";
	endif
	
	set callback="parse_arg";
	goto callback_handler;
#filename_list_append_value:


diagnostic_mode:
	set label_current="diagnostic_mode";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! -d "${HOME}/tmp" ) then
		set scripts_diagnosis_log="/tmp/${scripts_basename}.diagnosis.log";
	else
		set scripts_diagnosis_log="${HOME}/tmp/${scripts_basename}.diagnosis.log";
	endif
	if( -e "${scripts_diagnosis_log}" ) \
		rm -v "${scripts_diagnosis_log}";
	touch "${scripts_diagnosis_log}";
	printf "----------------%s debug.log-----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	printf \$"argv:\n\t%s\n\n" "$argv" >> "${scripts_diagnosis_log}";
	printf \$"parsed_argv:\n\t%s\n\n" "$parsed_argv" >> "${scripts_diagnosis_log}";
	printf \$"{0} == [%s]\n" "${0}" >> "${scripts_diagnosis_log}";
	@ arg=0;
	while( "${1}" != "" )
		@ arg++;
		printf \$"{%d} == [%s]\n" $arg "${1}" >> "${scripts_diagnosis_log}";
		shift;
	end
	printf "\n\n----------------<%s> environment-----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	env >> "${scripts_diagnosis_log}";
	printf "\n\n----------------<%s> variables-----------------\n" "${scripts_basename}" >> "${scripts_diagnosis_log}";
	set >> "${scripts_diagnosis_log}";
	printf "Create %s diagnosis log:\n\t%s\n" "${scripts_basename}" "${scripts_diagnosis_log}";
	@ errno=-500;
	if(! ${?being_sourced} ) then
		set callback="scripts_main_quit";
	else
		set callback="sourcing_main_quit";
	endif
	goto exception_handler;
#diagnostic_mode:


label_stack_set:
	if( ${?current_cwd} ) then
		if( ${current_cwd} != ${cwd} ) \
			cd ${current_cwd};
		unset current_cwd;
	endif
	
	if( ${?old_owd} ) then
		if( ${old_owd} != ${owd} ) then
			set owd=${old_owd};
		endif
	endif
	
	set old_owd="${owd}";
	set current_cwd="${cwd}";
	set escaped_cwd="`printf "\""%s"\"" "\""${cwd}"\"" | sed -r 's/\//\\\//g' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/([\[])/\\\1/g'`";
	
	set label_next=${label_current};
	
	if(! ${?labels_previous} ) then
		set labels_previous=("${label_current}");
		set label_previous=$labels_previous[${#labels_previous}];
	else
		if("${label_current}" != "$labels_previous[${#labels_previous}]" ) then
			set labels_previous=($labels_previous "${label_current}");
			set label_previous=$labels_previous[${#labels_previous}];
		else
			set label_previous=$labels_previous[${#labels_previous}];
			unset labels_previous[${#labels_previous}];
		endif
	endif
	
	#set callback=${label_previous};
	
	if( ${?debug} ) \
		printf "handling label_current: [%s]; label_previous: [%s].\n" "${label_current}" "${label_previous}" > /dev/stdout;
	
	goto ${label_previous};
#label_stack_set:


callback_handler:
	if(! ${?callback} ) \
		set callback="scripts_main_quit";
	
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
		unset callback;
	endif
	if( ${?debug} ) \
		printf "handling callback to [%s].\n" "${last_callback}" > /dev/stdout;
	
	goto $last_callback;
#callback_handler:


