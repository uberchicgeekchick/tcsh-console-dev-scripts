#!/bin/tcsh -f

init:
	if(! ${?eol} ) then
		set eol='$';
		set eol_set;
	endif
	
	set script_name="alacast:feed:fetch-all:enclosures.tcsh";
	
	if( `printf '%s' "${0}" | sed -r 's/^[^\.]*(csh)$/\1/'` == "csh" ) then
		set status=-1;
		printf "%s does not support being sourced and can only be executed.\n" "${script_name}";
		goto usage;
	endif
	
	set argc=${#argv};
	if( ${argc} < 1 ) then
		set status=-1;
		goto usage;
	endif
	
	set old_owd="${cwd}";
	cd "`dirname '${0}'`";
	set script_path="${cwd}";
	cd "${owd}";
	set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	set owd="${old_owd}";
	unset old_owd;
	
	set script="${script_path}/${script_name}";
	
	alias	ex	"ex -E -n -X --noplugin";
	
	set status=0;
	set logging;
	
	set alacasts_download_log_prefix="alacast:feeds:list:@:";
	set alacasts_download_log_timestamp="`date '+%s'`";
	set alacasts_download_log="./.${alacasts_download_log_prefix}.${alacasts_download_log_timestamp}.log";
	
	goto parse_argv;
#init:

main:
	if(! -e "${alacasts_download_log}" ) then
		set status=-1;
		goto usage;
	endif
	
	if(! ${?save_to_dir} ) then
		if( "`basename '${0}' | sed -r 's/^(alacast).*/\1/ig'`" == "alacast" ) then
			if( -e "${HOME}/.alacast/alacast.ini" ) then
				set alacast_ini="${HOME}/.alacast/alacast.ini";
			else if( -e "${HOME}/.alacast/profiles/${USER}/alacast.ini" ) then
				set alacast_ini="${HOME}/.alacast/profiles/${USER}/alacast.ini";
			else if( -e "`dirname '${0}'`../data/profiles/${USER}/alacast.ini" ) then
				set alacast_ini="`dirname '${0}'`../data/profiles/${USER}/alacast.ini";
			else if( -e "`dirname '${0}'`../data/profiles/default/alacast.ini" ) then
				set alacast_ini="`dirname '${0}'`../data/profiles/default/alacast.ini";
			endif
			if( ${?alacast_ini} ) then
				set save_to_dir="`cat '${alacast_ini}' | /bin/grep --perl-regexp 'save_to_dir.*' | /bin/sed -r 's/.*[^=]*=["\""'\'']([^"\""'\'']*)["\""'\''];/\1/'`";
				unset alacast_ini;
			endif
		endif
	endif

	if( ${?save_to_dir} ) then
		if( "${save_to_dir}" != "${cwd}" ) then
			if(! -d "${save_to_dir}" ) mkdir -p "${save_to_dir}";
			set starting_old_owd="${owd}";
			mv "${alacasts_download_log}" "${save_to_dir}/.${alacasts_download_log_prefix}.${alacasts_download_log_timestamp}.log";
			cd "${save_to_dir}";
		endif
		unset save_to_dir;
	endif
	
	alias	ex	"ex -E -n -X --noplugin";
	
	set download_command="curl --location --fail --show-error --silent";
	alias	curl	"${download_command}";

	set please_wait_phrase="...please be patient, I may need several moments.\t\t";
#main:


fetch_podcasts:
	foreach feed ("`cat '${alacasts_download_log}'`")
		ex -s '+1d' '+wq!' "${alacasts_download_log}";
		if(! ${?silent} ) printf "Downloading podcast's feed.\n\t<%s>\n" "${feed}";
		goto fetch_podcast;
	end
	goto exit_script;
#fetch_podcasts:


fetch_podcast:
	curl --output './00-feed.xml' "${feed}";
	ex '+1,$s/^<!\-\-.*\-\->[\r\n]/' '+wq!' './00-feed.xml' > /dev/null;

	if(! ${?silent} ) printf "Finding feed's title.\n";
	set title="`/usr/bin/grep '<title.*>' './00-feed.xml' | sed 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/gi' | head -1 | sed 's/[\r\n]//g' | sed 's/\//\ \-\ /g' | sed  's/[\ \t]*\&[^;]\+\;[\ \t]*/\ /ig'`";
	
	if( "`printf "\""${title}"\"" | sed -r 's/(The)(.*)/\1/g'`" == "The" ) \
		set title="`printf "\""${title}"\"" | sed -r 's/(The)\ (.*)/\2,\ \1/g' | sed 's/&[^;]\+;/ /'`";
	
	if(! -d "${title}" ) mkdir -p "${title}";
	set old_owd="${owd}";
	cd "${title}";

	set download_log="/dev/null";
	if( ${?logging} ) then
		set download_log="./00-"`basename "${0}"`".log";
		touch "${download_log}";
	endif

	if(! ${?silent} ) printf "Preparing to download: %s\n" "${title}";
	if( ${?logging} ) printf "Preparing to download: %s\n" "${title}" >> ${download_log};
	if(! ${?silent} ) printf "\tURI:\t[%s]\n" "${feed}";
	if( ${?logging} ) printf "\tURI:\t[%s]\n" "${feed}" >> ${download_log};

	if( -e './00-feed.xml' && -e './00-titles.lst' && -e './00-enclosures.lst' && -e './00-pubDates.lst' ) goto continue_download;

	# This to make sure we're working with UNIX file types & don't have to repeat newline replacement.
	cp '../00-feed.xml' "./00-feed.xml";
	rm -f '../00-feed.xml'

	# Grabs the titles of the podcast and all episodes.
	if(! ${?silent} ) printf "Finding title${please_wait_phrase}\t";
	if( ${?logging} ) printf "Finding titles${please_wait_phrase}\t" >> ${download_log};

	# Puts each item, or entry, on its own line:
	ex '+1,$s/[\r\n]\+[\ \t]*//' '+wq!' './00-feed.xml' >& /dev/null;
	ex '+1,$s/[\r\n]\+[\ \t]*//' '+1,$s/<\/\(item\|entry\)>/\<\/\1\>\r/ig' '+$d' '+wq!' './00-feed.xml' >& /dev/null;

	cp './00-feed.xml' './00-titles.lst';

	ex '+1,$s/.*<\(item\|entry\)[^>]*>.*<title[^>]*>\(.*\)<\/title>.*\(enclosure\).*<\/\(item\|entry\)>$/\2/ig' '+1,$s/.*<\(item\|entry\)[^>]*>.*\(enclosure\).*<title[^>]*>\(.*\)<\/title>.*<\/\(item\|entry\)>$/\3/ig' '+1,$s/.*<\(item\|entry\)[^>]*>.*<title[^>]*>\([^<]*\)<\/title>.*<\/\(item\|entry\)>[\n\r]*//ig' '+wq!' './00-titles.lst' >& /dev/null;

	ex '+1,$s/&\(#038\|amp\)\;/\&/ig' '+1,$s/&\(#8243\|#8217\|#8220\|#8221\|\#039\|rsquo\|lsquo\)\;/'\''/ig' '+1,$s/&[^;]\+\;[\ \t]*/\ /ig' '+1,$s/<\!\[CDATA\[\(.*\)\]\]>/\1/g' '+1,$s/#//g' '+1,$s/\//\ \-\ /g' '+wq!' './00-titles.lst' >& /dev/null;
	if(! ${?silent} )printf "[done]\n";
	if( ${?logging} ) printf "[done]\n" >> ${download_log};

	# This will be my last update to any part of Alacast v1
	# This fixes episode & chapter titles so that they will sort correctly
	if(! ${?silent} ) printf "Formating titles${please_wait_phrase}";
	if( ${?logging} ) printf "Formating titles${please_wait_phrase}" >> ${download_log};
	ex '+1,$s/^\(Zero\)/0/gi' '+1,$s/^\(One\)/1/gi' '+1,$s/^\(Two\)/2/gi' '+1,$s/^\(Three\)/3/gi' '+1,$s/^\(Four\)/4/gi' '+1,$s/^\(Five\)/5/gi' '+wq!' './00-titles.lst' >& /dev/null;
	ex '+1,$s/^\(Six\)/6/gi' '+1,$s/^\(Seven\)/7/gi' '+1,$s/^\(Eight\)/8/gi' '+1,$s/^\(Nine\)/9/gi' '+1,$s/^\(Ten\)/10/gi' '+wq!' './00-titles.lst' >& /dev/null;

	ex '+1,$s/^\([0-9]\)ty/\10/gi' '+1,$s/^\(Fifty\)/50/gi' '+1,$s/^\(Thirty\)/30/gi' '+1,$s/^\(Twenty\)/20/gi' '+wq!' './00-titles.lst' >& /dev/null;
	ex '+1,$s/^\([0-9]\)teen/1\1/gi' '+1,$s/^\(Fifteen\)/15/gi' '+1,$s/^\(Thirteen\)/13/gi' '+1,$s/^\(Twelve\)/12/gi' '+1,$s/^\(Eleven\)/11/gi' '+wq!' './00-titles.lst' >& /dev/null;

	ex '+1,$s/\([^a-zA-Z]\)\(Zero\)/\10/gi' '+1,$s/\([^a-zA-Z]\)\(One\)/\11/gi' '+1,$s/\([^a-zA-Z]\)\(Two\)/\12/gi' '+1,$s/\([^a-zA-Z]\)\(Three\)/\13/gi' '+1,$s/\([^a-zA-Z]\)\(Four\)/\14/gi' '+1,$s/\([^a-zA-Z]\)\(Five\)/\15/gi' '+wq!' './00-titles.lst' >& /dev/null;
	ex '+1,$s/\([^a-zA-Z]\)\(Six\)/\16/gi' '+1,$s/\([^a-zA-Z]\)\(Seven\)/\17/gi' '+1,$s/\([^a-zA-Z]\)\(Eight\)/\18/gi' '+1,$s/\([^a-zA-Z]\)\(Nine\)/\19/gi' '+1,$s/\([^a-zA-Z]\)\(Ten\)/\110/gi' '+wq!' './00-titles.lst' >& /dev/null;

	ex '+1,$s/\([^a-zA-Z]\)\([0-9]\)ty[^a-zA-Z]/\1\20/gi' '+1,$s/\([^a-zA-Z]\)\(Fifty\)\([^a-zA-Z]\)/\150\3/gi' '+1,$s/\([^a-zA-Z]\)\(Thirty\)\([^a-zA-Z]\)/\130\3/gi' '+1,$s/\([^a-zA-Z]\)\(Twenty\)\([^a-zA-Z]\)/\120\3/gi' '+wq!' './00-titles.lst' >& /dev/null;
	ex '+1,$s/\([^a-zA-Z]\)\([0-9]\)teen\([^a-zA-Z]\)/\11\2\3/gi' '+1,$s/\([^a-zA-Z]\)\(Fifteen\)\([^a-zA-Z]\)/\115\3/gi' '+1,$s/\([^a-zA-Z]\)\(Thirteen\)\([^a-zA-Z]\)/\113\3/gi' '+1,$s/\([^a-zA-Z]\)\(Twelve\)\([^a-zA-Z]\)/\112\3/gi' '+1,$s/\([^a-zA-Z]\)\(Eleven\)\([^a-zA-Z]\)/\111\3/gi' '+wq!' './00-titles.lst' >& /dev/null;

	ex '+1,$s/\([^a-zA-Z]\)\([0-9]\)ty/\1\20$/gi' '+1,$s/\([^a-zA-Z]\)\(Fifty\)/\150/gi' '+1,$s/\([^a-zA-Z]\)\(Thirty\)/\130/gi' '+1,$s/\([^a-zA-Z]\)\(Twenty\)/\120/gi' '+wq!' './00-titles.lst' >& /dev/null;
	ex '+1,$s/\([^a-zA-Z]\)\([0-9]\)teen/\11\2$/gi' '+1,$s/\([^a-zA-Z]\)\(Fifteen\)/\115/gi' '+1,$s/\([^a-zA-Z]\)\(Thirteen\)/\113/gi' '+1,$s/\([^a-zA-Z]\)\(Twelve\)/\112/gi' '+1,$s/\([^a-zA-Z]\)\(Eleven\)/\111/gi' '+wq!' './00-titles.lst' >& /dev/null;

	ex '+1,$s/^\([0-9]\{1\}\)\([^0-9]\{1\}\)/0\1\2/' '+1,$s/\([^0-9]\{1\}\)\([0-9]\{1\}\)\([^0-9]\{1\}\)/\10\2\3/g' '+1,$s/\([^0-9]\{1\}\)\([0-9]\{1\}\)$/\10\2/' '+wq!' './00-titles.lst' >& /dev/null;

	#start: fixing/renaming roman numerals
	ex '+1,$s/\ I\ /\ 1\ /g' '+1,$s/\ II\ /\ 2\ /g' '+1,$s/\ III\ /\ 3\ /g' '+1,$s/\ IV\ /\ 4\ /g' '+1,$s/\ V\ /\ 5\ /g' '+wq!' './00-titles.lst' >& /dev/null;
	ex '+1,$s/\ VI\ /\ 6\ /g' '+1,$s/\ VII\ /\ 7\ /g' '+1,$s/\ VIII\ /\ 8\ /g' '+1,$s/\ IX\ /\ 9\ /g' '+1,$s/\ X\ /\ 10\ /g' '+wq!' './00-titles.lst' >& /dev/null;
	ex '+1,$s/\ XI\ /\ 11\ /g' '+1,$s/\ XII\ /\ 12\ /g' '+1,$s/\ XIII\ /\ 13\ /g' '+1,$s/\ XIV\ /\ 14\ /g' '+1,$s/\ XV\ /\ 15\ /g' '+wq!' './00-titles.lst' >& /dev/null;
	ex '+1,$s/\ XVI\ /\ 16\ /g' '+1,$s/\ XVII\ /\ 17\ /g' '+1,$s/\ XVIII\ /\ 18\ /g' '+1,$s/\ XIX\ /\ 19\ /g' '+1,$s/\ XX\ /\ 20\ /g' '+wq!' './00-titles.lst' >& /dev/null;

	ex '+1,$s/\//\ \-\ /g' '+1,$s/[\ ]\{2,\}/\ /g' '+wq!' './00-titles.lst' >& /dev/null;
	if(! ${?silent} ) printf "[done]\n";
	if( ${?logging} ) printf "[done]\n" >> ${download_log};


	# Grabs the release dates of the podcast and all episodes.
	if(! ${?silent} ) printf "Finding release dates...please be patient, I may need several moments\t\t";
	if( ${?logging} ) printf "Finding release dates${please_wait_phrase}\t\t" >> ${download_log};
	cp './00-feed.xml' './00-pubDates.lst';

	# Concatinates all data into one single string:
	ex '+1,$s/.*<\(item\|entry\)[^>]*>.*<\(pubDate\|updated\)[^>]*>\(.*\)<\/\(pubDate\|updated\)>.*<.*enclosure[^>]*\(url\|href\)=["'\'']\([^"'\'']\+\)["'\''].*<\/\(item\|entry\)>$/\3/ig' '+1,$s/.*<\(item\|entry\)[^>]*>.*<.*enclosure[^>]*\(url\|href\)=["'\'']\([^"'\'']\+\)["'\''].*<\(pubDate\|updated\)[^>]*>\(.*\)<\/\(pubDate\|updated\)>.*<\/\(item\|entry\)>$/\5/ig' '+1,$s/.*<\(item\|entry\)[^>]*>.*<\(pubDate\|updated\)[^>]*>\([^<]*\)<\/\(pubDate\|updated\)>.*<\/\(item\|entry\)>[\n\r]*//ig' '+wq!' './00-pubDates.lst' >& /dev/null;


	if(! ${?silent} ) printf "[done]\n";
	if( ${?logging} ) printf "[done]\n" >> ${download_log};


	# Grabs the enclosures from the feed.
	# This 1st method only grabs one enclosure per item/entry.
	if(! ${?silent} ) printf "Finding enclosures . . . this may take a few moments\t\t\t\t";
	if( ${?logging} ) printf "Finding enclosures . . . this may take a few moments\t\t\t\t" >> ${download_log};
	cp './00-feed.xml' './00-enclosures-01.lst';

	ex '+1,$s/.*<\(item\|entry\)[^>]*>.*<.*enclosure[^>]*\(url\|href\)=["'\'']\([^"'\'']\+\)["'\''].*<\/\(item\|entry\)>$/\3/ig' '+1,$s/.*<\(item\|entry\)[^>]*>.*<\/\(item\|entry\)>[\n\r]*//ig' '+wq!' '00-enclosures-01.lst' >& /dev/null;
	ex '+1,$s/^[\ \s\r\n]\+//g' '+1,$s/[\ \s\r\n]\+$//g' '+1,$s/?/\\?/g' '+wq!' './00-enclosures-01.lst' >& /dev/null;

	# This second method grabs all enclosures.
	cp './00-feed.xml' './00-enclosures-02.lst';

	# Concatinates all data into one single string:
	ex '+1,$s/[\r\n]\+[\ \t]*//g' '+wq!' './00-enclosures-02.lst' >& /dev/null;

	/usr/bin/grep --perl-regex '.*<.*enclosure[^>]*>.*' './00-enclosures-02.lst' | sed 's/.*url=["'\'']\([^"'\'']\+\)["'\''].*/\1/gi' | sed 's/.*<link[^>]\+href=["'\'']\([^"'\'']\+\)["'\''].*/\1/gi' | sed 's/^\(http:\/\/\).*\(http:\/\/.*$\)/\2/gi' | sed 's/<.*>[\r\n]\+//ig' >! './00-enclosures-02.lst';
	ex '+1,$s/^[\ \s\r\n]\+//g' '+1,$s/[\ \s\r\n]\+$//g' '+1,$s/?/\\?/g' '+wq!' './00-enclosures-02.lst' >& /dev/null;

	set enclosure_count_01=`cat "./00-enclosures-01.lst"`;
	set enclosure_count_02=`cat "./00-enclosures-02.lst"`;
	if( ${#enclosure_count_01} >= ${#enclosure_count_02} ) then
		mv "./00-enclosures-01.lst" "./00-enclosures.lst";
		rm "./00-enclosures-02.lst";
	else
		mv "./00-enclosures-02.lst" "./00-enclosures.lst";
		rm "./00-enclosures-01.lst";
	endif
	if(! ${?silent} ) printf "[done]\n";
	if( ${?logging} ) printf "[done]\n" >> ${download_log};

	if(! ${?silent} ) printf "Beginning to download: %s\n" "${title}";
	if( ${?logging} ) printf "Beginning to download: %s\n" "${title}" >> ${download_log};
	set episodes=();
	if( ${?start_with} ) then
		if( ${start_with} > 1 ) then
			set start_with="`printf '%s-1\n' '${start_with}'`";
			ex "+1,${start_with}d" '+wq!' './00-enclosures.lst' >& /dev/null;
			ex "+1,${start_with}d" '+wq!' './00-titles.lst' >& /dev/null;
			ex "+1,${start_with}d" '+wq!' './00-pubDates.lst' >& /dev/null;
		endif
	endif
	if( ${?download_limit} ) then
		if( ${download_limit} > 0 ) then
			ex "+${download_limit},${eol}d" '+wq!' './00-enclosures.lst' >& /dev/null;
			ex "+${download_limit},${eol}d" '+wq!' './00-titles.lst' >& /dev/null;
			ex "+${download_limit},${eol}d" '+wq!' './00-pubDates.lst' >& /dev/null;
		endif
	endif

	set episodes="`cat './00-enclosures.lst'`";

	goto fetch_episodes;
#fetch_podcast:

continue_download:
	rm  "../00-feed.xml";
	set episodes="`cat './00-enclosures.lst'`";
#continue_download:

fetch_episodes:
	if(! ${?silent} ) printf "\n\tI have found %s episodes of:\n\t\t'%s'\n\n" "${#episodes}" "${title}";
	if( ${?logging} ) printf "\n\tI have found %s episodes of:\n\t\t'%s'\n\n" "${#episodes}" "${title}" >> ${download_log};
	
	@ episodes_downloaded=0;
	@ episodes_number=0;
	if(! ${?eol} ) set eol='$';
	foreach episode ( "`cat './00-enclosures.lst'`" )
		@ episodes_number++;
		if( ${episodes_number} > 1 ) then
			if(! ${?silent} ) printf "\n\n";
			if( ${?logging} ) printf "\n\n" >> ${download_log};
		endif
		
		set episode=`printf '%s' "${episode}" | sed 's/[\r\n]$//'`;
		set episodes_file="`printf '%s' '${episode}' | sed -r 's/.*\/([^\/]+)\\?\?.*${eol}/\1/'`";
		set extension=`printf '%s' "${episodes_file}" | sed 's/.*\.\([^.]*\)$/\1/'`;
		
		set episodes_pubdate="`cat './00-pubDates.lst' | head -${episodes_number} | tail -1 | sed 's/[\r\n]//g' | sed 's/\?//g'`";
		
		set episodes_title="`cat './00-titles.lst' | head -${episodes_number} | tail -1 | sed 's/[\r\n]//g' | sed 's/\?//g'`";
		
		if( "${episodes_title}" == "" ) set episodes_title=`printf '%s' "${episodes_file}" | sed 's/\(.*\)\.[^.]*$/\1/'`;
		
		if( "${episodes_pubdate}" != "" ) then
			set episodes_filename="${episodes_title}, released on: ${episodes_pubdate}.${extension}";
		else
			set episodes_filename="${episodes_title}.${extension}";
		endif
		
		if(! ${?silent} ) printf "\n\n\t\tDownloading episode: %s(episodes_number)\n\t\tTitle: %s (episodes_title)\n\t\tReleased on: %s (episodes_pubDate)\n\t\tFilename: %s (episodes_filename)\n\t\tRemote file: %s (episodes_file)\n\t\tURL: %s (episode)\n" ${episodes_number} "${episodes_title}" "${episodes_pubdate}" "${episodes_filename}" "${episodes_file}" "${episode}";
		if( ${?logging} ) printf "\n\n\t\tDownloading episode: %s(episodes_number)\n\t\tTitle: %s (episodes_title)\n\t\tReleased on: %s (episodes_pubDate)\n\t\tFilename: %s (episodes_filename)\n\t\tRemote file: %s (episodes_file)\n\t\tURL: %s (episode)\n" ${episodes_number} "${episodes_title}" "${episodes_pubdate}" "${episodes_filename}" "${episodes_file}" "${episode}" >> ${download_log};
		
		# Skipping existing files.
		if( ${?fetch_all} ) then
			${download_command} --output "./${episodes_filename}" "${episode}"
		else
			if( -e "./${episodes_filename}" ) then
				if(! ${?silent} ) printf "\t\t\t[skipped existing file]";
				if( ${?logging} ) printf "\t\t\t[skipping existing file]" >> ${download_log};
				continue;
			endif
			
			switch ( "`basename '${episodes_file}'`" )
				case "theend.mp3":
				case "caughtup.mp3":
				case "caught_up_1.mp3":
					if(! ${?silent} ) printf "\t\t\t[skipping podiobook.com notice]";
					if( ${?logging} ) printf "\t\t\t[skipping podiobook.com notice]" >> ${download_log};
					continue;
					breaksw;
			endsw
			
			if( "`printf '%s' "\""${episodes_title}"\"" | sed -r 's/.*(commentary).*/\1/ig'`" != "${episodes_title}" ) then
				if(! ${?silent} ) printf "\t\t\t[skipping commentary track]";
				if( ${?logging} ) printf "\t\t\t[skipping commentary track]" >> ${download_log};
				continue;
			endif
			
			if( ${?regex_match_titles} ) then
				if( "`printf '%s' "\""${episodes_title}"\"" | sed -r s/.*\(${regex_match_titles}\).*/\1/ig'`" )!="${episodes_title}" ) then
					printf "\t\t\t[skipping regexp matched episode]";
					continue;
				endif
			endif
			
			${download_command} --output "./${episodes_filename}" "${episode}"
		endif
		
		if(! -e "./${episodes_filename}" ) then
			if(! ${?silent} ) printf "\t\t\t[*epic fail* :(]";
			if( ${?logging} ) printf "\t\t\t[*pout* :(]" >> ${download_log};
		else
			@ episodes_downloaded++;
			if(! ${?silent} ) printf "\t\t\t[*w00t\!*, FTW\!]";
			if( ${?logging} ) printf "\t\t\t[*w00t\!*, FTW\!]" >> ${download_log};
		endif
	end
	
	if(! ${?debug} ) then
		if( -e './00-titles.lst' ) rm './00-titles.lst';
		if( -e './00-enclosures.lst' ) rm './00-enclosures.lst';
		if( -e './00-pubDates.lst' ) rm './00-pubDates.lst';
		if( -e './00-feed.xml' ) rm './00-feed.xml';
	endif
	
	if(! ${?silent} ) printf "\n\n*w00t\!*, I'm done; enjoy online media at its best!\n";
	if( ${?logging} ) printf "\n\n*w00t\!*, I'm done; enjoy online media at its best!\n" >> ${download_log};
	
	if( ${?old_owd} ) then
		cd "${owd}";
		set owd="${old_owd}";
		unset old_owd;
	endif
	goto fetch_podcasts;
#fetch_episodes:

exit_script:
	if( -e "${alacasts_download_log}" )	\
		rm -v "./.${alacasts_download_log_prefix}"*;
	if( ${?starting_old_owd} ) then
		cd "${owd}";
		set owd="${starting_old_owd}";
		unset starting_old_owd;
	endif
	
	exit ${status};
#exit_script:

usage:
	printf "Usage: %s [ (--start-with)=1..10..? ] [ (--download-limit)=1..10..? ] [ --quiet ] XML_URI\n" `basename ${0}`;
	goto exit_script;
#usage:


parse_argv:
	set argc=${#argv};
	
	if( ${argc} == 0 ) goto usage;
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		if( "$argv[$arg]" != "--debug" ) continue;
		printf "Enabling debug mode; via "\$"argv[%d].\n" $arg;
		set debug;
		break;
	end
	if( ! ${?debug} || $arg > 1 )	\
		@ arg=0;
	
	if( ${?debug} ) printf "Checking %s's argv options.  %d total.\n" "${script_name}" "${argc}";
#parse_argv:

parse_arg:
	while ( $arg < $argc )
		@ arg++;
		
		set equals="";
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?${eol}/\3/'`";
		if( "${value}" == "$argv[$arg]" ) then
			set value="";
		else
			set equals="=";
		endif
		
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?${eol}/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?${eol}/\2/'`";
		if( "${option}" == "$argv[$arg]" ) set option="";
		
		if( ${?debug} )		\
			printf "Checking argv #%d (%s).\nParsed option: %s%s%s%s" "${arg}" "$argv[$arg]" "${dashes}" "${option}" "${equals}" "${value}";
	
		switch ( "${option}" )
			case "h":
			case "help":
				goto usage;
				breaksw;
			
			case "oldest":
			case "last":
			case "stop-with-episode":
			case "stop-with":
			case "stop-at-episode":
			case "stop-at":
			case "download-limit":
				if(!( "${value}" != "" && "${value}" != "${1}" && ${value} > 0 )) then
					printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}";
					breaksw;
				endif
				
				set download_limit="`printf '%s+1\n' '${value}' | bc`";
				breaksw;
			
			case "newest":
			case "first":
			case "start-with-episode":
			case "start-with":
			case "start-at-episode":
			case "start-at":
				if(! ( "${value}" != "" && "${value}" != "${1}" && ${value} > 0 )) then
					printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}";
					breaksw;
				endif
				
				set start_with=${value};
				breaksw;
			
			case "silent":
				set silent;
				breaksw;
				
			case "f":
			case "force":
			case "force-fetch":
			case "force-all":
				set fetch_all;
				breaksw;
			
			case "save-to":
			case "download-to":
			case "download-dir":
			case "download-directory":
				if( "${value}" == "" ) then
					@ arg++;
					if( $arg > $argc ) then
						@ arg--;
					else
						set value="$argv[$arg]";
					endif
				endif
				if(!( "${value}" != "" && -d "${value}" )) then
					printf "%s%s must specify a valid and existing target directory.  See %s -h|--help for more information.\n" "${dashes}" "${option}" "${script_name}";
				else
					set save_to_dir="${value}";
				endif
				breaksw;
			
			case "regex-match-titles":
				if( "${value}" == "" ) breaksw;
				set regex_match_titles="${value}";
				breaksw;
			
			case "logging":
				if(! ${?logging} ) set logging;
				breaksw;
			
			case "debug":
				if(! ${?debug} ) set debug;
				breaksw;
					
			case "enable":
				switch( ${value} )
					case "logging":
						if(! ${?logging} ) set logging;
						breaksw;
					
					case "debug":
						if(! ${?debug} ) set debug;
						breaksw;
					
					default:
						printf "%s cannot be %s.\n" "${value}" "${option}" > /dev/stderr;
						breaksw;
				endsw
				breaksw;
			
			case "disable":
				switch( ${value} )
					case "logging":
						if( ${?logging} ) unset logging;
						breaksw;
					
					case "debug":
						if( ${?debug} ) unset debug;
					breaksw;
					
					default:
						printf "%s cannot be %s.\n" "${value}" "${option}" > /dev/stderr;
					breaksw;
				endsw
				breaksw;
			
			case "xmlUrl":
			default:
				if( "${option}" != "" && "${option}" != "xmlUrl" ) then
					printf "%s%s is an unsupported option.  See %s -h|--help for more information.\n" "${dashes}" "${option}" "${script_name}";
					breaksw;
				endif
				if( "${value}" == "" ) set value="$argv[$arg]";
				if( "`echo '${value}' | sed -r 's/^(http|https|ftp)(:\/\/).*/\2/i'`" != "://" ) then
					if( "${option}" != "" ) then
						printf "%s%s=[url] must specify a valid http, https, or ftp URI.\n" "${dashes}" "${option}" > /dev/stderr;
					else
						printf "A valid http, https, or ftp feeds URI must be specified.\n";
					endif
				else if(! -e "${alacasts_download_log}" ) then
					printf "%s\n" "${value}" >! "${alacasts_download_log}";
				else
					printf "%s\n" "${value}" >> "${alacasts_download_log}";
				endif
				printf "%s\n" "${value}";
				breaksw;
		endsw
		unset dashes option equals value;
	end
	goto main;
#parse_argv:

