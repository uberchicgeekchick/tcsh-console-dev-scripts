#!/bin/tcsh -f
init:
	onintr exit_script;
	
	set scripts_basename="playlists:convert.tcsh";
	set playlists_paths=( "/media/podcasts/playlists" "/media/library/playlists" );
	set playlist_types=( "m3u" "pls" "tox" );
	set scripts_debug_output="/dev/null";
	
	@ errno=0;
	
	if( "`alias cwdcmd`" != "" ) then
		set original_cwdcmd="`alias cwdcmd`";
		unalias cwdcmd;
	endif
	
	if(! ${?0} ) then
		set being_sourced;
	else
		if( "`basename "\""${0}"\""`" != "${scripts_basename}" ) then
			set being_sourced;
		endif
	endif
	
	if(! ${?being_sourced} ) \
		goto main;
	
	goto sourced;
#goto init;


sourced:
	foreach script("`where "\""${scripts_basename}"\""`")
		if( -x "${script}" ) \
			break;
		unset script;
	end
	
	if(! ${?script} ) then
		@ errno=-11;
		goto scripts_error;
	endif
	
	set old_cwd="${cwd}";
	set old_owd="${owd}";
	cd "`dirname "\""${script}"\""`";
	set scripts_path="${cwd}";
	set script="${scripts_path}/${scripts_basename}";
	cd "${cwd}";
	unset old_cwd;
	set owd="${old_owd}";
	unset old_owd;
	
	if( -e "${scripts_path}/../tcshrc/argv:check" ) then
		source "${scripts_path}/../tcshrc/argv:check" "${scripts_basename}" ${argv};
	endif
	
	if( ${?TCSH_RC_DEBUG} || ${?debug} ) \
		printf "Setting up aliases for playlist conversion.\n" > ${scripts_debug_output};
	
	foreach import_type( ${playlist_types} )
		foreach export_type( ${playlist_types} )
			alias ${import_type}2${export_type} "${script} --import ${import_type} --export ${export_type}";
			unset export_type;
		end
		unset import_type;
	end
	
	goto exit_script;
#goto sourced;


scripts_error:
	set errno_handled;
	
	if(! ${?errno} ) \
		@ errno=0;
	
	if( $errno == 0 ) \
		goto exit_script;
	
	if( $errno < -100 ) \
		goto usage;
	
	switch($errno)
		case -1;
			set error_message="$argv[$arg] must specify a valid playlist type: m3u, pls, or tox";
			breaksw;
		
		case -9:
			set error_message="$argv[$arg] is an unsupported option";
			breaksw;
		
		case -11:
			set error_message="${scripts_basename} could no be found in your path";
			breaksw;
		
		default:
			breaksw
	endsw
	
	if(! ${?error_message} ) then
		goto usage;
	endif
	
	if(! ${?being_sourced} ) then
		set message_prefix="${scripts_basename} error";
	else
		set message_prefix="errno sourcing ${scripts_basename}";
	endif
	
	printf "**%s:** %s (errno: %d)\n" "${message_prefix}" "${error_message}" $errno;
	
	goto exit_script;
#goto scripts_error;


exit_script:
	onintr -;
	if(! ${?errno_handled} ) then
		goto scripts_error;
	endif
	
	if( ${?being_sourced} ) then
		unset being_sourced;
		if( ${?scripts_path} ) then
			if( -e "${scripts_path}/../tcshrc/argv:check" ) then
				source "${scripts_path}/../tcshrc/argv:check" "${scripts_basename}" ${argv};
			endif
			unset scripts_path;
		endif
		if( ${?script} ) \
			unset script;
	endif
	
	unset scripts_basename;
	unset scripts_debug_output;
	unset playlists_paths;
	unset playlist_types;
	
	if( ${?script} ) then
		unset script;
		if( ${?scripts_path} ) \
			unset scripts_path;
	endif
	
	if( ${?old_cwd} ) then
		if( "${cwd}" != "${old_cwd}" ) \
			cd "${old_cwd}";
		unset old_cwd;
	endif
	
	if( ${?old_owd} ) then
		if( "${owd}" != "${old_owd}" ) \
			set owd="${old_owd}";
		unset old_owd;
	endif
	
	if( ${?original_cwdcmd} ) then
		alias cwdcmd "${original_cwdcmd}";
		unset original_cwdcmd;
	endif
	
	if( ${?playlist_type} ) \
		unset playlist_type;
	if( ${?type} ) \
		unset type;
	if( ${?import_type} ) \
		unset import_type;
	if( ${?export_type} ) \
		unset export_type;
	
	if( ${?playlist_to_convert} ) then
		if( -e "${playlist_to_convert}.new" ) then
			rm -f "${playlist_to_convert}.new";
		endif
		if( -e "${playlist_to_convert}.swap" ) then
			rm -f "${playlist_to_convert}.swap";
		endif
		unset playlist_to_convert;
	endif
	
	if( ${?playlist_to_convert_to} ) then
		if( -e "${playlist_to_convert_to}.new" ) then
			rm -f "${playlist_to_convert_to}.new";
		endif
		if( -e "${playlist_to_convert_to}.swap" ) then
			rm -f "${playlist_to_convert_to}.swap";
		endif
		unset playlist_to_convert_to;
	endif
	
	if( ${?argc} ) then
		unset argc;
		if( ${?arg} ) \
			unset arg;
	endif
	
	set status=$errno;
	exit $errno;
#goto exit_script;

usage:
	goto exit_script;
#goto usage;


debug_check:
	@ argc=${#argv};
	@ arg=0;
	
	while( $arg < $argc )
		@ arg++;
		switch("$argv[$arg]")
			case "--debug":
				set scripts_debug_output="/dev/stderr";
				break;
		endsw
	end
	@ arg=0;
	goto parse_argv;
#goto debug_check;


parse_argv:
	if(! ${?argc} ) then
		goto debug_check;
	endif
	
	@ arg=0;
	
	while( $arg < $argc )
		@ arg++;
		
		if( ${?debug} ) \
			printf "Checking option: [%d] of [%d].  "\$"argv[%d]: %s.\n" $arg $argc $arg "$argv[$arg]" > ${scripts_debug_output};
		
		switch("$argv[$arg]")
			case "--debug":
				breaksw;
			
			case "--import":
			case "--export":
				@ arg++;
				if( $arg > $argc ) then
					@ errno=-1;
					goto scripts_error;
				endif
				@ arg--;
				breaksw;
			
			default:
				if( ! ${?import_type} || ! ${?export_type} ) then
					if(! ${?type} ) \
						set type="$argv[$arg]";
					foreach playlist_type( ${playlist_types} )
						if( ${?debug} ) \
							printf "Comparing "\$"{playlist_type}: [%s] against argument "\$"type: [%s]\n" "${playlist_type}" "${type}" > ${scripts_debug_output};
						if( "${playlist_type}" == "${type}" ) \
							break;
						
						unset playlist_type;
					end
					unset type;
					
					if(! ${?playlist_type} ) then
						@ errno=-1;
						goto scripts_error;
					endif
					
					if(! ${?import_type} ) then
						if( ${?debug} ) \
							printf "\n\tPreparing to convert all [%s] playlists" "${playlist_type}" > ${scripts_debug_output};
						set import_type="${playlist_type}";
					else
						printf "into [%s] playlists.\n" "${playlist_type}" > ${scripts_debug_output};
						set export_type="${playlist_type}";
					endif
					unset playlist_type;
					breaksw;
				endif
			
				@ errno=-9;
				goto scripts_error;
				breaksw;
		endsw
	end
	goto main;
#goto parse_argv;


main:
	if(! ${?argc} ) \
		goto parse_argv;
	
	if(!( ${?import_type} && ${?export_type} )) then
		@ errno=-101;
		goto scripts_error;
	endif
	
	@ errno=0;
	foreach playlist_path( ${playlists_paths} )
		printf "Looking for playlists: [%s]\n" "${playlist_path}";
		if( -d "${playlist_path}/${import_type}" ) then
			if( `/bin/ls -A "${playlist_path}/${import_type}/"*.${import_type}` != "" ) then
				foreach playlist_to_convert( "`/bin/ls --width 1 "\""${playlist_path}/${import_type}/"\""*.${import_type}`" )
					set playlist_to_convert_to="`printf "\""%s"\"" "\""${playlist_to_convert}"\"" | sed -r 's/${import_type}/${export_type}/g'`";
					playlist:convert.tcsh --force "${playlist_to_convert}" "${playlist_to_convert_to}";
					unset playlist_to_convert playlist_to_convert_to;
				end
			endif
		endif
		unset playlist_path;
	end
	goto exit_script;
#goto main;


