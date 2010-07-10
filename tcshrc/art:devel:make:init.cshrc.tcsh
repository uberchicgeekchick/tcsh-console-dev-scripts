if(! ${?TCSH_RC_SESSION_PATH} ) \
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

if( ${?TCSH_RC_DEBUG} ) \
	printf "Setting up make & gcc environment @ %s.\n" `date "+%I:%M:%S%P"`;

if(! ${?TCSH_CANVAS_PATH} ) \
	setenv TCSH_CANVAS_PATH "${TCSH_RC_SESSION_PATH}/../devel/make";
source "${TCSH_CANVAS_PATH}/canvas.init.tcsh" ${argv};

alias "make:init:artistic:canvas" "if(! ${?OSS_ARTISTIC_CANVAS} ) setenv OSS_ARTISTIC_CANVAS; source "\$"{TCSH_CANVAS_PATH}/init.canvas"

alias "make:init:build:canvas" "if(! ${?OSS_BUILD_CANVAS} ) setenv OSS_BUILD_CANVAS; source "\$"{TCSH_CANVAS_PATH}/init.canvas"

find_canvas:
	while( ! ${?canvas_to_load} && "${cwd}" != "/" )
		if( -e "./.custom.canvas" ) then
			set canvas_to_load="./.custom.canvas";
		else if( -e "./.artistic.canvas" ) then
			set canvas_to_load="${TCSH_CANVAS_PATH}/artistic.canvas";
		else if( -e "./.build.canvas" ) then
			set canvas_to_load="${TCSH_CANVAS_PATH}/build.canvas";
		else
			if(! ${?starting_dir} ) \
				set starting_dir="${cwd}";
			cd ..;
		endif
	end
	
	if( ${?starting_dir} ) then
		if( "${starting_dir}" != "${cwd}" ) \
			cd "${starting_dir}";
		unset starting_dir;
	endif
#find_canvas:

load_canvas:
	if( ${?OSS_CUSTOM_CANVAS} ) \
		unsetenv OSS_CUSTOM_CANVAS;
	
	if( ${?OSS_ARTISTIC_CANVAS} ) \
		unsetenv OSS_ARTISTIC_CANVAS;
	
	if( ${?OSS_BUILD_CANVAS} ) \
		unsetenv OSS_BUILD_CANVAS;
	
	if(! ${?canvas_to_load} ) \
		set canvas_to_load="${TCSH_CANVAS_PATH}/artistic.canvas";
	
	switch("`basename "\""${canvas_to_load}"\""`")
		case ".custom.canvas":
			if( ${?TCSH_OUTPUT_ENABLED} ) \
				printf "Setting up custom make environment @ %s.\n" `date "+%I:%M:%S%P"`;
			setenv OSS_CUSTOM_CANVAS;
			breaksw;
		case "build.canvas":
			setenv OSS_BUILD_CANVAS;
			breaksw;
		
		case "artistic.canvas":
			setenv OSS_ARTISTIC_CANVAS;
			breaksw;
	endsw
	
	if( ${?TCSH_OUTPUT_ENABLED} ) then
		source "${canvas_to_load}" ${argv};
	else
		source "${canvas_to_load}" ${argv} >& /dev/null;
	endif

unset canvas_to_load;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "art:devel:make:init.cshrc.tcsh";
