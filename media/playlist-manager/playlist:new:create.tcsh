#!/bin/tcsh -f
init:
	if(! ${?0} ) then
		printf "This script cannot be sourced.\n" > /dev/stderr;
		goto usage;
	endif
	
	set scripts_basename="pls-m3u-tox:new:create.tcsh":
	alias ex "ex -E -X -n --noplugin";
#init:


playlist_init:
	@ argc=${#argv};
	if( $argc != 1 ) \
		goto usage;
	
	if(! -e "$argv[1]" ) then
		touch "$argv[1].new";
		goto exit_script;
	endif
	
	set playlist="$argv[1]";
	set playlist_type="`printf "\""$argv[1]"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
	
	cp -f "${playlist}" "${playlist}.new";
#playlist_init:


playlist_setup:
	switch( "${playlist_type}" )
		case "pls":
			ex -s '+1,$s/\v^File[0-9]+\=(.*)$/\1/' '+wq' "${playlist}.new";
			breaksw;
		
		case "tox":
		case "toxine":
			ex -s '+1,$s/\v^[\ \t]+mrl\ \=\ (\/.*);$/\1/' '+wq' "${playlist}.new";
			breaksw;
		
		case "m3u":
			breaksw;
		
		default:
			printf "**${scripts_basename} error:** [${playlist}] is an unsupported playlist with an an unsupported playlist type: [${playlist_type}].\n\nRun: "\`"${scripts_basename} --help"\`" for more information.\n" > /dev/stderr;
			@ errno=-606;
			if( -e "${playlist}.new" ) \
				rm "${playlist}.new";
			goto exit_script;
			breaksw;
	endsw
	ex -s '+1,$s/\v^[^\/].*\n//' '+1,$s/\v^\n//g' '+wq' "${playlist}.new";
#playlist_setup:

exit_script:
	if( ${?playlist} ) \
		unset playlist;
	
	if(! ${?status} ) \
		set status=0;
	exit $status;
#exit_script:


usage:
	printf "%s [path/to/playlist/file.(m3u|tox|pls)]\n\Creates a [.new] playlist containing raw filenames which your script can use.\n\tThe .new playlist can than easily be saved using playlist:new:save.tcsh.\n" "${scripts_basename}";
	goto exit_script;
#usage:
