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

foreach program ( /programs/* )
	if(! -d "${program}" ) \
		continue;
	if( -d "${program}/bin" ) \
		set program="${program}/bin";
	
	if( ${?TCSH_RC_DEBUG} ) \
		printf "Attempting to add: [file://%s] to your PATH:\t\t" "${program}";
	
	if( `${TCSH_RC_SESSION_PATH}/../setenv/PATH:add:test.tcsh "${program}"` != 0 ) then
		if( ${?TCSH_RC_DEBUG} ) \
			printf "[already listed]\n\t<file://%s> is already listed in your "\$"\n" "${program}";
		continue;
	endif
	
	if( ${?TCSH_RC_DEBUG} ) \
		printf "[added]\n";
	if(! ${?programs_path} ) then
		set programs_path="${program}";
	else
		set programs_path="${programs_path}:${program}";
	endif
end
if( ${?programs_path} ) then
	set programs_path="`printf "\""%s"\"" "\""${programs_path}"\"" | sed -r 's/^\://' | sed -r 's/\:\:/\:/g' | sed -r 's/(\/)(\:)/\2/g' | sed -r 's/[\/\:]+"\$"//g'`";
	if(! ${?PATH} ) then
		setenv PATH "${programs_path}";
	else
		setenv PATH "${PATH}:${programs_path}";
	endif
	unset programs_path;
endif
unset program;

if( -d /usr/lib64/jvm/java-openjdk ) then
	setenv JAVA_HOME /usr/lib64/jvm/java-openjdk
else if( -d /usr/lib/jvm/java-openjdk ) then
	setenv JAVA_HOME /usr/lib/jvm/java-openjdk
endif

alias	thunderbird	'/programs/mozilla/Thunderbird3/x86_64/thunderbird-bin -compose %s'


source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "paths:programs.cshrc.tcsh";

