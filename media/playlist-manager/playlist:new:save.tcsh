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
	
	if(! -e "$argv[$arg].new" ) then
		printf "**%s error:** cannot find: [%s.new].\nSo no new playlist can be saved.\n" "${scripts_basename}" "$argv[$arg].new" > /dev/stderr;
		set status=-1;
		goto usage;
	endif
	
	set playlist="$argv[$arg]";
	set playlist_type="`printf "\""%s"\"" "\""${playlist}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
	
	@ arg++;
	if( $arg <= $argc ) then
		set new_playlist="$argv[$arg]";
		set new_playlist_type="`printf "\""%s"\"" "\""${new_playlist}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
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
				goto scripts_main_quit;
			endif
		endif
	endif
	
	if(! -e "${playlist}.new" ) \
		touch "${playlist}.new";
	set files_new=`wc -l "${playlist}.new" | sed -r 's/^([0-9]+)(.*)$/\1/'`;
	if(! ${files_new} > 0 ) then
		unset files_new;
		rm "${playlist}.new";
		
		if(! -e "${playlist}.swp" ) then
			set files=`wc -l "${playlist}" | sed -r 's/^([0-9]+)(.*)$/\1/'`;
			if(! ${files} > 0 ) then
				rm "${playlist}";
				unset files;
			endif
			goto scripts_main_quit;
		endif
		
		set files=`wc -l "${playlist}.swp" | sed -r 's/^([0-9]+)(.*)$/\1/'`;
		if(! ${files} > 0 ) then
			rm "${playlist}.swp";
			unset files;
			goto scripts_main_quit;
		endif
		unset files;
	endif
	unset files_new;
#playlist_init:


playlist_setup:
	if(! -e "${playlist}.swp" ) \
		goto playlist_save;
	
	set new_playlist_to_read="`printf "\""%s"\"" "\""${playlist}.swp"\"" | sed -r 's/([\(\)\ ])/\\\1/g'`";
	ex -s "+0r ${new_playlist_to_read}" '+wq!' "${playlist}.new";
	rm "${playlist}.swp";
#playlist_setup:


playlist_save:
	mv -f "${playlist}.new" "${playlist}.new.${new_playlist_type}";
	while( "`/bin/grep --perl-regex -c '^"\$"' "\""${playlist}.new.${new_playlist_type}"\""`" != 0 )
		set line_numbers=`/bin/grep --perl-regex --line-number '^$' "${playlist}.new.${new_playlist_type}" | sed -r 's/^([0-9]+).*$/\1/' | grep --perl-regexp '^[0-9]+'`;
		set line_numbers=`printf "%s\n" "${line_numbers}" | sed 's/ /,/g'`;
	 	ex -s "+${line_numbers}d" '+1,$s/\v^\n//g' '+wq!' "${playlist}.new.${new_playlist_type}";
		unset line_numbers;
	end
	set new_playlist_to_read="`printf "\""%s"\"" "\""${playlist}.new.${new_playlist_type}"\"" | sed -r 's/([\(\)\ ])/\\\1/g'`";
	switch( "${new_playlist_type}" )
		case "tox":
			printf "#toxine playlist\n\n" >! "${playlist}.swp.${new_playlist_type}";
			ex -s "+2r ${new_playlist_to_read}" '+wq!' "${playlist}.swp.${new_playlist_type}";
			ex -s '+3,$s/\v^(.*\/)(.*)(\.[^.]+)$/entry\ \{\r\tidentifier\ \=\ \2;\r\tmrl\ \=\ \1\2\3;\r\tav_offset\ \=\ 3600;\r};\r/' '+1,$s/\v^(\tidentifier\ \=\ )(.*), released on.*;$/\1\2;/' '+wq!' "${playlist}.swp.${new_playlist_type}";
			printf "#END" >> "${playlist}.swp.${new_playlist_type}";
			while( "`grep --perl-regexp -c '^(\tidentifier\ \=\ )([^;\=]+)[;\=]([^:\n]*);"\$"' "\""${playlist}.swp.${new_playlist_type}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" != 0 )
				ex -s '+1,$s/\v^(\tidentifier\ \=\ )([^;\=]+)[;\=](.*)$/\1\2\3;/' '+wq!' "${playlist}.swp.${new_playlist_type}";
			end
			breaksw;
		
		case "pls":
			set lines=`wc -l "${playlist}.new.${new_playlist_type}" | sed -r 's/^([0-9]+).*"\$"/\1/'`;
			@ line=0;
			@ line_number=0;
			while( $line < $lines )
				@ line++;
				@ line_number++;
				ex -s "+${line_number}s/\v^(.*\/)(.*)(\.[^.]+)"\$"/File${line}\=\1\2\3\rTitle${line}\=\2/" '+wq!' "${playlist}.new.${new_playlist_type}";
				@ line_number++;
				ex -s "+${line_number}s/\v^(Title\=.*)(,\ released\ on.*)"\$"/\1/" '+wq!' "${playlist}.new.${new_playlist_type}";
			end
			printf "[playlist]\nnumberofentries=${lines}\n" >! "${playlist}.swp.${new_playlist_type}";
			ex -s "+2r ${new_playlist_to_read}" '+wq!' "${playlist}.swp.${new_playlist_type}";
			printf "\nVersion=2" >> "${playlist}.swp.${new_playlist_type}";
			while( "`grep --perl-regexp -c '^(Title\=)([^\=]+)\=([^\=\n]*)"\$"' "\""${playlist}.swp.${new_playlist_type}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" != 0 )
				ex -s '+1,$s/\v^(Title\=)([^\=]+)[\=](.*)$/\1\2\3/' '+wq!' "${playlist}.swp.${new_playlist_type}";
			end
			breaksw;
		
		case "m3u":
			printf "#EXTM3U\n" >! "${playlist}.swp.${new_playlist_type}";
			ex -s "+1r ${new_playlist_to_read}" '+wq!' "${playlist}.swp.${new_playlist_type}";
			ex -s '+2,$s/\v^(.*\/)(.*)(\.[^.]+)$/\#EXTINF:,\2\r\1\2\3/' '+wq!' "${playlist}.swp.${new_playlist_type}";
			ex -s '+2,$s/\v^(#EXTINF:,.*)(,\ released\ on.*)$/\1/' '+wq!' "${playlist}.swp.${new_playlist_type}";
			while( "`grep --perl-regexp -c '^(#EXTINF:,)([^:]+):([^:\n]*)"\$"' "\""${playlist}.swp.${new_playlist_type}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" != 0 )
				ex -s '+1,$s/\v^(#EXTINF:,)([^:]+):(.*)$/\1\2\3/' '+wq!' "${playlist}.swp.${new_playlist_type}";
			end
			breaksw;
	endsw
	rm "${playlist}.new.${new_playlist_type}";
	mv -f "${playlist}.swp.${new_playlist_type}" "${new_playlist}";
	
	unset new_playlist_to_read;
	
	goto scripts_main_quit;
#playlist_save:

scripts_main_quit:
	if( ${?new_playlist} ) \
		unset new_playlist;
	
	if( ${?playlist} ) then
		if( ${?new_playlist_type} ) then
			if( -e "${playlist}.new.${new_playlist_type}" ) \
				rm "${playlist}.new.${new_playlist_type}";
			if( -e "${playlist}.swp.${new_playlist_type}" ) \
				rm "${playlist}.swp.${new_playlist_type}";
			unset new_playlist_type;
		endif
		
		if( -e "${playlist}.new" ) \
			rm "${playlist}.new";
		if( -e "${playlist}.swp" ) \
			rm "${playlist}.swp";
		unset playlist playlist_type;
	endif
	
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
	printf "%s [--force|--interactive(optional)] [path/to/playlist/file.(m3u|tox|pls)] [path/to/new/playlist.(m3u|tox|pls)](optional)\n\tThis script will save a [.new] playlist, usually created by [playlist:new:create.tcsh], and format it correctly.\n\tThe correctly formatted playlist will than over the exitsting playlist or, if the 2nd option is provided, it will format and save over that specified playlist.\n" "${scripts_basename}";
	goto scripts_main_quit;
#usage:
