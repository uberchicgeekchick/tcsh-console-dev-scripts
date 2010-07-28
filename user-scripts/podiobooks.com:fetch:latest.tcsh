#!/bin/tcsh -f
setup:
	if(! ${?0} ) \
		exit -1;
	
	cd "`dirname "\""${0}"\""`";
	
	alias feed:podiobook:fetch:latest.tcsh "feed:fetch:all:enclosures.tcsh --disable=logging --start-with=2 --download-limit=1";
	alias feed:fetch:all:enclosures.tcsh "feed:fetch:all:enclosures.tcsh --disable=logging";

	set podiobooks=( \
			# "book_id/title"(e.g.: "509" or "conjuring-raine") (optional: "start-with", e.g.: "2" or "0", "download-limit", e.g.: "2" or "-1")  \
			"506" \ # 2 1 \
	);
	
	@ podiobook_index=0;
#goto setup;

fetch_podiobook:
	onintr exit_script;
	if( ${?fetch_command} ) then
		printf "Cancelled:\n\t%s\n" "${fetch_command}";
		unset limit start_with download_limit podiobook feed fetch_command;
		sleep 2;
	else if( ${?podiobook} ) then
		printf "Cancelled downloading: %s\n" "${podiobook}";
		unset limit start_with download_limit podiobook feed fetch_command;
		sleep 2;
	endif
	while( $podiobook_index < ${#podiobooks} )
		@ podiobook_index++;
		set podiobook=$podiobooks[$podiobook_index];
		goto fetch_enclosures;
	end
	goto exit_script;
#goto fetch_podiobook;

fetch_enclosures:
	onintr fetch_podiobook;
	if(! ${?limit} ) then
		goto get_limit;
	else if(! ${?start_with} ) then
		set start_with=$limit;
		unset limit;
		goto get_limit;
	else if(! ${?download_limit} ) then
		set download_limit=$limit;
		unset limit;
		goto get_limit;
	endif
	if( `printf "%s" "$podiobook" | sed -r 's/^[0-9]+$//'` != "" ) then
		set feed="http://www.podiobooks.com/title/$podiobook/feed/";
	else
		set feed="http://www.podiobooks.com/bookfeed/29127/$podiobook/book.xml";
	endif
	set fetch_command="feed:fetch:all:enclosures.tcsh --disable=logging --download-limit=$download_limit --start-with=$start_with $feed";
	printf "Running: [%s]\n" "${fetch_command}";
	$fetch_command;
	unset limit start_with download_limit podiobook feed fetch_command;
	goto fetch_podiobook;
#goto fetch_enclosures;


get_limit:
	@ podiobook_index++;
	if( $podiobook_index < ${#podiobooks} ) then
		if( `printf "%s" "$podiobooks[$podiobook_index]" | sed -r 's/^[0-9]+$//'` != "" ) then
			@ podiobook_index--;
			if(! $?limit ) then
				if(! ${?start_with} ) then
					@ limit=2;
				else
					@ limit=1;
				endif
			else if( $limit != 1 )
				@ limit=1;
			endif
		else
			if( $podiobooks[$podiobook_index] < 1 ) then
				@ limit=0;
			else if( $podiobooks[$podiobook_index] < 100 ) then
				@ limit=$podiobooks[$podiobook_index];
			else
				@ podiobook_index--;
				if(! ${?start_with} ) then
					@ limit=2;
				else
					@ limit=1;
				endif
			endif
		endif
	else
		#@ podiobook_index--;
		if(! $?limit ) then
			if(! ${?start_with} ) then
				@ limit=2;
			else
				@ limit=1;
			endif
		else if( $limit != 1 )
			@ limit=1;
		endif
	endif
	goto fetch_enclosures;
#goto get_limit;


exit_script:
	if( ${?podiobook} )\
		unset podiobook;
	if( $?limit ) \
		unset limit;
	if( ${?download_limit} )\
		unset download_limit;
	if( ${?start_with} )\
		unset start_with;
	if( ${?feed} )\
		unset feed;
	if( ${?fetch_command} )\
		unset fetch_command;
	exit;
#goto exit_script;
