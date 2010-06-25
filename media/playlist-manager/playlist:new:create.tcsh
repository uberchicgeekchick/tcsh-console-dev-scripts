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
	@ argc=${#argv};
	if( $argc != 1 ) \
		goto usage;
	
	set playlist="$argv[1]";
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
	
	if( -e "${playlist}.new" ) \
		rm -f "${playlist}.new";
	
	touch "${playlist}.new";
	
	if(! -e "${playlist}" ) then
		touch "${playlist}";
		goto scripts_main_quit;
	endif
#playlist_check:


playlist_setup:
	cp -f "${playlist}" "${playlist}.swp";
	
	switch( "${playlist_type}" )
		case "pls":
			ex -s '+1,$s/\v^File[0-9]+\=(.*)$/\1/' '+wq!' "${playlist}.swp";
			breaksw;
		
		case "tox":
			ex -s '+1,$s/\v^\tmrl\ \=\ (\/.*);$/\1/' '+wq!' "${playlist}.swp";
			breaksw;
		
		case "m3u":
			breaksw;
	endsw
	ex -s '+1,$s/\v^[^/].*\n//' '+1,$s/\v^\n//g' '+wq!' "${playlist}.swp";
	printf "\n" >> "${playlist}.swp";
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
