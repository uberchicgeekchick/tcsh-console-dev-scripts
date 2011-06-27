#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script cannot be sourced and must be executed.\n" > /dev/stderr;
	exit -1;
endif

set keep_pubDate;
parse_argv:
	while( "${1}" != "" )
		set value="${1}";
		shift;
		
		switch("${value}")
			case "--keep-pubdates":
				if(! ${?keep_pubDate} ) \
					set keep_pubDate;
				breaksw;
			
			case "--drop-pubdates":
				if( ${?keep_pubDate} ) \
					unset keep_pubDate;
				breaksw;
			
			default:
				if( ! ${?target_directory} && -d "${value}" ) then
					set target_directory="${value}";
					goto rename_episodes;
				endif
				
				printf "%s is not a supported option or existing directory.\n" "${value}" > /dev/stderr;
				breaksw;
		endsw
	end
	goto exit_script;
#goto parse_argv;


usage:
	printf "Usage: %s [directory]" "`basename ${0}`";
	@ errno=-502;
	goto parse_argv;
#goto usage;


exit_script:
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit ${errno};
#goto exit_script;


rename_episodes:
	set books_title="`basename "\""${target_directory}"\"" | sed -r 's/^ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g'`";
	
	foreach episode("`/usr/bin/find -L "\""${target_directory}"\"" -regextype posix-extended -iregex '.*\.([^.]+)"\$"' -type f | sort | sed -r 's/^ //' | sed -r 's/(["\""])/"\""\\"\"""\""/g' | sed -r 's/["\$"]/"\""\\"\$""\""/g' | sed -r 's/(['\!'])/\\\1/g'`")
		
		set title="`printf "\""%s"\"" "\""${episode}"\"" | sed -r 's/^(.*)\/(.*)(,\ released\ on\:\ [^.]*)\.([^.]+)"\$"/\1\/\2\.\4/g'`";
		#echo $title;
		
		set books_chapter_or_episode_string="`printf "\""%s"\"" "\""${title}"\"" | sed -r 's/(.*)\/(.*)([CE])?(hapter|pisode)?[^.]*[^.]+\.([^.]+)/\u\3\L\4/ig' | sed -r 's/^0//'`";
		if( "${books_chapter_or_episode_string}" == "" || "${books_chapter_or_episode_string}" == "${title}" ) then
			set books_chapter_or_episode_string="Episode";
			#printf "Cannot rename <%s> it does not appear to be a numbered episode or chapter release.\n" "${episode}" > /dev/stderr;
			#unset books_chapter_or_episode_string;
			#continue;
		endif
		
		set books_path="`printf "\""%s"\"" "\""${episode}"\"" | sed -r 's/^(.*)\/([^/]*)"\$"/\1/g'`";
		
		set pubDate="`printf "\""%s"\"" "\""${episode}"\"" | sed -r 's/^(.*)\/(.*)(, released on: [^.]*)\.([^.]+)"\$"/\3/g'`";
		if( "${pubDate}" == "${episode}" ) \
			set pubDate="";
		
		set episode_title="`printf "\""%s"\"" "\""${episode}"\"" | sed -r 's/(.*)\/(.*)([CE])?(hapter|pisode)?([^,])(, released on: [^.]+)\.([^.]+)/\2/ig'`";
		if( "${episode_title}" == "${episode}" ) \
			set episode_title="";
		
		set books_chapter_number="`printf "\""%s"\"" "\""${title}"\"" | sed -r 's/(.*)\/[^0-9/]*([0-9]+)(.*)"\$"/\2/g' | sed -r 's/^0//'`";
		if( "${books_chapter_number}" == "" || "${books_chapter_number}" == "${title}" ) then
			printf "Cannot rename <%s> it does not appear to be a numbered episode or chapter release.\n" "${episode}" > /dev/stderr;
			unset books_chapter_or_episode_string;
			continue;
		endif
		
		set extension="`printf "\""%s"\"" "\""${title}"\"" | sed -r 's/.*\/[^/]+\.([^.]+)"\$"/\1/g'`";
		
		#echo "${books_path}/<${books_title}> - [${books_chapter_or_episode_string}] [#${books_chapter_number}].${extension}";
		if( $books_chapter_number < 10 && `printf "%s" "${books_chapter_number}" | wc -m` == 1 ) \
			set books_chapter_number="0${books_chapter_number}";
		
		if(! ${?keep_pubDate} ) then
			set new_episode_title="${books_path}/${books_title} - ${books_chapter_or_episode_string} ${books_chapter_number}.${extension}";
		else
			set new_episode_title="${books_path}/${books_title} - ${books_chapter_or_episode_string}${pubDate} ${books_chapter_number}.${extension}";
		endif
		if(!( "${new_episode_title}" == "${episode}" && -e "${new_episode_title}" )) then
			mv -v "${episode}" "${new_episode_title}";
		else
			printf "%s has already been reformated.\n" "`basename "\""${episode}"\""`" > /dev/stderr;
		endif
	end
	unset target_directory;
	goto parse_argv;
#goto rename_episodes;

