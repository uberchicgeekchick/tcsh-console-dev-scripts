#!/bin/tcsh -f
if(! ${?0} ) \
	exit -1;

cd "`dirname "\""${0}"\""`";

alias feed:fetch:all:enclosures.tcsh "feed:fetch:all:enclosures.tcsh --disable=logging";

set podiobooks=( \
		# "book_id/title"(e.g.: "509" or "conjuring-raine") "limit"(e.g.: "2" or "-1")  \
	);

@ podiobook_index=0;
while( $podiobook_index < ${#podiobooks} )
	@ podiobook_index++;
	set which_podiobook=$podiobooks[$podiobook_index];
	@ podiobook_index++;
	if( $podiobook_index <= ${#podiobooks} ) then
		if( $podiobooks[$podiobook_index] < 0 ) then
			if( ${?limit} ) \
				unset limit;
		else if( $podiobooks[$podiobook_index] < 100 ) then
			@ limit=$podiobooks[$podiobook_index];
		else
			@ podiobook_index--;
			if(! ${?limit} ) then
				@ limit=2;
			else if( ${limit} != 2 )
				@ limit=2;
			endif
		endif
	endif
	if(! ${?limit} ) then
		feed:fetch:all:enclosures.tcsh "http://www.podiobooks.com/title/$which_podiobook/feed/";
	else
		feed:fetch:all:enclosures.tcsh --download-limit=$limit "http://www.podiobooks.com/bookfeed/29127/$which_podiobook/book.xml";
	endif
	unset which_podiobook;
end

