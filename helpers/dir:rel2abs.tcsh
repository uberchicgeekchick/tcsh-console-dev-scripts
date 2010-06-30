#!/bin/tcsh -f

init:
	set scripts_basename="dir:rel2abs.tcsh";
	
	if(!( ${?0} && ${#argv} == 1 )) then
		goto usage;
	endif
#goto init;

main:
	set value="$argv[1]";
	if( `printf "%s" "${value}" | sed -r 's/^(\/).*$/\1/'` != "/" ) then
		set value="${cwd}/${value}";
		while( `printf "%s" "${value}" | sed -r 's/^(.*)(\/\.\/)(.*)$/\2/'` == "/./" )
			set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/(.*)(\/\.\/)(.*)"\$"/\1\/\3/'`";
		end
		while( `printf "%s" "${value}" | sed -r 's/^(.*)(\/\.\.\/)(.*)$/\2/'` == "/../" )
			set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/(.*)(\/\.\.\/)([^/]+\/)(.*)"\$"/\1\/\4/'`";
		end
	endif
	printf "%s\n" "${value}";
#goto main;


exit_script:
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $errno;
#goto exit_script;


usage:
	printf "Usage: %s ./directory\n\tor: %s ../../directory\n\tor: %s /directory/subdirectory/.././subdirectory" "${scripts_basename}" "${scripts_basename}" "${scripts_basename}";
	goto exit_script;
#goto usage;

