#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/tcshrc";
set source_file="art:devel:make:init.cshrc.tcsh";


alias	"make:init:artistic:canvas"		"if( ! ${?OSS_CANVAS} ) setenv OSS_CANVAS; source /projects/cli/devel/make/init.tcsh"

alias	"make:init:build:canvas"		"if( ${?OSS_CANVAS} ) unsetenv OSS_CANVAS; source /projects/cli/devel/make/init.tcsh"

set starting_dir=`pwd`;
while( ! ${?canvas_loaded} && "${cwd}" != "/" )
	if( -e "./.custom.canvas" ) then
		if( ! ${?SSH_CONNECTION} ) then
			printf "Setting up custom make environment @ %s.\n" `date "+%I:%M:%S%P"`;
			source "./.custom.canvas";
		else
			source "./.custom.canvas" >& /dev/null ;
		endif
		set canvas_loaded;
	else if( -e "./.build.canvas" || -e "../.build.canvas" ) then
		if( ! ${?SSH_CONNECTION} ) then
			source "/projects/cli/devel/make/build.canvas";
		else
			source "/projects/cli/devel/make/build.canvas" >& /dev/null ;
		endif
		set canvas_loaded;
	else
		cd ..;
	endif
end

if(! ${?canvas_loaded} ) then
	if( ! ${?SSH_CONNECTION} ) then
		source "/projects/cli/devel/make/artistic.canvas";
	else
		source "/projects/cli/devel/make/artistic.canvas" >& /dev/null ;
	endif
endif

#Path to xmkmf, Makefile generator for X Window System
setenv XMKMF "/usr/bin/xmkmf";

cd "${starting_dir}";

unset starting_dir canvas_loaded;

source /projects/cli/tcshrc/argv:clean-up art:devel:make:init.tcsh;
