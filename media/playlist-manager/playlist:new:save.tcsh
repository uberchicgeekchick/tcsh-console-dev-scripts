#!/bin/tcsh -f
init:
	if(! ${?0} ) then
		printf "This script cannot be sourced.\n" > /dev/stderr;
		goto usage;
	endif
	
	onintr scripts_main_quit;
	
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
	
	if( "$argv[$arg]" == "--silent" ) then
		set silent;
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
	
	if( ! ${?force} && "${new_playlist}" != "${playlist}" && -e "${new_playlist}" ) then
		printf "You've specified that you want to over-write an existing playlist with the newly sorted playlist\nIn order to do this the existing playlist must first be removed.\nAre you sure you want to proceed? [y/N]\n" > /dev/stderr;
		set confirmation="$<";
		#set rconfirmation=$<:q;
		printf "\n";
		
		switch(`printf "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
			case "y":
				rm -vf "${new_playlist}";
				breaksw;
			
			case "n":
			default:
				printf "Your playlist(s), [%s] and [%s], will be left alone.\n\t%s is now exiting\n\t[%s.new] will now be deleted.\n" "${playlist}" "${new_playlist}" "${scripts_basename}" "${playlist}" > /dev/stderr;
				goto scripts_main_quit;
				breaksw;
		endsw
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
	unset new_playlist_to_read;
#playlist_setup:


playlist_save:
	if(! ${?silent} ) then
		if( "${new_playlist}" != "${playlist}" ) then
			printf "Saving new playlist: <file://%s>" "${new_playlist}";
		else
			printf "Saving updated playlist: <file://%s>" "${playlist}";
		endif
	endif
	
	set playlist_temp="`mktemp --tmpdir ${scripts_basename}.new.playlist.${new_playlist_type}.XXXXXXXXXX`";
	set playlist_swap="`mktemp --tmpdir ${scripts_basename}.swp.playlist.${new_playlist_type}.XXXXXXXXXX`";
	mv -f "${playlist}.new" "${playlist_temp}";
	while( "`/bin/grep --perl-regex -c '^"\$"' "\""${playlist_temp}"\""`" != 0 )
		set line_numbers=`/bin/grep --perl-regex --line-number '^$' "${playlist_temp}" | sed -r 's/^([0-9]+).*$/\1/' | grep --perl-regexp '^[0-9]+'`;
		set line_numbers=`printf "%s\n" "${line_numbers}" | sed 's/ /,/g'`;
	 	ex -s "+${line_numbers}d" '+1,$s/\v^\n//g' '+wq!' "${playlist_temp}";
		unset line_numbers;
	end
	set new_playlist_to_read="`printf "\""%s"\"" "\""${playlist_temp}"\"" | sed -r 's/([\(\)\ ])/\\\1/g'`";
	switch( "${new_playlist_type}" )
		case "tox":
			printf "#toxine playlist\n\n" >! "${playlist_swap}";
			ex -s "+2r ${new_playlist_to_read}" '+wq!' "${playlist_swap}";
			ex -s '+3,$s/\v^(.*\/)(.*)(\.[^.]+)$/entry\ \{\r\tidentifier\ \=\ \2;\r\tmrl\ \=\ \1\2\3;\r\tav_offset\ \=\ 3600;\r};\r/' '+1,$s/\v^(\tidentifier\ \=\ )(.*), released on.*;$/\1\2;/' '+wq!' "${playlist_swap}";
			printf "#END" >> "${playlist_swap}";
			while( "`grep --perl-regexp -c '^(\tidentifier\ \=\ )(.*)[\=;](.*);"\$"' "\""${playlist_swap}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" != 0 )
				ex -s '+1,$s/\v^(\tidentifier\ \=\ )(.*)[\=;](.*);$/\1\2\3;/' '+wq!' "${playlist_swap}";
			end
			breaksw;
		
		case "pls":
			set lines=`wc -l "${playlist_temp}" | sed -r 's/^([0-9]+).*$/\1/'`;
			@ line=0;
			@ line_number=0;
			while( $line < $lines )
				@ line++;
				@ line_number++;
				ex -s "+${line_number}s/\v^(.*\/)(.*)(\.[^.]+)"\$"/File${line}\=\1\2\3\rTitle${line}\=\2/" '+wq!' "${playlist_temp}";
				@ line_number++;
				ex -s "+${line_number}s/\v^(Title${line}\=.*)(,\ released\ on.*)"\$"/\1/" '+wq!' "${playlist_temp}";
			end
			printf "[playlist]\nnumberofentries=${lines}\n" >! "${playlist_swap}";
			ex -s "+2r ${new_playlist_to_read}" '+wq!' "${playlist_swap}";
			#ex -s '+3,$s/\v^(Title[0-9]+\=.*)(,\ released\ on.*)$/\1/' '+wq!' "${playlist_temp}";
			printf "Version=2" >> "${playlist_swap}";
			unset lines line_number line;
			while( "`grep --perl-regexp -c '^(Title\=)(.*)[\=](.*)"\$"' "\""${playlist_swap}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" != 0 )
				ex -s '+1,$s/\v^(Title\=)(.*)[\=](.*)$/\1\2\3/' '+wq!' "${playlist_swap}";
			end
			breaksw;
		
		case "m3u":
			printf "#EXTM3U\n" >! "${playlist_swap}";
			ex -s "+1r ${new_playlist_to_read}" '+wq!' "${playlist_swap}";
			ex -s '+2,$s/\v^(.*\/)(.*)(\.[^.]+)$/\#EXTINF:,\2\r\1\2\3/' '+wq!' "${playlist_swap}";
			ex -s '+2,$s/\v^(#EXTINF:,.*)(,\ released\ on.*)$/\1/' '+wq!' "${playlist_swap}";
			while( "`grep --perl-regexp -c '^(#EXTINF:,)(.*)[:](.*)"\$"' "\""${playlist_swap}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`" != 0 )
				ex -s '+1,$s/\v^(#EXTINF:,)(.*)[:](.*)$/\1\2\3/' '+wq!' "${playlist_swap}";
			end
			breaksw;
	endsw
	rm "${playlist_temp}";
	mv -f "${playlist_swap}" "${new_playlist}";
	printf "\t[done]\n";
	
	unset new_playlist_to_read playlist_swap playlist_temp;
	
	goto scripts_main_quit;
#playlist_save:

scripts_main_quit:
	if( ${?new_playlist} ) \
		unset new_playlist;
	
	if( ${?new_playlist_type} ) \
		unset new_playlist_type;
	
	if( ${?playlist} ) then
		if( ${?playlist_temp} ) then
			if( -e "${playlist_temp}" ) \
				rm "${playlist_temp}";
			unset playlist_temp;
		endif
		
		if( ${?playlist_swap} ) then
			if( -e "${playlist_swap}" ) \
				rm "${playlist_swap}";
			unset playlist_swap;
		endif
		if( -e "${playlist}.new" ) \
			rm "${playlist}.new";
		if( -e "${playlist}.swp" ) \
			rm "${playlist}.swp";
		
		unset playlist;
		
		if( ${?playlist_type} ) \
			unset playlist_type;
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
