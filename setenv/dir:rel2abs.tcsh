#!/bin/tcsh -f

init:
	set scripts_basename="dir:rel2abs.tcsh";
	
	if(!( ${?0} && ${#argv} == 1 )) then
		goto usage;
	endif
	set value="$argv[1]";
#goto init;

# turns $value from a relative path, e.g.: ~/Documents/../Photos/./Me.png, to its absolute path, e.g.: /home/user/Photos/Me.png.
rel2abs:
	
	if( `printf "%s" "${value}" | sed -r 's/^(\/).*$/\1/'` != "/" ) \
		set value="${cwd}/${value}";
	set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/(\/)(\/)/\1/g'`";
	while( `printf "%s" "${value}" | sed -r 's/^(.*)(\/\.\/)(.*)$/\2/'` == "/./" )
		set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/(\/\.\/)/\//'`";
	end
	while( `printf "%s" "${value}" | sed -r 's/^(.*)(\/\.\.\/)(.*)$/\2/'` == "/../" )
		set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/(.*)(\/[^/.]{2}.+)(\/\.\.\/)(.*)"\$"/\1\/\4/'`";
	end
	
#goto rel2abs;

main:
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

