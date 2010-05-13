#!/bin/tcsh -f
init:
	if(! ${?0} ) then
		printf "This script cannot be sourced.\n" > /dev/stderr;
		goto usage;
	endif
	
	set scripts_basename="playlist:new:save.tcsh":
	#set scripts_tmpdir="`mktemp --tmpdir -d tmpdir.for.${scripts_basename}.XXXXXXXXXX`";
	alias ex "ex -E -X -n --noplugin";
#init:


playlist_init:
	@ argc=${#argv};
	if( $argc < 1 || $argc > 4 ) \
		goto usage;
	
	@ arg=1;
	if( "$argv[$arg]" == "--force" ) then
		set force;
		@ arg++;
	endif
	
	if( "$argv[$arg]" != "--interactive" ) then
		set interactive;
	else
		set interactive="i";
		@ arg++;
	endif
	
	if(! -e "$argv[$arg].new" ) then
		printf "**%s error:** cannot find: [%s.new].\nSo no new playlist can be saved.\n" > /dev/stderr;
		set status=-1;
		goto usage;
	endif
	
	set playlist="$argv[$arg]";
	set playlist_type="`printf "\""$argv[$arg]"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
	@ arg++;
	
	if( $arg <= $argc ) then
		set new_playlist="$argv[$arg]";
		set new_playlist_type="`printf "\""$argv[$arg]"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
	else
		set new_playlist="${playlist}";
		set new_playlist_type="${playlist_type}";
	endif
	
	if( "${new_playlist}" != "${playlist}" && -e "${new_playlist}" ) then
		if(! ${?force} ) then
			printf "You've specified that you want to over-write an existing playlist with the newly sorted playlist\nIn order to do this the existing playlist must first be removed.\nAre you sure you want to proceed?\n" > /dev/stderr;
			set rm_confirmation="`rm -vfi "\""${new_playlist}"\""`";
			if(!( ${status} == 0 && "${rm_confirmation}" != "" )) then
				printf "Your playlist(s), [%s] and [%s], will be left alone.\n\t%s is now exiting\n\t[%s.new] will now be deleted.\n" "${playlist}" "${new_playlist}" "${scripts_basename}" "${playlist}" > /dev/stderr;
				goto exit_script;
			endif
		endif
	endif
#playlist_init:


playlist_save:
	if( "${playlist}.new" != "${new_playlist}.new" ) \
		mv -f "${playlist}.new" "${new_playlist}.new";
	while( "`/bin/grep --perl-regex -c '^"\$"' "\""${new_playlist}.new"\""`" != 0 )
		set line_numbers=`/bin/grep --perl-regex --line-number '^$' "${new_playlist}.new" | sed -r 's/^([0-9]+).*$/\1/' | grep --perl-regexp '^[0-9]+'`;
		set line_numbers=`printf "%s\n" "${line_numbers}" | sed 's/ /,/g'`;
	 	ex -s "+${line_numbers}d" '+1,$s/\v^\n//g' '+wq!' "${new_playlist}.new";
		unset line_numbers;
	end
	set new_playlist_to_read="`printf "\""%s"\"" "\""${new_playlist}.new"\"" | sed -r 's/([\(\)\ ])/\\\1/g'`";
	switch( "${new_playlist_type}" )
		case "tox":
		case "toxine":
			printf "#toxine playlist\n\n" >! "${new_playlist}.swp";
			ex -s "+2r ${new_playlist_to_read}" '+wq!' "${new_playlist}.swp";
			ex -s '+3,$s/\v^(.*\/)(.*)(\.[^.]+)$/entry\ \{\r\tidentifier\ \=\ \2;\r\tmrl\ \=\ \1\2\3;\r\tav_offset\ \=\ 3600;\r};\r/' '+1,$s/\v^(\tidentifier\ \=\ )(.*), released on.*;$/\1\2;/' '+1,$s/\v^(\tidentifier\ \=\ )([^:]*):?.*;$/\1\2;/' '+wq!' "${new_playlist}.swp";
			printf "#END" >> "${new_playlist}.swp";
			breaksw;
		
		case "pls":
			set lines="`wc -l "\""${new_playlist}.new"\"" | sed -r 's/^[\ \t]*//' | sed -r 's/[\ \t]*"\$"//'`";
			@ line=0;
			@ line_number=0;
			while( $line < $lines )
				@ line++;
				@ line_number++;
				ex -s "+${line_number}s/\v^(.*\/)(.*)(\.[^.]+)"\$"/File${line}\=\1\2\3\rTitle${line}\=\2/" '+wq!' "${new_playlist}.new";
				@ line_number++;
				ex -s "+${line_number}s/\v^(Title\=.*)(,\ released\ on.*)"\$"/\1/" "+${line_number}s/\v^(Title\=)([^:]*):?.*"\$"/\1\2/" '+wq!' "${new_playlist}.new";
			end
			printf "[playlist]\nnumberofentries=${lines}\n" >! "${new_playlist}.swp";
			ex -s "+2r ${new_playlist_to_read}" '+wq!' "${new_playlist}.swp";
			printf "\nVersion=2" >> "${new_playlist}.swp";
			breaksw;
		
		case "m3u":
			printf "#EXTM3U\n" >! "${new_playlist}.swp";
			ex -s "+1r ${new_playlist_to_read}" '+wq!' "${new_playlist}.swp";
			ex -s '+2,$s/\v^(.*\/)(.*)(\.[^.]+)$/\#EXTINF:,\2\r\1\2\3/' '+wq!' "${new_playlist}.swp";
			ex -s '+2,$s/\v^(#EXTINF:,.*)(,\ released\ on.*)$/\1/' '+wq!' "${new_playlist}.swp";
			foreach line_number( "`grep --perl-regexp --line-number '^(#EXTINF:,)([^:]+):([^:]*)"\$"' "\""${new_playlist}.swp"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" )
				ex -s "+${line_number}s/://g" "+${line_number}s/\v^(#EXTINF,)(.*)"\$"/\1:\2/g" '+wq!' "${new_playlist}.swp";
				unset line_number;
			end
			breaksw;
	endsw
	rm "${new_playlist}.new";
	mv -f${interactive} "${new_playlist}.swp" "${new_playlist}";
	
	unset new_playlist_to_read;
	
	goto exit_script;
#playlist_save:

exit_script:
	if( ${?scripts_tmpdir} ) then
		if( -d "${scripts_tmpdir}" ) \
			rm -rf "${scripts_tmpdir}";
		unset scripts_tmpdir;
	endif
	
	if( ${?playlist} ) then
		if( -e "${playlist}.new" ) \
			rm "${playlist}.new";
		if( -e "${playlist}.swp" ) \
			rm "${playlist}.swp";
		unset playlist;
	endif
	
	if(! ${?status} ) \
		set status=0;
	exit $status;
#exit_script:


usage:
	printf "%s [--force|--interactive(optional)] [path/to/playlist/file.(m3u|tox|pls)] [path/to/new/playlist.(m3u|tox|pls)](optional)\n\tThis script will save a [.new] playlist, usually created by [playlist:new:create.tcsh], and format it correctly.\n\tThe correctly formatted playlist will than over the exitsting playlist or, if the 2nd option is provided, it will format and save over that specified playlist.\n" "${scripts_basename}";
	goto exit_script;
#usage:
