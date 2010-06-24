#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";

source "${TCSH_RC_SESSION_PATH}/argv:check" "paths:programs.cshrc.tcsh" ${argv};

if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

init:
	set program_params=( "/programs" "bin" "/programs/mozilla" "${MACHTYPE}" );
	@ program_index=0;
	goto main;
#init:

main:
	while( $program_index < ${#program_params} )
		@ program_index++;
		if(! ${?check_for_paths_in} ) \
			set check_for_paths_in="";
		
		if( "${check_for_paths_in}" != "$program_params[$program_index]" ) \
			set check_for_paths_in="$program_params[$program_index]";
		
		@ program_index++;
		set check_for_subdir="$program_params[$program_index]";
		
		if( ${?TCSH_RC_DEBUG} ) then
			if( $program_index > 2 ) \
				printf "\n\n";
			printf "Searching: <file://%s> for directories to your PATH:\n\n" "${check_for_paths_in}";
		endif
		
		goto add_program;
	end
#main:

exit_script:
	unset program_params program_index;
	unset check_for_paths_in check_for_subdir;
	if( ${?programs_path} ) then
		set programs_path="`printf "\""%s"\"" "\""${programs_path}"\"" | sed -r 's/^\://' | sed -r 's/\:\:/\:/g' | sed -r 's/(\/)(\:)/\2/g' | sed -r 's/[\/\:]+"\$"//g'`";
		if(! ${?PATH} ) then
			setenv PATH "${programs_path}";
		else
			setenv PATH "${PATH}:${programs_path}";
		endif
		unset programs_path;
	endif
	
	if( -d /usr/lib64/jvm/java-openjdk ) then
		setenv JAVA_HOME /usr/lib64/jvm/java-openjdk
	else if( -d /usr/lib/jvm/java-openjdk ) then
		setenv JAVA_HOME /usr/lib/jvm/java-openjdk
	endif
	
	alias thunderbird '/programs/mozilla/Thunderbird3/x86_64/thunderbird-bin -compose %s'
	
	
	source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "paths:programs.cshrc.tcsh";
	exit 0;
#exit_script



add_program:
	if(! ${?check_for_paths_in} ) \
		set check_for_paths_in="/programs";
	
	if( "`printf "\""%s"\"" "\""${check_for_paths_in}"\"" | sed -r 's/^(.)(.*)"\$"/\1/'`" != "/" ) \
		set check_for_paths_in="/${check_for_paths_in}";
	if( "`printf "\""%s"\"" "\""${check_for_paths_in}"\"" | sed -r 's/^(.*)(\/)"\$"/\2/'`" == "/" ) \
		set check_for_paths_in="`printf "\""%s"\"" "\""${check_for_paths_in}"\"" | sed -r 's/^(.*)(\/)"\$"/\1/'`";
	
	if(! -d "${check_for_paths_in}" ) then
		if( ${?check_for_subdir} ) \
			unset check_for_subdir;
		unset check_for_paths_in;
		goto main;
	endif
	
	if(! ${?check_for_subdir} ) \
		set check_for_subdir="bin";
	
	foreach program( ${check_for_paths_in}/* )
		if(! -d "${program}" ) then
			unset program;
			continue;
		endif
		
		switch("`basename "\""${program}"\""`" )
			case "src":
			case "mozilla":
			case "lost+found":
			case "tmp":
			case "ISOs":
			case "rpms":
			case "tarballs":
			case "icons":
			case "settings":
			case "extensions":
				unset program;
				continue;
		endsw
		
		if( -d "${program}/${check_for_subdir}" ) \
			set program="${program}/${check_for_subdir}";
		
		if( ${?TCSH_RC_DEBUG} ) \
			printf "Attempting to add: [file://%s] to your PATH:\t\t" "${program}";
		
		if( `${TCSH_RC_SESSION_PATH}/../setenv/PATH:add:test.tcsh "${program}"` != 0 ) then
			if( ${?TCSH_RC_DEBUG} ) \
				printf "[already in "\$"PATH]\n";
			unset program;
			continue;
		endif
		
		if( ${?TCSH_RC_DEBUG} ) \
			printf "[added]\n";
		if(! ${?programs_path} ) then
			set programs_path="${program}";
		else
			set programs_path="${programs_path}:${program}";
		endif
		unset program;
	end
	goto main;
#add_program:
