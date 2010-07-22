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
	set value_file="`mktemp --tmpdir .escaped.relative.filename.value.XXXXXXXX`";
	printf "%s" "${value}" >! "${value_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
	set escaped_value="`cat "\""${value_file}"\""`";
	rm -f "${value_file}";
	unset value_file;
	set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/)(\/)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\/)(.*)"\$"/\2/'`" == "/./" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/\.\/)/\//' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\.\/)(.*)"\$"/\2/'`" == "/../" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(.*)(\/[^.]{2}[^/]+)(\/\.\.\/)(.*)"\$"/\1\/\4/' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
	unset escaped_value;
	
	goto main;
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

