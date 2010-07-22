#!/bin/tcsh -f
set label_current="init";
goto label_stack_set;


exit_script:
	set label_current="exit_script";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ! ${?0} && ${?supports_being_sourced} ) then
		set callback="scripts_sourcing_quit";
	else
		set callback="scripts_main_quit";
	endif
	goto callback_handler;
#exit_script:


init:
	set label_current="init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	onintr exit_script;
	
	set strict;
	set original_owd=${owd};
	set starting_dir=${cwd};
	set escaped_starting_dir=${escaped_cwd};
	
	set scripts_basename="playlist:find:non-existent:listings.tcsh";
	set script_alias="`printf '%s' '${scripts_basename}' | sed -r 's/(.*)\.(tcsh|cshrc)"\$"/\1/'`";
	#set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	
	set escaped_home_dir="`printf "\""%s"\"" "\""${HOME}"\"" | sed -r 's/\//\\\//g' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
	
	if( "`alias cwdcmd`" != "" ) then
		set oldcwdcmd="`alias cwdcmd`";
		unalias cwdcmd;
	endif
	
	@ errno=0;
	
	#set supports_being_source;
	#set argz="";
	#set script_supported_extensions="mp3|ogg|m4a";
	
	alias ex "ex -E -X -n --noplugin";
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	#alias "curl" "${download_command_with_options}";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --quiet --continue --output-document";
	#alias "wget" "${download_command_with_options}";
#init:

dependencies_check:
	onintr scripts_main_quit;
	set label_current="dependencies_check";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set dependencies=("${scripts_basename}" "playlist:new:create.tcsh" "playlist:new:save.tcsh");# "${script_alias}");
	@ dependencies_index=0;
#dependencies_check:


dependency_check:
	set label_current="dependency_check";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		set dependency=$dependencies[$dependencies_index];
		if( ${?debug} ) \
			printf "\n**%s debug:** looking for dependency: %s.\n\n" "${scripts_basename}" "${dependency}";
			
		foreach program("`where "\""${dependency}"\""`")
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
			
			printf "**%s debug:** %d%s dependency: %s ( binary: %s )\t[found]\n" "${scripts_basename}" ${dependencies_index} "${suffix}" "${dependency}" "${program}";
			unset suffix;
		endif
		
		switch("${dependency}")
			case "${scripts_basename}":
				if( ${?script} ) \
					breaksw;
				
				set old_owd="${cwd}";
				cd "`dirname '${program}'`";
				set scripts_path="${cwd}";
				cd "${owd}";
				set owd="${old_owd}";
				unset old_owd;
				set script="${scripts_path}/${scripts_basename}";
				breaksw;
			
			default:
				if(! ${?execs} ) \
					set execs=()
				set execs=(${execs} "${program}");
				breaksw;
		endsw
		
		unset program;
	end
	
	set callback="dependencies_found";
	goto callback_handler;
#dependency_check:


dependencies_found:
	set label_current="dependencies_found";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	unset dependency dependencies dependencies_index;
	
	set callback="parse_argv";
	goto callback_handler;
#dependencies_found:
	


if_sourced:
	set label_current="if_sourced";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?0} ) then
		set callback="main";
	else if( ${?supports_being_source} ) then
		set callback="sourcing_init";
	else
		@ errno=-502;
		goto exception_handler;
	endif
	
	goto callback_handler;
#if_sourced:


sourcing_init:
	set label_current="sourcing_init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	onintr sourcing_main_quit;
	# BEGIN: source scripts_basename support.
	if(! ${?TCSH_RC_SESSION_PATH} ) \
		setenv TCSH_RC_SESSION_PATH "${scripts_path}/../tcshrc";
	source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
	
	# START: special handler for when this file is sourced.
	source "${TCSH_RC_SESSION_PATH}/argv:check" "${scripts_basename}" ${argv};
	set callback="sourcing_main";
	goto callback_handler;
#sourcing_init:


sourcing_main:
	set label_current="sourcing_main";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! ${?TCSH_RC_SESSION_PATH} ) \
		setenv TCSH_RC_SESSION_PATH "${scripts_path}/../tcshrc";
	
	# START: special handler for when this file is sourced.
	alias "${script_alias}" \$"{TCSH_LAUNCHER_PATH}/${scripts_basename}";
	# FINISH: special handler for when this file is sourced.
	set callback="sourcing_main_quit";
	goto callback_handler;
#sourcing_main:


sourcing_main_quit:
	set label_current="sourcing_main_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	onintr scripts_main_quit;
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${scripts_basename}";
	
	# END: source scripts_basename support.
	
	set callback="scripts_main_quit";
	goto callback_handler;
#sourcing_main_quit:


main:
	set label_current="main";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?debug} ) \
		printf "Executing %s's main.\n" "${scripts_basename}";
	
	if(! ${?playlist} ) then
		@ errno=-506;
		set callback="parse_arg";
		goto exception_handler;
	endif
	
	if(! -e "${playlist}" ) then
		@ errno=-506;
		set callback="parse_arg";
		goto exception_handler;
	endif
	
	onintr parse_arg;
	
	if( `printf "%s" "${playlist}" | sed -r 's/^(\/).*$/\1/'` != "/" ) \
		set playlist="${cwd}/${playlist}";
	set playlist="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/(\/)(\/)/\1/g'`";
	while( `printf "%s" "${playlist}" | sed -r 's/^(.*)(\/\.\/)(.*)$/\2/'` == "/./" )
		set playlist="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/(\/\.\/)/\//'`";
	end
	while( `printf "%s" "${playlist}" | sed -r 's/^(.*)(\/\.\.\/)(.*)$/\2/'` == "/../" )
		set playlist="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/(.*)(\/[^/.]{2}.+)(\/\.\.\/)(.*)"\$"/\1\/\4/'`";
	end
	
	if( ${?edit_playlist} ) \
		${EDITOR} "${playlist}";
	
	printf "Ensuring that all files listed in: <file://%s> still exists.\n" "${playlist}";
	playlist:new:create.tcsh "${playlist}";
	if(! ${?filename_list} ) \
		set filename_list="`mktemp --tmpdir filenames.${scripts_basename}.XXXXXX`";
	mv -f "${playlist}.swap" "${filename_list}";
	if(! ${?clean_up} ) \
		rm -f "${playlist}.new";
	set callback="exec";
	goto callback_handler;
#main:


exec:
	set label_current="exec";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?debug} ) \
		printf "Executing %s's exec.\n" "${scripts_basename}";
	
	if( ${?filename_list} ) then
		if( ${?filename} ) then
			if( -e "${filename}.${extension}" ) then
				if( ${?clean_up} ) then
					printf "%s.%s\n" "${filename}" "${extension}" >> "${playlist}.new";
				endif
			else
				if(! ${?dead_file_count} ) then
					if( ${?clean_up} ) \
						printf "\tThese files will be removed from <file://%s>:\n" "${playlist}";
					@ dead_file_count=1;
				else
					@ dead_file_count++;
				endif
				printf "%s.%s\n" "${filename}" "${extension}";
			endif
		endif
		set callback="filename_next";
		goto callback_handler;
	endif
	set callback="format_new_playlist";
	goto callback_handler;
#exec:

filename_next:
	foreach original_filename("`cat "\""${filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`")
		ex -s '+1d' '+wq!' "${filename_list}";
		set extension="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/g'`";
		set filename="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\1/g'`";
		set callback="exec";
		goto callback_handler;
	end
	rm "${filename_list}";
	unset filename filename_list;
#filename_next:

format_new_playlist:
	if(! ${?clean_up} ) then
		printf "%s has finished processing:\n\t<file//%s>\n" "${scripts_basename}" "${playlist}";
	else
		printf "<file//%s> now only contains existing files.\n" "${playlist}";
		if( ${?dead_file_count} ) then
			printf "\n";
			playlist:new:save.tcsh --save-empty --force "${playlist}";
			printf "\n";
			unset dead_file_count;
		endif
	endif
	unset playlist;
	
	set callback="parse_arg";
	goto callback_handler
#format_new_playlist:

scripts_main_quit:
	set label_current="scripts_main_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if( ${?playlist} ) then
		if( -e "${playlist}.swap" ) \
			rm "${playlist}.swap";
		if( -e "${playlist}.new" ) \
			rm "${playlist}.new";
		unset playlist;
	endif
	
	if( ${?clean_up} ) \
		unset clean_up;
	if( ${?dead_file_count} ) \
		unset dead_file_count;
	
	if( ${?label_current} ) \
		unset label_current;
	if( ${?label_previous} ) \
		unset label_previous;
	if( ${?labels_previous} ) \
		unset labels_previous;
	if( ${?label_next} ) \
		unset label_next;
	
	if( ${?argc} ) \
		unset argc;
	if( ${?argz} ) \
		unset argz;
	if( ${?parsed_arg} ) \
		unset parsed_arg;
	if( ${?parsed_argv} ) \
		unset parsed_argv;
	if( ${?parsed_argc} ) \
		unset parsed_argc;
	
	if( ${?supports_being_source} ) \
		unset supports_being_source;
	
	if( ${?script_alias} ) \
		unset script_alias;
	if( ${?scripts_basename} ) \
		unset scripts_basename;
	if( ${?scripts_pathe} ) \
		unset scripts_pathe;
	if( ${?script} ) \
		unset script;
	
	if( ${?nodeps} ) \
		unset nodeps;
	if( ${?dependency} ) \
		unset dependency;
	if( ${?dependencies} ) \
		unset dependencies;
	if( ${?missing_dependency} ) \
		unset missing_dependency;
	
	if( ${?usage_displayed} ) \
		unset usage_displayed;
	if( ${?exit_on_usage} ) \
		unset exit_on_usage;
	if( ${?display_usage_on_error} ) \
		unset display_usage_on_error;
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
	if( ${?arg_shifted} ) \
		unset arg_shifted;
	
	if( ${?escaped_cwd} ) \
		unset escaped_cwd;
	if( ${?escaped_home_dir} ) \
		unset escaped_home_dir;
	if( ${?escaped_starting_dir} ) \
		unset escaped_starting_dir;
	
	if( ${?old_owd} ) \
		unset old_owd;
	
	if( ${?starting_cwd} ) then
		if( "${starting_cwd}" != "${cwd}" ) \
			cd "${starting_cwd}";
	endif
	
	if( ${?original_owd} ) then
		set owd="${original_owd}";
		unset original_owd;
	endif
	
	if( ${?oldcwdcmd} ) then
		alias cwdcmd "${oldcwdcmd}";
		unset oldcwdcmd;
	endif
	
	if( ${?script_supported_extensions} ) \
		unset script_supported_extensions;
	if( ${?filename_list} ) then
		if( ${?filename} ) \
			unset filename;
		if( ${?extension} ) \
			unset extension;
		
		if( -e "${filename_list}" ) \
			rm "${filename_list}";
		unset filename_list;
	endif
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
	if( ${?debug} ) \
		unset debug;
	if( ${?script_diagnosis_log} ) \
		unset script_diagnosis_log;
	
	if( ${?strict} ) \
		unset strict;
	
	if(! ${?errno} ) then
		set status=0;
	else
		set status=$errno;
		unset errno;
	endif
	exit ${status}
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
	
	if(! ${?script} ) then
		printf "Usage:\n\t%s [options]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.\n" "${scripts_basename}";
	else if( "${program}" != "${script}" ) then
		${program} --help;
	endif
	
	if(! ${?usage_displayed} ) \
		set usage_displayed;
	
	if( ${?exit_on_usage} ) then
		set callback="scripts_main_quit";
	else if(! ${?callback} ) then
		set callback="parse_arg";
	endif
	goto callback_handler;
#usage:


exception_handler:
	set label_current="exception_handler";
	if( "${label_next}" != "${label_current}" ) \
		goto label_stack_set;
	
	if(! ${?errno} ) \
		@ errno=-599;
	printf "\n**%s error("\$"errno:%d):**\n\t" "${scripts_basename}" $errno;
	switch( $errno )
		case -500:
			printf "Debug mode has triggered an exception for diagnosis.  Please see any output above.\n" "${scripts_basename}" > /dev/stderr;
			@ errno=0;
			breaksw;
		
		case -501:
			printf "One or more required dependencies couldn't be found.\n\t[%s] couldn't be found.\n\t%s requires: %s" "${dependency}" "${scripts_basename}" "${dependencies}";
			breaksw;
		
		case -502:
			printf "Sourcing is not supported and may only be executed" > /dev/stderr;
			breaksw;
		
		case -503:
			printf "An internal script error has caused an exception.  Please see any output above" > /dev/stderr;
			if(! ${?debug} ) \
				printf " or run: %s%s --debug%s to find where %s failed" '`' "${scripts_basename}" '`' "${scripts_basename}" > /dev/stderr;
			printf ".\n" > /dev/stderr;
			breaksw;
		
		case -504:
			printf "One or more required options have not been provided." > /dev/stderr;
			breaksw;
		
		case -505:
			printf "%s%s is an unsupported option.\n\tPlease see: %s%s --help%s for supported options and details" "${dashes}" "${option}" '`' "${scripts_basename}" '`' > /dev/stderr;
			breaksw;
		
		case -506:
			printf "<file://%s> does not exist.\nA valid and existing playlist must be specified.\n\tPlease see: %s%s --help%s for supported options and details" "${playlist}" '`' "${scripts_basename}" '`' > /dev/stderr;
			unset playlist;
			breaksw;
		
		case -599:
		default:
			printf "An unknown error "\$"errno: %s has occured" "${errno}" > /dev/stderr;
			breaksw;
	endsw
	set last_exception_handled=$errno;
	printf "\nrun: %s%s --help%s for more information\n" '`' "${scripts_basename}" '`' > /dev/stderr;
	
	if( ${?display_usage_on_error} ) \
		goto usage;
	
	if( ${?callback} ) \
		goto callback_handler;
	
	goto scripts_main_quit;
#exception_handler:

parse_argv:
	set label_current="parse_argv";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ argc=${#argv};
	@ required_options=0;
	
	if( ${argc} < ${required_options} ) then
		@ errno=-504;
		set callback="parse_argv_quit";
		goto exception_handler;
	endif
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		switch("$argv[$arg]")
			case "--diagnosis":
			case "--diagnostic-mode":
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				if(! ${?debug} ) \
					set debug;
				break;
			
			case "--debug":
				printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set debug;
				break;
			
			default:
				continue;
		endsw
	end
	
	if( ${?debug} ) \
		printf "**%s debug:** checking argv.  %d total arguments.\n\n" "${scripts_basename}" "${argc}";
	
	@ arg=0;
	@ parsed_argc=0;
	unset strict;
#parse_argv:

parse_arg:
	set label_current="parse_arg";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	while( $arg < $argc )
		if(! ${?arg_shifted} ) \
			@ arg++;
		
		if( ${?debug} ) \
			printf "**%s debug:** Checking argv #%d (%s).\n" "${scripts_basename}" "${arg}" "$argv[$arg]";
		
		set dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) \
			set dashes="";
		
		set option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
		if( "${option}" == "$argv[$arg]" ) \
			set option="";
		
		set equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
		if( "${equals}" == "$argv[$arg]" ) \
			set equals="";
		
		set value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
		if( "${dashes}" != "" && "${option}" != "" && "${equals}" == "" && "${value}" == "" ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				if( ${?debug} ) \
					printf "**%s debug:** Looking for replacement value.  Checking argv #%d (%s).\n" "${scripts_basename}" "${arg}" "$argv[$arg]";
				
				set test_dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
				if( "${test_dashes}" == "$argv[$arg]" ) \
					set test_dashes="";
				
				set test_option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
				if( "${test_option}" == "$argv[$arg]" ) \
					set test_option="";
				
				set test_equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
				if( "${test_equals}" == "$argv[$arg]" ) \
					set test_equals="";
				
				set test_value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^\ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g' | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
				
				if( ${?debug} ) \
					printf "\tparsed %sargv[%d] (%s) to test for replacement value.\n\tparsed %stest_dashes: [%s]; %stest_option: [%s]; %stest_equals: [%s]; %stest_value: [%s]\n" \$ "${arg}" "$argv[$arg]" \$ "${test_dashes}" \$ "${test_option}" \$ "${test_equals}" \$ "${test_value}";
				
				if(!( "${test_dashes}" == "" && "${test_option}" == "" && "${test_equals}" == "" && "${test_value}" == "$argv[$arg]" )) then
					@ arg--;
				else
					set equals=" ";
					set value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/(["\$"])/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/(\[)/\\\1/g' | sed -r 's/([*])/\\\1/g'`";
					set arg_shifted;
				endif
				unset test_dashes test_option test_equals test_value;
			endif
		endif
		
		if( -e "${value}" ) then
			if( `printf "%s" "${value}" | sed -r 's/^(\/).*$/\1/'` != "/" ) \
				set value="${cwd}/${value}";
			set value_file="`mktemp --tmpdir .escaped.relative.filename.value.XXXXXXXX`";
			printf "%s" "${value}" >! "${value_file}";
			ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
			set escaped_value="`cat "\""${value_file}"\""`";
			rm -f "${value_file}";
			unset value_file;
			set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/)(\/)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
			while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\/)(.*)"\$"/\2/'`" == "/./" )
				set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/\.\/)/\//' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
			end
			while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\.\/)(.*)"\$"/\2/'`" == "/../" )
				set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(.*)(\/[^.]{2}[^/]+)(\/\.\.\/)(.*)"\$"/\1\/\4/' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
			end
			set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
			unset escaped_value;
		endif
		
		@ parsed_argc++;
		set parsed_arg="${dashes}${option}${equals}${value}";
		if(! ${?parsed_argv} ) then
			set parsed_argv="${parsed_arg}";
		else
			set parsed_argv="${parsed_argv} ${parsed_arg}";
		endif
		
		if( ${?debug} ) \
			printf "\tparsed option %sparsed_argv[%d]: %s\n" \$ "$parsed_argc" "${parsed_arg}";
		
		switch("${option}")
			case "numbered_option":
				if(! ( "${value}" != "" && ${value} > 0 )) then
					printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}";
					breaksw;
				endif
			
				set numbered_option="${value}";
				breaksw;
			
			case "edit-playlist":
				if(! ${?edit_playlist} ) \
					set edit_playlist;
				breaksw;
			
			case "h":
			case "help":
				goto usage;
				breaksw;
			
			case "verbose":
				if(! ${?be_verbose} ) \
					set be_verbose;
				breaksw;
			
			case "playlist":
				if(! -e "${value}" ) then
					@ errno=-506;
					set callback="parse_arg";
					goto exception_handler;
					breaksw;
				endif
				set playlist="${value}";
				breaksw;
			
			case "debug":
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "diagnosis":
			case "diagnostic-mode":
				if( ${?diagnostic_mode} ) \
					breaksw;
				
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "do-not-clean-up":
			case "no-clean-up":
				if(! ${?clean_up}) \
					breaksw;
				
				unset clean_up;
				
				if( ${?debug} ) \
					printf "**%s debug:**, via "\$"argv[%d], %s:\t[enabled].\n\n" "${scripts_basename}" $arg "${option}";
				breaksw;
			
			case "clean-up":
				if( ${?clean_up}) \
					breaksw;
				
				set clean_up;
				
				if( ${?debug} ) \
					printf "**%s debug:**, via "\$"argv[%d], %s:\t[enabled].\n\n" "${scripts_basename}" $arg "${option}";
				breaksw;
			
			case "enable":
				switch("${value}")
					case "clean-up":
						if( ${?clean_up} ) \
							breaksw;
						
						if( ${?debug} ) \
							printf "**%s debug:**, via "\$"argv[%d], clean-up mode:\t[%sed].\n\n" "${scripts_basename}" $arg "${option}";
						set clean_up;
						breaksw;
					
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], verbose output\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						set be_verbose;
						breaksw;
					
					default:
						printf "enabling %s is not supported by %s.  See %s --help\n" "${value}" "${scripts_basename}" "${scripts_basename}";
						breaksw;
				endsw
				breaksw;
			
			case "disable":
				switch("${value}")
					case "clean-up":
						if(! ${?clean_up} ) \
							breaksw;
						
						if( ${?debug} ) \
							printf "**%s debug:**, via "\$"argv[%d], clean-up mode:\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						unset clean_up;
						breaksw;
					
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						printf "**%s debug:**, via "\$"argv[%d], verbose output\t[%sd].\n\n" "${scripts_basename}" $arg "${option}";
						unset be_verbose;
						breaksw;
					
					default:
						printf "disabling %s is not supported by %s.  See %s --help\n" "${value}" "${scripts_basename}" "${scripts_basename}";
						breaksw;
				endsw
				breaksw;
			
			case "nodeps":
			case "debug":
			case "diagnosis":
			case "diagnostic-mode":
				breaksw;
					
			default:
				if( -e "${value}" && ! ${?playlist} ) then
					set playlist="${value}";
					breaksw;
				endif
				
				if(! ${?strict} ) \
					breaksw;
				
				if(! ${?argz} ) then
					@ errno=-505;
					set callback="parse_arg";
					goto exception_handler;
					breaksw;
				endif
				
				if( "${argz}" == "" ) then
					set argz="$parsed_arg";
				else
					set argz="${argz} $parsed_arg";
				endif
				breaksw;
		endsw
		
		if( ${?arg_shifted} ) then
			unset arg_shifted;
			@ arg--;
		endif
		
		unset dashes option equals value parsed_arg;
		
		if( ${?playlist} ) then
			set callback="if_sourced";
			goto callback_handler;
		endif
	end
#parse_arg:


parse_argv_quit:
	set label_current="parse_argv_quit";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! ${?callback} ) then
		unset arg argc;
	else
		if( "${callback}" != "parse_arg" ) then
			unset arg;
		endif
	endif
	if(! ${?0} ) then
		set callback="if_source";
	else if( ${?diagnostic_mode} ) then
		set callback="diagnostic_mode";
	else
		set callback="exit_script";
	endif
	
	goto callback_handler;
#parse_argv_quit:


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
	#if(! -d "`printf "\""%s"\"" "\""${escaped_cwd}"\"" | sed -r 's/\\([*])/\1/g' | sed -r 's/\\([\[])/\1/g'`" ) then
	#	set cwd_files=();
	#else
	#	set cwd_files="`/bin/ls "\""${escaped_cwd}"\""`";
	#endif
	
	set label_next=${label_current};
	
	if(! ${?labels_previous} ) then
		set labels_previous=("${label_current}");
		set label_previous="$labels_previous[${#labels_previous}]";
	else
		if("${label_current}" != "$labels_previous[${#labels_previous}]" ) then
			set labels_previous=($labels_previous "${label_current}");
			set label_previous="$labels_previous[${#labels_previous}]";
		else
			set label_previous="$labels_previous[${#labels_previous}]";
			unset labels_previous[${#labels_previous}];
		endif
	endif
	
	set callback=${label_previous};
	
	if( ${?debug} ) \
		printf "handling label_current: [%s]; label_previous: [%s].\n" "${label_current}" "${label_previous}" > /dev/stdout;
	goto callback_handler;
#label_stack_set:


callback_handler:
	if(! ${?callback} ) then
		if(! ${?callback_stack} ) then
			goto scripts_main_quit;
		else
			set callback="$callback_stack[${#callback_stack}]";
			unset callback_stack[${#callback_stack}];
		endif
	endif
	
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
		printf "handling callback to [%s].\n" "${last_callback}" > /dev/stdout;
	
	goto $last_callback;
#callback_handler:


diagnostic_mode:
	set label_current="diagnostic_mode";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! -d "${HOME}/tmp" ) then
		set script_diagnosis_log="/tmp/${scripts_basename}.diagnosis.log";
	else
		set script_diagnosis_log="${HOME}/tmp/${scripts_basename}.diagnosis.log";
	endif
	if( -e "${script_diagnosis_log}" ) \
		rm -v "${script_diagnosis_log}";
	touch "${script_diagnosis_log}";
	printf "----------------%s debug.log-----------------\n" "${scripts_basename}" >> "${script_diagnosis_log}";
	printf \$"argv:\n\t%s\n\n" "$argv" >> "${script_diagnosis_log}";
	printf \$"parsed_argv:\n\t%s\n\n" "$parsed_argv" >> "${script_diagnosis_log}";
	printf \$"{0} == [%s]\n" "${0}" >> "${script_diagnosis_log}";
	@ arg=0;
	while( "${1}" != "" )
		@ arg++;
		printf \$"{%d} == [%s]\n" $arg "${1}" >> "${script_diagnosis_log}";
		shift;
	end
	printf "\n\n----------------<%s> environment-----------------\n" "${scripts_basename}" >> "${script_diagnosis_log}";
	env >> "${script_diagnosis_log}";
	printf "\n\n----------------<%s> variables-----------------\n" "${scripts_basename}" >> "${script_diagnosis_log}";
	set >> "${script_diagnosis_log}";
	printf "Create %s diagnosis log:\n\t%s\n" "${scripts_basename}" "${script_diagnosis_log}";
	@ errno=-500;
	set callback="exit_script";
	goto exception_handler;
#diagnostic_mode:

