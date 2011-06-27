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
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		switch( "$argv[$arg]" )
			case "--force":
			case "--forced":
				set force;
				breaksw;
			
			case "--silent":
				set silent;
				breaksw;
			
			case "--save-empty":
				set save_empty;
				breaksw;
			
			default:
				if( -e "$argv[$arg]" && -e "$argv[$arg].new" ) then
					break;
				endif
				breaksw;
		endsw
	end
	
	if( $arg > $argc ) then
		@ errno=-1;
		@ arg--;
	else if(! -e "$argv[$arg].new" ) then
		@ errno=-1;
	endif
	
	if( ${?errno} ) then
		printf "**%s error:** cannot find: [%s.new].\nSo no new playlist can be saved.\n" "${scripts_basename}" "$argv[$arg]" > /dev/stderr;
		set status=$errno;
		goto usage;
	endif
	
	set value="$argv[$arg]";
	
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
	
	set playlist="${value}";
	set playlist_type="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
	unset escaped_value;
	
	@ arg++;
	if( $arg <= $argc ) then
		set value="$argv[$arg]";
		
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
		
		set playlist_dir_for_ls="`dirname "\""${escaped_value}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
		set playlist_dir="`dirname "\""${escaped_value}"\""`";
		if(! -d "${playlist_dir}" ) \
			mkdir -pv "${playlist_dir}";
		
		set new_playlist="${value}";
		set new_playlist_type="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
		unset escaped_value;
	else
		set new_playlist="${playlist}";
		set new_playlist_type="${playlist_type}";
	endif
	
	if( ! ${?force} && "${new_playlist}" != "${playlist}" && -e "${new_playlist}" ) then
		printf "You've specified that you want to over-write an existing playlist with the newly sorted playlist\nIn order to do this the existing playlist must first be removed.\nAre you sure you want to proceed? [y/N]\n" > /dev/stderr;
		set confirmation="$<";
		#set rconfirmation=$<:q;
		printf "\n";
		
		switch(`printf "%s" "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
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
	if(! ${?save_empty} ) then
		set files_new=`wc -l "${playlist}.new" | sed -r 's/^([0-9]+)(.*)$/\1/'`;
		if(!( ${files_new} > 0 )) then
			unset files_new;
			rm -f "${playlist}.new";
			if( -e "${playlist}.swap" ) \
				rm -f "${playlist}.swap";
			goto scripts_main_quit;
		endif
	endif
	unset files_new;
	
	goto playlist_setup;
#playlist_init:


playlist_setup:
	if(! -e "${playlist}.swap" ) \
		goto playlist_save;
	
	set new_playlist_to_read="`printf "\""%s"\"" "\""${playlist}.swap"\"" | sed -r 's/([\(\)\ ])/\\\1/g'`";
	ex -s "+0r ${new_playlist_to_read}" '+wq!' "${playlist}.new";
	rm -f "${playlist}.swap";
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
	
	set playlist_temp="`mktemp --tmpdir .${scripts_basename}.new.playlist.${new_playlist_type}.XXXXXXXXXX`";
	set playlist_swap="`mktemp --tmpdir .${scripts_basename}.swap.playlist.${new_playlist_type}.XXXXXXXXXX`";
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
			printf "# toxine playlist\n\n" >! "${playlist_swap}";
			ex -s "+2r ${new_playlist_to_read}" '+wq!' "${playlist_swap}";
			ex -s '+3,$s/\v^(.*\/)(.*)(\.[^.]+)$/entry\ \{\r\tidentifier\ \=\ \2;\r\tmrl\ \=\ \1\2\3;\r\tav_offset\ \=\ 3600;\r};\r/' '+1,$s/\v^(\tidentifier\ \=\ )(.*), released on.*;$/\1\2;/' '+wq!' "${playlist_swap}";
			printf "# END\n" >> "${playlist_swap}";
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
			printf "[playlist]\nnumberofentries=%s\n" "${lines}" >! "${playlist_swap}";
			ex -s "+2r ${new_playlist_to_read}" '+wq!' "${playlist_swap}";
			#ex -s '+3,$s/\v^(Title[0-9]+\=.*)(,\ released\ on.*)$/\1/' '+wq!' "${playlist_temp}";
			printf "Version=2\n" >> "${playlist_swap}";
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
	if(! ${?silent} ) \
		printf "\t\t[finished]\n";
	
	unset new_playlist_to_read playlist_swap playlist_temp;
	
	goto scripts_main_quit;
#playlist_save:


scripts_main_quit:
	onintr -;
	if( ${?playlist_dir_for_ls} ) then
		while( "${playlist_dir}" != "/" && "`mount | grep "\""^${playlist_dir_for_ls} "\""`" == "" )
			if( "`/bin/ls -A "\""${playlist_dir_for_ls}"\""`" != "" ) \
				break;
			
			set rm_notification="`rm -rv "\""${playlist_dir_for_ls}"\""`";
			if(! ${?removal_silent} ) \
				printf "\t%s\n" "${rm_notification}"
			unset rm_notification;
			if( ${?create_script} ) then
				printf "rm -rv "\""%s"\"";\n" "${playlist_dir}" >> "${create_script}";
			endif
			
			set playlist_cwd="`printf "\""%s"\"" "\""${playlist_dir_for_ls}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
			set playlist_dir="`dirname "\""${playlist_cwd}"\""`";
			set playlist_dir_for_ls="`dirname "\""${playlist_cwd}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
		end
	endif
	if( ${?new_playlist} ) \
		unset new_playlist;
	
	if( ${?new_playlist_type} ) \
		unset new_playlist_type;
	
	if( ${?save_empty} ) \
		unset save_empty;
	
	if( ${?playlist} ) then
		if( ${?playlist_temp} ) then
			if( -e "${playlist_temp}" ) \
				rm -f "${playlist_temp}";
			unset playlist_temp;
		endif
		
		if( ${?playlist_swap} ) then
			if( -e "${playlist_swap}" ) \
				rm -f "${playlist_swap}";
			unset playlist_swap;
		endif
		
		if( -e "${playlist}.new" ) \
			rm -f "${playlist}.new";
		if( -e "${playlist}.swap" ) \
			rm -f "${playlist}.swap";
		
		if( ${?playlist_type} ) \
			unset playlist_type;
		
		unset playlist;
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
