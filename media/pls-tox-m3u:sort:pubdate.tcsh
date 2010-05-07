#!/bin/tcsh -f
init:
	if(! ${?0} ) then
		printf "This script cannot be sourced.\n" > /dev/stderr;
		goto usage;
	endif
	set scripts_basename="pls-m3u-tox:sort:pubdate.tcsh":
	alias ex "ex -E -X -n --noplugin";
#init:


playlist_init:
	@ argc=${#argv};
	if( $argc < 1 || $argc > 2 ) \
		goto usage;
	
	if(! -e "$argv[1]" ) then
		printf "An existing playlist to sort by release date must be specified.\n" > /dev/stderr;
		set status=-1;
		goto usage;
	endif
	
	set playlist="$argv[1]";
	set playlist_type="`printf "\""$argv[1]"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
	
	if( $argc > 1 ) then
		if( -e "$argv[2]" ) then
			printf "You've specified that you want to over-write an existing playlist with the newly sorted playlist\nIn order to do this the existing playlist must first be removed.\nAre you sure you want to proceed?\n" > /dev/stderr;
			set rm_confirmation="`rm -vfi "\""$argv[2]"\""`";
			if(!( ${status} == 0 && "${rm_confirmation}" != "" )) then
				printf "Your playlist(s) have been left alone and %s is now exiting.\n" "`basename "\""${0}"\""`";
				goto exit_script;
			endif
		endif
		set new_playlist="$argv[2]";
		set playlist_save_as_type="`printf "\""$argv[2]"\"" | sed -r 's/^(.*)\.([^\.]+)"\$"/\2/'`";
	else
		set new_playlist="${playlist}";
		set playlist_save_as_type="${playlist_type}";
	endif
	cp "${playlist}" "${playlist}.new";
#playlist_init:


playlist_setup:
	switch( "${playlist_type}" )
		case "tox":
			set playlist_type="toxine";
			breaksw;
		
		case "pls":
		case "m3u":
			breaksw;
		
		default:
			printf "**${scripts_basename} error:** [${playlist}] is an unsupported playlist with an an unsupported playlist type: [${playlist_type}].\n\nRun: "\`"${scripts_basename} --help"\`" for more information.\n" > /dev/stderr;
			@ errno=-606;
			goto exit_script;
			breaksw;
		endsw
		
		switch( "${playlist_type}" )
			case "pls":
				ex -s '+1,$s/\v^File[0-9]+\=(.*)$/\1/' '+wq' "${playlist}.new";
				breaksw;
			
			case "tox":
			case "toxine":
				ex -s '+1,$s/\v^[\ \t]+mrl\ \=\ (\/.*);$/\1/' '+wq' "${playlist}.new";
				breaksw;
		endsw
		ex -s '+1,$s/\v^[^\/].*\n//' '+wq' "${playlist}.new";
	endif
#playlist_setup:


playlist_sort:
	cat "${playlist}.new" | \
		sed -r 's/(.*\/)([^\/]*, released on\:? [^,]+, )([0-9]+ )(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)( [^\.]+)(\.[^\.]+)/\3\4\5\ \:\ \1\2\3\4\5\6/' \
		| sed -r 's/([0-9]+ )(Jan) ([0-9]+) ([^\:]+)(\:.*)/\3\-01\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Feb) ([0-9]+) ([^\:]+)(\:.*)/\3\-02\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Mar) ([0-9]+) ([^\:]+)(\:.*)/\3\-03\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Apr) ([0-9]+) ([^\:]+)(\:.*)/\3\-04\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(May) ([0-9]+) ([^\:]+)(\:.*)/\3\-05\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Jun) ([0-9]+) ([^\:]+)(\:.*)/\3\-06\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Jul) ([0-9]+) ([^\:]+)(\:.*)/\3\-07\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Aug) ([0-9]+) ([^\:]+)(\:.*)/\3\-08\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Sep) ([0-9]+) ([^\:]+)(\:.*)/\3\-09\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Oct) ([0-9]+) ([^\:]+)(\:.*)/\3\-10\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Nov) ([0-9]+) ([^\:]+)(\:.*)/\3\-11\-\1\4\5/' \
		| sed -r 's/([0-9]+ )(Dec) ([0-9]+) ([^\:]+)(\:.*)/\3\-12\-\1\4\5/' \
		| sort \
		| sed -r 's/(.*)\ \:\ (.*)/\2/' >! "${playlist}.new";
#playlist_sort:


playlist_save:
	set playlist_new="`echo "\""${playlist}.new"\"" | sed -r 's/([\(\)\ ])/\\\1/g'`";
	switch( "${playlist_save_as_type}" )
		case "tox":
		case "toxine":
			ex -s '+1,$s/\v^(.*)\/([^\/]+)\.([^\.]+)$/entry\ \{\r\tidentifier\ \=\ \2;\r\tmrl\ \=\ \1\/\2\.\3;\r\tav_offset\ \=\ 3600;\r};\r/' '+1,$s/\v^(\tidentifier\ \=\ )(.*), released on.*;$/\1\2;/' '+wq!' "${playlist}.new";
			echo -n "#toxine playlist\n\n" >! "${playlist}.swp";
			ex -s "+2r ${playlist_new}" '+wq!' "${playlist}.swp";
			echo -n "#END" >> "${playlist}.swp";
			breaksw;
		
		case "pls":
			set lines=`wc -l "${playlist}"`;
			@ line=0;
			@ line_number=0;
			while( $line < $lines )
				@ line++;
				@ line_number++;
				ex -s "+${line_number}s/\v^(.*)\/([^\/]+)\.([^\.]+)"\$"/File${line}\=\1\/\2\.\3\rTitle${line}\=\2/" '+wq!' "${playlist}.new";
				@ line_number++;
				ex -s "+${line_number}s/\v^(Title\=.*)(,\ released\ on.*)"\$"/\1/" '+wq!' "${playlist}.new";
			end
			echo -n "[playlist]\nnumberofentries=${lines}\n" >! "${playlist}.swp";
			ex -s "+2r ${playlist_new}" '+wq!' "${playlist}.swp";
			echo -n "\nVersion=2" >> "${playlist}.swp";
			breaksw;
		
		case "m3u":
			ex -s '+1,$s/\v^(.*)\/([^\/]+)\.([^\.]+)$/\#EXTINF:,\2\r\1\/\2\.\3/' '+wq!' "${playlist}.new";
			ex -s '+1,$s/\v^(\#EXTINF\:,.*)(,\ released\ on.*)$/\1/' '+wq!' "${playlist}.new";
			echo -n "#EXTM3U\n" >! "${playlist}.swp";
			ex -s "+1r ${playlist_new}" '+wq' "${playlist}.swp";
			breaksw;
	endsw
	mv -f "${playlist}.swp" "${new_playlist}";
	ex -s '+1,$s/\v^\n//' '+wq' "${new_playlist}";
	
	unset playlist_new;
	
	goto exit_script;
#playlist_save:

exit_script:
	if( ${?playlist} ) then
		if( -e "${playlist}.new" ) \
			rm "${playlist}.new";
		if( -e "${playlist}.swp" ) \
			rm "${playlist}.swp";
	endif
	
	if(! ${?status} ) \
		set status=0;
	exit $status;
#exit_script:


usage:
	printf "%s [path/to/playlist/file.(m3u|tox|pls)] [path/to/new/playlist.(m3u|tox|pls)](optional)\n" "`basename "\""${0}"\""`";
	goto exit_script;
#usage:
