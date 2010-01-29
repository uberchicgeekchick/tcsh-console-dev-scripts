#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
set source_file="art:devel:make:init.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:check" "${source_file}" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

source "${TCSH_RC_SESSION_PATH}/../devel/make/compilers.environment";

alias	"make:init:artistic:canvas"		"if( ! ${?OSS_CANVAS} ) setenv OSS_CANVAS; source ${TCSH_RC_SESSION_PATH}/../devel/make/init.tcsh"

alias	"make:init:build:canvas"		"if( ${?OSS_CANVAS} ) unsetenv OSS_CANVAS; source ${TCSH_RC_SESSION_PATH}/../devel/make/init.tcsh"

set starting_dir="${cwd}";
while( ! ${?canvas_to_load} && "${cwd}" != "/" )
	if( -e "./.custom.canvas" ) then
		if(! ${?SSH_CONNECTION} ) printf "Setting up custom make environment @ %s.\n" `date "+%I:%M:%S%P"`;
		set canvas_to_load="./.custom.canvas";
	else if( -e "./.artistic.canvas" ) then
		set canvas_to_load="${TCSH_RC_SESSION_PATH}/../devel/make/artistic.canvas";
	else if( -e "./.build.canvas" ) then
		set canvas_to_load="${TCSH_RC_SESSION_PATH}/../devel/make/build.canvas";
	else
		cd ..;
	endif
end

if(! ${?canvas_to_load} ) set canvas_to_load="${TCSH_RC_SESSION_PATH}/../devel/make/artistic.canvas";

if( ! ${?SSH_CONNECTION} ) then
	source "${canvas_to_load}";
else
	source "${canvas_to_load}" >& /dev/null;
endif

#Path to xmkmf, Makefile generator for X Window System
setenv XMKMF "/usr/bin/xmkmf";

cd "${starting_dir}";

unset starting_dir canvas_to_load;

if(! ${?source_file} ) set source_file="art:devel:make:init.cshrc.tcsh";
if( "${source_file}" != "art:devel:make:init.cshrc.tcsh" ) set source_file="art:devel:make:init.cshrc.tcsh";
source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "${source_file}";
