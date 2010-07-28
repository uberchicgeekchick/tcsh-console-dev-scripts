#!/bin/tcsh -f
setup:
	if(! ${?0} ) then
		printf "This script cannot be sourced.";
		exit -1;
	endif
	
	set scripts_basename="unset:check.tcsh";
	
	if( ${?GREP_OPTIONS} ) then
		set grep_options="${GREP_OPTIONS}";
		unsetenv GREP_OPTIONS;
	endif
	
	if( "`alias grep`" != "" ) then
		set original_grep="`alias grep`";
		unalias grep;
	endif
	
	if( "`alias egrep`" != "" ) then
		set original_egrep="`alias egrep`";
		alias "egrep" "grep -P";
	endif
	
	@ arg=0;
	@ argc=${#argv};
#goto setup;


parse_argv:
	while( $arg < $argc )
		@ arg++;
		switch( "$argv[$arg]" )
			case "--help":
				goto usage;
				breaksw;
			
			case "--debug":
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "--no-debug":
				if( ${?debug} ) \
					unset debug;
				breaksw;
			
			case "--restricted":
			case "--only-missing":
			case "--none-unset-vars-only":
			case "--unset-missing-only":
				if(! ${?show_unset_for_all_vars} ) \
					set show_unset_for_all_vars;
				breaksw;
			
			case "--all":
			case "--all-vars":
			case "--unset-all":
				if(! ${?show_unset_for_all_vars} ) \
					set show_unset_for_all_vars;
				breaksw;
			
			case "--make-label":
			case "--create-label":
			case "--create-script":
				if(! ${?create_unset_label} ) \
					set create_unset_label;
				if(! ${?show_unset_for_all_vars} ) \
					set show_unset_for_all_vars;
				breaksw;
			
			case "edit":
			case "--edit":
				if( ${?create_unset_label} ) \
					set create_unset_label="edit";
				breaksw;
			
			default:
				if(! -e "$argv[$arg]" ) then
					@ errno=-1;
					goto usage;
				else
					set tcsh_script="$argv[$arg]";
					goto check_vars;
				endif
				breaksw;
		endsw
	end
	goto exit_script;
#goto parse_argv;


check_vars:
	set var_list="`mktemp --tmpdir '.escaped.vars.to.unset.XXXXXX'`";
	foreach var("`grep -P '[ \t](set|\@|setenv|foreach)([ \t]+[a-zA-Z][a-zA-Z0-9_]+)[\+\-\=\;\ \(]' "\""${tcsh_script}"\"" | sed -r 's/.*(set|\@|foreach)(env)?[ \t]+([a-zA-Z][a-zA-Z0-9_]+)[-+=; (].*"\$"/\2 \3/'`")
		if( ${?show_unset_for_all_vars} || "`grep -P 'unset.*$var' "\""${tcsh_script}"\""`" == "" ) then
			switch( "${var}" )
				case " errno":
				case " env_unset":
				case " status":
				case " cwd":
				case " owd":
					breaksw;
				
				case " TCSH_CANVAS_PATH":
				case " TCSH_LAUNCHER_PATH":
				case " TCSH_RC_SESSION_PATH":
				case " TCSH_ALTERNATIVES_PATH":
					breaksw;
				
				case " grep_options":
					printf "\n\tif( "\$"{?grep_options} ) then\n\t\tsetenv GREP_OPTIONS "\"\$"{grep_options}"\"";\n\t\tunset grep_options;\n\tendif\n" >> "${var_list}";
					breaksw;
				
				case " original_grep":
					printf "\n\tif( "\$"{?original_grep} ) then\n\t\talias grep "\"\$"{original_grep}"\"";\n\t\tunset original_grep;\n\tendif\n" >> "${var_list}";
					breaksw;
				
				case " original_egrep":
					printf "\n\tif( "\$"{?original_egrep} ) then\n\t\talias egrep "\"\$"{original_egrep}"\"";\n\t\tunset original_egrep;\n\tendif\n" >> "${var_list}";
					breaksw;
				
				default:
					printf "%s\n" "${var}" >> "${var_list}";
					breaksw;
			endsw
		endif
		unset var;
	end
	
	foreach var("`grep -P '^(set|\@|setenv|foreach)([ \t]+[a-zA-Z][a-zA-Z0-9_]+)[\+\-\=\;\ \(]' "\""${tcsh_script}"\"" | sed -r 's/.*(set|\@|foreach)(env)?[ \t]+([a-zA-Z][a-zA-Z0-9_]+)[-+=; (].*"\$"/\2 \3/'`")
		if( ${?show_unset_for_all_vars} || "`grep -P 'unset.*$var' "\""${tcsh_script}"\""`" == "" ) then
			switch( "${var}" )
				case " errno":
				case " env_unset":
				case " status":
				case " cwd":
				case " owd":
					breaksw;
				
				case " TCSH_CANVAS_PATH":
				case " TCSH_LAUNCHER_PATH":
				case " TCSH_RC_SESSION_PATH":
				case " TCSH_ALTERNATIVES_PATH":
					breaksw;
				
				case " grep_options":
					printf "\n\tif( "\$"{?grep_options} ) then\n\t\tsetenv GREP_OPTIONS "\"\$"{grep_options}"\"";\n\t\tunset grep_options;\n\tendif\n" >> "${var_list}";
					breaksw;
				
				case " original_grep":
					printf "\n\tif( "\$"{?original_grep} ) then\n\t\talias grep "\"\$"{original_grep}"\"";\n\t\tunset original_grep;\n\tendif\n" >> "${var_list}";
					breaksw;
				
				case " original_egrep":
					printf "\n\tif( "\$"{?original_egrep} ) then\n\t\talias egrep "\"\$"{original_egrep}"\"";\n\t\tunset original_egrep;\n\tendif\n" >> "${var_list}";
					breaksw;
				
				default:
					printf "%s\n" "${var}" >> "${var_list}";
					breaksw;
			endsw
		endif
		unset var;
	end
	sort "${var_list}" | uniq >! "${var_list}.swp";
	mv -f "${var_list}.swp" "${var_list}";
	ex -s '+1,$s/\v^(env | )?(.*)$/\tif\( \$\{\?\2\} \) \\\r\t\tunset\1\2;' '+wq' "${var_list}";
	if(! ${?create_unset_label} ) then
		cat "${var_list}";
		rm -f "${var_list}";
	else
		printf "env_unset:\n" >! "${var_list}.label";
		cat "${var_list}" >> "${var_list}.label";
		printf "\n\tset env_unset;\n" >> "${var_list}.label";
		if( `egrep '^scripts_main_quit:' "${tcsh_script}"` != "" ) then
			printf "\n\tgoto scripts_main_quit;\n" >> "${var_list}.label";
		else if( `egrep '^exit_script:' "${tcsh_script}"` != "" ) then
			printf "\n\tgoto exit_script;\n" >> "${var_list}.label";
		endif
		printf "#goto env_unset;" >> "${var_list}.label";
		mv -f "${var_list}.label" "${var_list}";
		printf "Need unsets have been saved to: <file://%s>.\n" "${var_list}";
		if( "${create_unset_label}" == "edit" ) then
			vim-enhanced -p "${var_list}";
			rm -fv "${var_list}";
		endif
		unset exit_label;
	endif
	unset tcsh_script;
	goto parse_argv;
#goto check_vars;


exit_script:
	unset scripts_basename;
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $errno;
#goto exit_script;

usage:
	printf "Usage: "\`"%s [script.tcsh]'\n\n\tFinds all variable set within "\`"script.tcsh"\`" and displays any needed unset checks.\n" > ${stdout};
	goto exit_script;
#goto usage;

