#!/bin/tcsh -f
init:
	if(! ${?0} ) then
		printf "This script cannot be sourced.\n" > /dev/stderr;
		goto usage;
	endif
	
	onintr scripts_main_quit;
	
	set scripts_basename="pls-m3u-tox:new:create.tcsh":
	#set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	alias ex "ex -E -X -n --noplugin";
#init:


playlist_init:
	if( ${#argv} != 1 ) \
		goto usage;
	
	set value="$argv[1]";
	
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
	
	set playlist="${value}";
	set playlist_type="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
#playlist_init:


#playlist_check:
	switch( "${playlist_type}" )
		case "pls":
		case "tox":
		case "m3u":
			breaksw;
		
		default:
			printf "**%s error:** [%s] is an unsupported playlist with an an unsupported playlist type: [%s].\n\nRun: "\`"${scripts_basename} --help"\`" for more information.\n" "${scripts_basename}" "${playlist}" "${playlist_type}" > /dev/stderr;
			@ errno=-606;
			goto scripts_main_quit;
			breaksw;
	endsw
	
	if( -e "${playlist}.swap" ) \
		rm -f "${playlist}.swap";
	
	if( -e "${playlist}.new" ) \
		rm -f "${playlist}.new";
	
	if(! -d "`dirname "\""${playlist}"\""`" ) then
		mkdir -pv "`dirname "\""${playlist}"\""`";
	endif
	
	touch "${playlist}.new";
	
	if(! -e "${playlist}" ) then
		touch "${playlist}" "${playlist}.swap";
		goto scripts_main_quit;
	endif
#playlist_check:


playlist_setup:
	cp -f "${playlist}" "${playlist}.swap";
	
	switch( "${playlist_type}" )
		case "pls":
			ex -s '+1,$s/\v^File[0-9]+\=(.*)$/\1/' '+wq!' "${playlist}.swap";
			breaksw;
		
		case "tox":
			ex -s '+1,$s/\v^\tmrl\ \=\ (\/.*);$/\1/' '+wq!' "${playlist}.swap";
			breaksw;
		
		case "m3u":
			breaksw;
	endsw
	ex -s '+1,$s/\v^[^/].*\n//' '+1,$s/\v^\n//g' '+wq!' "${playlist}.swap";
	printf "\n" >> "${playlist}.swap";
#playlist_setup:

scripts_main_quit:
	if( ${?playlist} ) \
		unset playlist;
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
	if(! ${?status} ) \
		set status=0;
	exit $status;
#scripts_main_quit:


usage:
	printf "%s [path/to/playlist/file.(m3u|tox|pls)]\n\Creates a [.new] playlist containing raw filenames which your script can use.\n\tThe .new playlist can than easily be saved using playlist:new:save.tcsh.\n" "${scripts_basename}";
	goto scripts_main_quit;
#usage:
