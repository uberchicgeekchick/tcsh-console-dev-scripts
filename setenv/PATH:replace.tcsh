#!/bin/tcsh -f
init:
	set scripts_basename="PATH:replace.tcsh";
	
	@ arg=1;
	@ argc=${#argv};
	
	set restrict;
	
	if( ${?0} ) then
		printf "This script must be sourced to work correctly.\n";
		exit -1;
	endif
	
	if( $argc != 2 && $argc != 3 ) then
		@ errno=-2;
		goto usage;
	endif
	
	if( "$argv[$arg]" == "-r" || "$argv[$arg]" == "--absolute-match" ) then
		@ arg++;
		set restrict=":";
	endif
	
	if(!( $arg < $argc )) then
		@ errno=-3;
		goto usage;
	endif
#goto init;


replace:
	set replace="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/(["\[\(\?\)\+\*\.\\\$\!"])/\\\1/g'`";
	set replacement="`printf "\""%s"\"" "\""$argv[$argc]"\"" | sed -r 's/(["\[\(\?\)\+\*\.\\\$\!"])/\\\1/g'`";
	if( "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*:()/\1/g'`" == "$argv[$arg]" ) then
		setenv NEW_PATH "`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/${restrict}${replace}${restrict}/${restrict}${replacement}${restrict}/g'`";
		goto exit;
	endif
	
	printf "**notice:** <file://%s> is not listed in your current path.\n\tWould you like to add <file://%s> to your "\$"PATH? " "$argv[$arg]" "$argv[$argc]";
	set confirmation="$<";
	printf "\n";
#goto replace;
exit:
	if( ${?errno} ) then
		set status=$errno;
		unset errno;
	endif
	
	unset scripts_basename arg argc restrict;
	exit $status;
#goto exit;


usage:
	printf "Usace: "\`"source %s path_old_dir path_new_dir"\`"\nor: "\`"source %s -r|--absolute-match path_old_dir path_new_dir"\`"\n\n\tRemoves <path_old_dir> from your "\$"PATH and replaces it with <path_new_dir>\n\n\tExample:\n\t\t"\`"source %s "\""/usr/share/local/bin"\"" "\""/usr/local/bin"\""\n\t\treplaces all instances of:  "\""/usr/share/local/bin"\""  with: "\""/usr/local/bin"\""\n\n" "${scripts_basename}" "${scripts_basename}" "${scripts_basename}";
	goto exit;
#goto usage;
