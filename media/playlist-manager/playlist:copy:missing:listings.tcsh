#!/bin/tcsh -f
setenv:
	onintr exit_script;
	
	if( "`alias cwdcmd`" != "" ) then
		set original_cwdcmd="`alias cwdcmd`";
		unalias cwdcmd;
	endif
	
	if( ${?GREP_OPTIONS} ) then
		set grep_options="${GREP_OPTIONS}";
		unsetenv GREP_OPTIONS;
	endif
	
	set scripts_basename="playlist:copy:missing:listings.tcsh";
	set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	set scripts_alias="`printf "\""${scripts_basename}"\"" | sed -r 's/(.*)\.(tcsh|cshrc)"\$"/\1/'`";
	
	set strict;
	#set supports_being_sourced;
	
	alias ex "ex -E -X -n --noplugin";
	
	#set supports_multiple_files;
	#set supports_hidden_files;
	#set scripts_supported_extensions="mp3|ogg|m4a";
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	#alias "curl" "${download_command_with_options}";
	
	#set download_command="wget";
	#set download_command_with_options="${download_command} --no-check-certificate --quiet --continue --output-document";
	#alias "wget" "${download_command_with_options}";
	
#setenv:


set label_current="init";
goto label_stack_set;
init:
	set label_current="init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set usage_message="Usage:\n\t${scripts_basename} [path/to/playlist.(m3u|tox|pls)]\n\tPossible options are:\n\t\t[-h|--help]\tDisplays this screen.\n";
	
	set original_owd=${owd};
	set starting_dir=${cwd};
	set escaped_starting_cwd=${escaped_cwd};
	
	set argument_file="${scripts_tmpdir}/.escaped.dir.`date '+%s'`.file";
	printf "${HOME}" >! "${argument_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
	set escaped_cwd="`cat "\""${argument_file}"\"" | sed -r 's/([\[\/])/\\\1/g'`";
	rm -f "${argument_file}";
	unset argument_file;
#init:


debug_check:
	set label_current="debug_check";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	@ arg=0;
	@ argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		
		set argument_file="${scripts_tmpdir}/.escaped.argument.$scripts_basename.argv[$arg].`date '+%s'`.arg";
		printf "$argv[$arg]" >! "${argument_file}";
		ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
		set argument="`cat "\""${argument_file}"\""`";
		rm -f "${argument_file}";
		unset argument_file;
		
		set option="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
		set value="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
		if( -e "${value}" ) \
			continue;
		
		if( ${?debug} || ${?debug_arguments} ) \
			printf "**${scripts_basename} [debug_check:]**"\$"option: [${option}]; "\$"value: [${value}].\n";
		
		switch("${option}")
			case "diagnosis":
			case "diagnostic-mode":
				printf "**${scripts_basename} debug:**, via "\$"argv[$arg], diagnostic mode:\t[enabled].\n\n";
				set diagnostic_mode;
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "debug":
				switch("${value}")
					case "logged":
						if( ${?logging} ) \
							breaksw;
						
						printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], debug logging:\t[enabled].\n\n";
						set debug_logging;
						breaksw;
					
					case "argv":
					case "parse_argv":
					case "arguments":
						if( ${?debug_arguments} ) \
							breaksw;
						
						printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], debugging arguments:\t[enabled].\n\n";
						set debug_arguments;
						breaksw;
					
					case "filenames":
						if(! ${?supports_multiple_files} ) then
							printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], debugging ${value}:\t[unsupported].\n" > /dev/stderr;
							printf "**${scripts_basename} debug:** does not support handling or processing multiple files.\n" > /dev/stderr;
							breaksw;
						endif
						
						if( ${?debug_filenames} ) \
							breaksw;
						
						printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], debugging ${value}:\t[enabled].\n\n";
						set debug_filenames;
						breaksw;
					
					default:
						if( ${?debug} ) \
							breaksw;
						
						printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], debug mode:\t[enabled].\n\n";
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
	
	set dependencies=("${scripts_basename}" "playlist:new:create.tcsh");# "${script_alias}");
	@ dependencies_index=0;
	
	foreach dependency(${dependencies})
		@ dependencies_index++;
		unset dependencies[$dependencies_index];
		if( ${?debug} ) \
			printf "\n**${scripts_basename} debug:** looking for dependency: ${dependency}.\n\n"; 
			
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
			switch( "`printf "\""${dependencies_index}"\"" | sed -r 's/^[0-9]*[^1]?([1-3])"\$"/\1/'`" )
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
			
				if(! ${?execs} ) \
					set execs=()
				set execs=(${execs} "${program}");
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
	
	if( ${?0} ) then
		set callback="scripts_main";
	else if( ${?supports_being_sourced} ) then
		set callback="scripts_sourcing_main";
	else
		@ errno=-502;
		goto exception_handler;
	endif
	goto callback_handler;
	# END: disable source scripts_basename.
#if_sourced:


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


scripts_sourcing_main:
	set label_current="scripts_sourcing_main";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	# BEGIN: source scripts_basename support.
	if(! ${?TCSH_RC_SESSION_PATH} ) \
		setenv TCSH_RC_SESSION_PATH "${scripts_path}/../tcshrc";
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
	
	@ required_options=1;
	
	if( ${argc} < ${required_options} ) then
		@ errno=-503;
		set callback="parse_argv_quit";
		goto exception_handler;
	endif
	
	if(! ${?playlist} ) then
		@ errno=-601;
		goto exception_handler;
	endif
	
	if(! -e "${playlist}" ) then
		if(! ${?display_usage_on_exception} ) \
			set display_usage_on_exception;
		@ errno=-601;
		goto exception_handler;
	endif
	
	if(!( ${?filename_list} && ${?supports_multiple_files} )) then
		set callback="scripts_exec";
		goto callback_handler;
	endif
	
	set callback="filename_list_process_init";
	goto callback_handler;
#scripts_main:


scripts_exec:
	set label_current="scripts_exec";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	printf "Preparing to copy contents of %s" "${playlist}";
	playlist:new:create.tcsh "${playlist}";
	set tcsh_copy_script="`mktemp --tmpdir -u ${scripts_basename}.XXXXXXXXXX`.tcsh";
	
	printf '#\!/bin/tcsh -f\nset old_podcast="";\n' >! "${tcsh_copy_script}";
	chmod u+x "${tcsh_copy_script}";
	ex -s "+2r `printf "\""%s"\"" "\""${playlist}.swp"\"" | sed -r 's/(["\"\$\!"'\''\[\]\(\)\ \<\>])/\\\1/g'`" '+wq!' "${tcsh_copy_script}";
	/bin/rm "${playlist}.swp";
	/bin/rm "${playlist}.new";
	
	ex -s '+3,$s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${tcsh_copy_script}";
	ex -s '+3,$s/\v^(\/[^/]+\/[^/]+\/)(.*\/)?([^/]*)(\.[^.]+)$/if\(\! -e "\1\2\3\4" \) then\r\tif\(\! -e "\1nfs\/\2\3\4" \) then\r\t\tprintf "**error coping:** remote file\\n\\t\<\1nfs\/\2\3\4\> doesn'\''t exists.\\n" \> \/dev\/stderr;\r\telse\r\t\tset current_podcast="\1\2";\r\t\tif\(\! -d "${current_podcast}" \) \\\r\t\t\tmkdir -p "${current_podcast}";\r\t\t\r\t\tif\( "${old_podcast}" \!\= "`basename "\\""${current_podcast}"\\""`" \) then\r\t\t\tset old_podcast\="`basename "\\""${current_podcast}"\\""`";\r\t\t\tprintf "\\nCopying: ${old_podcast}'\''s content(s):";\r\t\tendif\r\t\tprintf "\\n\\tCopying: \3\4";\r\t\tcp "\1nfs\/\2\3\4" "\1\2\3\4";\r\t\tprintf "\\t\\t[finished]\\n";\r\tendif\rendif\r/' '+wq!' "${tcsh_copy_script}";
	
	printf "\t\t[finished]\n\nChecking for any missing files and copying them from the nfs share to local fs.\n";
	"${tcsh_copy_script}";
	/bin/rm "${tcsh_copy_script}";
	printf "\nCopying files from nfs share to local fs:\t[finished]\n";
	unset tcsh_copy_script;
	
	set callback="scripts_main_quit";
	goto callback_handler;
#scripts_exec:


filename_list_process_init:
	set label_current="filename_list_process_init";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	cat "${filename_list}" | sort | uniq > "${filename_list}.swp";
	mv -f "${filename_list}.swp" "${filename_list}";
	
	set file_count=`wc -l "${filename_list}" | sed -r 's/^([0-9]+)(.*)$/\1/'`;
	
	if(! ${file_count} > 0 ) then
		if( ${?no_exit_on_exception} ) \
			unset no_exit_on_exception;
		if(! ${?display_usage_on_exception} ) \
			set display_usage_on_exception;
		@ errno=-503;
		set callback="scripts_main_quit";
		goto exception_handler;
	endif
	
	@ files_processed=0;
	#ex -X -n --noplugin -s '+1,$s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${filename_list}";
	cp "${filename_list}" "${filename_list}.all";
	set callback="scripts_exec";
	goto callback_handler;
#filename_list_process_init:


filename_list_process:
	set label_current="filename_list_process";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	foreach original_filename("`cat "\""${filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )# | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g' | sed -r 's/["\`"]/"\""\\"\`""\""/g'`" )
	#foreach filename("`cat "\""${filename_list}"\""`")
		ex -s '+1d' '+wq!' "${filename_list}";
		@ files_processed++;
		if( ${?debug} ) \
			printf "Attempting to filename_process: [${original_filename}] (file: #${files_processed} of ${file_count})\n";
		set callback="filename_process";
		goto callback_handler;
	end
	if( ${files_processed} > 0 ) then
		set callback="scripts_main_quit";
	else
		set callback="usage";
	endif
	goto callback_handler;
#filename_list_process:


filename_process:
	set label_current="filename_process";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	set callback="filename_list_process";
	set extension="`printf "\""${original_filename}"\"" | sed -r 's/^(.*)(\.[^\.]+)"\$"/\2/g'`";
	if( "${extension}" == "${original_filename}" ) \
		set extension="";
	set original_extension="${extension}";
	set filename="`printf "\""${original_filename}"\"" | sed -r 's/^(.*)(\.[^\.]+)"\$"/\1/g'`";
	if(! -e "${filename}${extension}" ) then
		if(! ${?no_exit_on_exception} ) \
			set no_exit_on_exception_set no_exit_on_exception;
		@ errno=-498;
		set callback="filename_list_process";
		goto exception_handler;
	endif
	
	set filename_for_regexp="`printf "\""${original_filename}"\"" | sed -r 's/([\\\*\[\/])/\\\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	set filename_for_editor="`printf "\""${original_filename}"\"" | sed -r 's/(["\"\$\!"\[\(\)\ \<\>])/\\\1/g'`";
	if( ${?edit_all_files} ) \
		${EDITOR} "+0r ${filename_for_editor}";
	printf "\nFile info for:\n\t<file://${filename}${extension}>\n";
	
	if( -d "${filename}${extension}" ) \
		/bin/ls -d -l "${filename}${extension}" | grep -v --perl-regexp '^[\s\ \t\r\n]+$';
	
	/bin/ls -l "${filename}${extension}" | grep -v --perl-regexp '^[\s\ \t\r\n]+$';
	
	set grep_test="`grep "\""^${filename_for_regexp}"\"\$" "\""${filename_list}.all"\""`";
	printf "grep ";
	if( "${grep_test}" != "" ) then
		printf "found:\n\t${grep_test}\n";
	else
		printf "couldn't find:\n\t${filename_for_regexp}.\n";
	endif
	
	goto callback_handler;
#filename_process:


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
	
	if( ${?argument} ) \
		unset argument;
	if( ${?argument_file} ) then
		if( -e "${argument_file}" ) \
			rm -f "${argument_file}";
		unset argument_file;
	endif
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
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
	if( ${?execs} ) \
		unset execs;
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
	
	if( ${?supports_multiple_files} ) \
		unset supports_multiple_files;
	if( ${?scripts_supported_extensions} ) \
		unset scripts_supported_extensions;
	if( ${?supports_hidden_files} ) \
		unset supports_hidden_files;
	
	if( ${?filename_list} ) then
		if( ${?original_filename} ) \
			unset original_filename;
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
	
	if( ${?strict} ) then
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
	endif
	
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
		printf "${usage_message}\n";
	else
		if( "${program}" != "${script}" ) then
			${program} --help;
		else
			printf "${usage_message}\n";
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
		@ errno=-999;
	
	if( $errno > 0 && $errno < -500 ) then
		if( ${?no_exit_on_exception} ) \
			set no_exit_on_exception;
	endif
	
	printf "\n**${scripts_basename} error("\$"errno:$errno):**\n\t";
	switch( $errno )
		case -498:
			printf "**${scripts_basename} error:** filename: ${filename}${extension} can no longer be found" > ${stderr};
			breaksw;
		
		case -499:
			printf "${dashes}${option}${equals}${value} is an unsupported option" > /dev/stderr;
			breaksw;
		
		case -500:
			printf "Debug mode has triggered an exception for diagnosis.  Please see any output above" > /dev/stderr;
			breaksw;
		
		case -501:
			printf "One or more required dependencies couldn't be found.\n\t[${dependency}] couldn't be found.\n\t${scripts_basename} requires: ${dependencies}" > /dev/stderr;
			breaksw;
		
		case -502:
			printf "Sourcing is not supported. ${scripts_basename} may only be executed" > /dev/stderr;
			breaksw;
		
		case -503:
			printf "One or more required options have not been provided" > /dev/stderr;
			breaksw;
		
		case -505:
			printf "handling and/or processing multiple files isn't supported" > /dev/stderr;
			breaksw;
		
		case -601:
			printf "An existing playlist to sort by release date must be specified" > /dev/stderr;
			breaksw;
		
		case -602:
			printf "An existing and supported playlist type must be specified.\n[%s] either doesn't exist or isn't supported.\n%s supports m3u, tox, and pls playlists" "${value}" "${scripts_basename}" > /dev/stderr;
			breaksw;
		
		case -602:
			printf "[%s] isn't a supported playlist type.\n%s supports m3u, tox, and pls playlists" "${value}" "${scripts_basename}" > /dev/stderr;
			breaksw;
		
		case -603:
			printf "[%s] doesn't support converting between the same playlist types.\nJust copy them" "${scripts_basename}" > /dev/stderr;
			breaksw;
		
		case -999:
		default:
			printf "An internal script error has caused an exception: errno: [#%d].  Please see any output above" $errno > /dev/stderr;
			breaksw;
	endsw
	set last_exception_handled=$errno;
	printf ".\n\tPlease see: "\`"${scripts_basename} --help"\`" for more information and supported options.\n" > /dev/stderr;
	if(! ${?debug} ) \
		printf "\tOr run: "\`"${scripts_basename} --debug"\`" to diagnose where ${scripts_basename} failed.\n" > /dev/stderr;
	printf "\n";
	
	if(! ${?callback} ) then
		if(! ${?0} && ${?supports_being_sourced} ) then
			set callback="scripts_sourcing_quit";
		else
			set callback="scripts_main_quit";
		endif
	endif
	
	if( ${?display_usage_on_exception} ) then
		if( ${?display_usage_on_exception_set} ) \
			unset display_usage_on_exception display_usage_on_exception_set;
		goto usage;
	endif
	
	if(! ${?no_exit_on_exception} ) then
		if(! ${?0} && ${?supports_being_sourced} ) then
			set callback="scripts_sourcing_quit";
		else
			set callback="scripts_main_quit";
		endif
	endif
	
	if( ${?no_exit_on_exception_set} ) \
		unset no_exit_on_exception_set no_exit_on_exception;
	
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
		printf "**${scripts_basename} debug:** checking argv.  ${argc} total arguments.\n\n";
#parse_argv:

parse_arg:
	set label_current="parse_arg";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	while( $arg < $argc )
		if(! ${?arg_shifted} ) then
			@ arg++;
		else
			if( ${?value_used} ) then
				@ arg++;
				unset value_used;
			endif
			unset arg_shifted;
		endif
		
		if( ${?debug} ) \
			printf "**%s debug:** Checking argv #%d (%s).\n" "${scripts_basename}" ${arg} "$argv[$arg]";
		
		set argument_file="${scripts_tmpdir}/.escaped.argument.$scripts_basename.argv[$arg].`date '+%s'`.arg";
		printf "$argv[$arg]" >! "${argument_file}";
		ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
		set argument="`cat "\""${argument_file}"\""`";
		rm -f "${argument_file}";
		unset argument_file;
		
		set dashes="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
		if( "${dashes}" == "${argument}" ) \
			set dashes="";
		
		set option="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
		if( "${option}" == "${argument}" ) \
			set option="";
		
		set equals="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
		if( "${equals}" == "${argument}" ) \
			set equals="";
		
		set value="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
		
		if( ${?debug} ) \
			printf "\tparsed "\$"argument: [%s]; "\$"argv[%d] (%s)\n\t"\$"dashes: [%s];\n\t"\$"option: [%s];\n\t"\$"equals: [%s];\n\t"\$"value: [%s]\n\n" "${argument}" "${arg}" "$argv[$arg]" "${dashes}" "${option}" "${equals}" "${value}";
		
		if( "${dashes}" != "" && "${option}" != "" && "${equals}" == "" && "${value}" == "" ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				if( ${?debug} ) \
					printf "**%s debug:** Looking for replacement value.  Checking argv #%d (%s).\n" "${scripts_basename}" ${arg} "$argv[$arg]";
				
				set argument_file="${scripts_tmpdir}/.escaped.argument.$scripts_basename.argv[$arg].`date '+%s'`.arg";
				printf "$argv[$arg]" >! "${argument_file}";
				ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
				set test_argument="`cat "\""${argument_file}"\""`";
				rm -f "${argument_file}";
				unset argument_file;
				
				set test_dashes="`printf "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
				if( "${test_dashes}" == "${test_argument}" ) \
					set test_dashes="";
				
				set test_option="`printf "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
				if( "${test_option}" == "${test_argument}" ) \
					set test_option="";
				
				set test_equals="`printf "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
				if( "${test_equals}" == "${test_argument}" ) \
					set test_equals="";
				
				set test_value="`printf "\""${test_argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
				
				if(!( "${test_dashes}" == "" && "${test_option}" == "" && "${test_equals}" == "" && "${test_value}" == "${test_argument}" )) then
					@ arg--;
				else
					if( ${?debug} ) \
						printf "\tparsed "\$"argument: [%s]; "\$"argv[%d] (%s)\n\t"\$"dashes: [%s];\n\t"\$"option: [%s];\n\t"\$"equals: [%s];\n\t"\$"value: [%s]\n\n" "${test_argument}" "${arg}" "$argv[$arg]" "${test_dashes}" "${test_option}" "${test_equals}" "${test_value}";
					set equals="=";
					set value="${test_value}";
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
			printf "\tparsed option "\$"parsed_argv[${parsed_argc}]: ${parsed_arg}\n\n";
		
		switch("${option}")
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
			
			case "enable":
				switch("${value}")
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], verbose output:\t[${option}d].\n\n";
						set be_verbose;
						breaksw;
					
					default:
						printf "enabling ${value} is not supported.  See "\`"${scripts_basename} --help"\`"\n";
						breaksw;
				endsw
				breaksw;
			
			case "disable":
				switch("${value}")
					case "verbose":
						if(! ${?be_verbose} ) \
							breaksw;
						
						printf "**${scripts_basename} debug:**, via "\$"argv[${arg}], verbose output:\t[${option}d].\n\n";
						unset be_verbose;
						breaksw;
					
					default:
						printf "disabling ${value} is not supported.  See "\`"${scripts_basename} --help"\`"\n";
						breaksw;
				endsw
				breaksw;
			
			default:
				if( -e "${value}" && ${?supports_multiple_files} ) then
					set value_used;
					set callback="filename_list_append";
					goto callback_handler;
				endif
				
				if(! ${?playlist} ) then
					if(! -e "${value}" ) then
						if(! ${?display_usage_on_exception} ) \
							set display_usage_on_exception display_usage_on_exception_set;
						@ errno=-601;
						goto exception_handler;
					endif
					
					set playlist_type="`printf "\""${value}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
					switch("${playlist_type}")
						case "m3u":
						case "pls":
						case "tox":
							set playlist="${value}";
							set value_used;
							breaksw;
						
						default:
							if( ${?no_exit_on_exception} ) \
								unset no_exit_on_exception;
							if(! ${?display_usage_on_exception} ) \
								set display_usage_on_exception;
							unset playlist_type;
							@ errno=-602;
							goto exception_handler;
							breaksw;
					endsw
				endif
				
				if( ${?value_used} ) \
					breaksw;
				
				if(! ${?strict} ) then
					if(! ${?no_exit_on_exception} ) \
						set no_exit_on_exception_set no_exit_on_exception;
				else if( ${?no_exit_on_exception} ) then
					unset no_exit_on_exception;
				endif
				
				@ errno=-504;
				set callback="parse_arg";
				goto exception_handler;
				breaksw;
		endsw
		
		if( ${?arg_shifted} ) then
			unset arg_shifted;
			if(! ${?value_used} ) \
				@ arg--;
		endif
		
		if( ${?value_used} ) \
			unset value_used;
		
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
	
	if(! ${?diagnostic_mode} ) then
		set callback="if_sourced";
	else
		set callback="diagnostic_mode";
	endif
	
	goto callback_handler;
#parse_argv_quit:


filename_list_append:
	set label_current="filename_list_append";
	if( "${label_current}" != "${label_previous}" ) \
		goto label_stack_set;
	
	if(! ${?supports_multiple_files} ) then
		@ errno=-505;
		set callback="parse_arg";
		goto exception_handler;
	endif
	
	if(! ${?filename_list} ) then
		set filename_list="${scripts_tmpdir}/.filenames.${scripts_basename}.@`date '+%s'`";
		touch "${filename_list}";
	endif
	
	if(! ${?scripts_supported_extensions} ) then
		if( ${?debug} || ${?debug_filenames} ) then
			printf "Adding [${value}] to [${filename_list}].\nBy running:\n\tfind -L "\""$value"\""";
			if(! ${?supports_hidden_files} ) \
				printf  \! -iregex '.*\/\..*';
			printf "| sort >> "\""${filename_list}"\""\n\n";
		endif
		if(! ${?supports_hidden_files} ) then
			find -L "$value" \! -iregex '.*\/\..*' | sort >> "${filename_list}";
		else
			find -L "$value" | sort >> "${filename_list}";
		endif
		
		set callback="parse_arg";
		goto callback_handler;
	endif
	
	#if( "${scripts_supported_extensions}" == "mp3|ogg|m4a" && ! ${?ltrim} && ! ${?rtrim} ) \
	#	set scripts_supported_extensions="mp3|m4a";
	
	if( ${?debug}  || ${?debug_filenames} ) then
		if(! -d "$value" ) then
			printf "Adding [${value}] to [${filename_list}] if its a supported file type.\nSupported extensions are:\n\t`printf '${scripts_supported_extensions}' | sed -r 's/\|/,\ /g'`.\n";
		else
			printf "Adding any supported files found under [${value}] to [${filename_list}].\nSupported extensions are:\n\t`printf '${scripts_supported_extensions}' | sed -r 's/\|/,\ /g'`.\n";
		endif
		printf "By running:\n\tfind -L "\""$value"\"" -regextype posix-extended -iregex "\"".*\.(${scripts_supported_extensions})"\"""\$"";
		if(! ${?supports_hidden_files} ) \
			printf " \! -iregex '.*\/\..*'";
		printf " | sort >> "\""${filename_list}"\""\n\n";
	endif
	
	if(! ${?supports_hidden_files} ) then
		find -L "$value" -regextype posix-extended -iregex ".*\.(${scripts_supported_extensions})"\$ \! -iregex '.*\/\..*'  | sort >> "${filename_list}";
	else
		find -L "$value" -regextype posix-extended -iregex ".*\.(${scripts_supported_extensions})"\$ | sort >> "${filename_list}";
	endif
	
	set callback="parse_arg";
	goto callback_handler;
#filename_list_append:


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
	printf "----------------${scripts_basename} debug.log-----------------\n" >> "${scripts_diagnosis_log}";
	printf \$"argv:\n\t${argv}\n\n" >> "${scripts_diagnosis_log}";
	printf \$"parsed_argv:\n\t$parsed_argv\n\n" >> "${scripts_diagnosis_log}";
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
	printf "Create ${scripts_basename} diagnosis log:\n\t${scripts_diagnosis_log}\n";
	@ errno=-500;
	if( ${?callback} ) \
		unset callback;
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
	
	if(! ${?currend_cwd} ) \
		set current_cwd="";
	
	if( "${current_cwd}" != "${cwd}" ) then
		set old_owd="${owd}";
		set current_cwd="${cwd}";
		set argument_file="${scripts_tmpdir}/.escaped.dir.`date '+%s'`.file";
		printf "${cwd}" >! "${argument_file}";
		ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
		set escaped_cwd="`cat "\""${argument_file}"\""`";
		rm -f "${argument_file}";
		unset argument_file;
	endif
	
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
		printf "handling callback to [${last_callback}].\n" > /dev/stdout;
	
	goto $last_callback;
#callback_handler:


