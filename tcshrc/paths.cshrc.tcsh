#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";
source "${TCSH_RC_SESSION_PATH}/argv:check" "paths.cshrc.tcsh" ${argv};
if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

if( ${?TCSH_RC_DEBUG} ) printf "Setting up PATH environmental variable.\n";

if( ${?PATH} ) unsetenv PATH;

setenv PATH ".:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/etc/init.d";
if( "${cwd}" != "${TCSH_RC_SESSION_PATH}" ) then
	set revert_to_owd="${cwd}";
	if( "`alias cwdcmd`" != "" ) then
		setenv paths_oldcwdcmd "`alias cwdcmd`";
		unalias cwdcmd;
	endif
	cd "${TCSH_RC_SESSION_PATH}";
endif
source "${TCSH_RC_SESSION_PATH}/source:argv" art:alacast.cshrc.tcsh art:paths.cshrc.tcsh paths:lib.cshrc.tcsh paths:lib64.cshrc.tcsh paths:programs.cshrc.tcsh;
setenv PATH "`printf '%s' '${PATH}' | sed -r 's/::/:/g' | sed -r 's/:${eol}//'`";
if( ${?revert_to_owd} ) then
	cd "${revert_to_owd}";
	if( ${?paths_oldcwdcmd} ) then
		alias cwdcmd "${paths_oldcwdcmd}";
		unsetenv paths_oldcwdcmd;
	endif
	unset revert_to_owd;
endif

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "paths.cshrc.tcsh";
