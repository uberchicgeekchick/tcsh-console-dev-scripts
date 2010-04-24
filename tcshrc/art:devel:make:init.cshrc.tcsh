#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} )	\
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";

source "${TCSH_RC_SESSION_PATH}/argv:check" "art:devel:make:init.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

if( ${?TCSH_RC_DEBUG} )	\
	printf "Setting up make & gcc environment @ %s.\n" `date "+%I:%M:%S%P"`;

if(! ${?TCSH_CANVAS_PATH} )	\
	setenv TCSH_CANVAS_PATH "${TCSH_RC_SESSION_PATH}/../devel/make";
source "${TCSH_CANVAS_PATH}/canvas.init.tcsh" ${argv};

alias	"make:init:artistic:canvas"		"if( ! ${?OSS_ARTISTIC_CANVAS} ) setenv OSS_ARTISTIC_CANVAS; source "\$"{TCSH_CANVAS_PATH}/init.tcsh"

alias	"make:init:build:canvas"		"if(! ${?OSS_BUILD_CANVAS} ) setenv OSS_BUILD_CANVAS; source "\$"{TCSH_CANVAS_PATH}/init.tcsh"

if( "${1}" != "" && "${1}" != "--reset" ) then
	if( ${?OSS_ARTISTIC_CANVAS} ) then
		set canvas_to_load="${TCSH_CANVAS_PATH}/artistic.canvas";
		goto load_canvas;
	endif
	
	if( ${?OSS_BUILD_CANVAS} ) then
		set canvas_to_load="${TCSH_CANVAS_PATH}/build.canvas";
		goto load_canvas;
	endif
endif

find_canvas:
	while( ! ${?canvas_to_load} && "${cwd}" != "/" )
		if( -e "./.custom.canvas" ) then
			if( ${?TCSH_OUTPUT_ENABLED} ) printf "Setting up custom make environment @ %s.\n" `date "+%I:%M:%S%P"`;
			setenv OSS_CUSTOM_CANVAS;
			set canvas_to_load="./.custom.canvas";
		else if( -e "./.artistic.canvas" ) then
			setenv OSS_ARTISTIC_CANVAS;
			set canvas_to_load="${TCSH_CANVAS_PATH}/artistic.canvas";
		else if( -e "./.build.canvas" ) then
			setenv OSS_BUILD_CANVAS;
			set canvas_to_load="${TCSH_CANVAS_PATH}/build.canvas";
		else
			if(! ${?starting_dir} )	\
				set starting_dir="${cwd}";
			cd ..;
		endif
	end
	
	if( ${?starting_dir} ) then
		if( "${starting_dir}" != "${cwd}" )	\
			cd "${starting_dir}";
		unset starting_dir;
	endif
#find_canvas:

if(! ${?canvas_to_load} ) then
	set canvas_to_load="${TCSH_CANVAS_PATH}/artistic.canvas";
endif

load_canvas:
if( ${?TCSH_OUTPUT_ENABLED} ) then
	source "${canvas_to_load}" ${argv};
else
	source "${canvas_to_load}" ${argv} >& /dev/null;
endif

unset canvas_to_load;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art:devel:make:init.cshrc.tcsh";
