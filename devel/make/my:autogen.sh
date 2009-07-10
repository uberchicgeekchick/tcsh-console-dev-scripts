#!/bin/tcsh -f
set build_script="`basename '${0}' | sed 's/.*my:\(.*\)/\1/g'`";
if( ! -x "./${build_script}" ) then
	printf "I'm unable to find an executable %s script.\n" "${build_script}";
	unset build_script;
	exit -1;
endif

if ( ${?GREP_OPTIONS} ) then
	set prev_grep_options="${GREP_OPTIONS}";
	unsetenv GREP_OPTIONS;
endif


if( `alias grep` != "" ) then
	set prev_grep_alias=`alias grep`;
	unalias grep;
endif


if( `alias egrep` != "" ) then
	set prev_egrep_alias=`alias egrep`;
	unalias egrep;
endif

./{$build_script} ${argv};
unset build_script;


if(${?prev_grep_options}) then
	setenv GREP_OPTIONS "${prev_grep_options}";
	unset prev_grep_options;
endif


if(${?prev_grep_alias}) then
	alias grep "${prev_grep_alias}";
	unset prev_grep_alias;
endif


if(${?prev_egrep_alias}) then
	alias egrep "${prev_egrep_alias}";
	unset prev_egrep_alias;
endif



