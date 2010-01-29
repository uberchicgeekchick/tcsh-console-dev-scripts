#!/bin/tcsh -f
if( "${?}" != "" && "${}" != "" ) then
	printf "Usage: %s [--subscribe(default)|--just-check] [opml_to_use_when_checking_podiobooks(optional)]";
	exit -1;
endif

set podcatcher = "gpodder --add=";
set my_path = "`dirname '${0}' | sed 's/[\r\n]\+//'`";
set podiobooks_opml_date = "`date '+%Y-%m-%d' | sed 's/[\r\n]\+//'`";
set podiobooks_opml = "`printf '%s/../../data/xml/opml/users/%s/podiobooks.com:%s:.opml' '${my_path}' '${USER}' '${podiobooks_opml_date}'`";

switch ( "${1}" )
case "--subscribe":
	set podiobooks_auto_subscribe;
	breaksw;

case "--just-check":
	shift;
	if( ${?podiobooks_auto_subscribe} ) unset podiobooks_auto_subscribe;
	breaksw;

endsw;

if( ${?1} && -e "${1}" ) then
	set podiobooks_opml = "${1}";
else
	wget --quiet -O "${podiobooks_opml}" "http://www.podiobooks.com/opml/subscriptions.php?name=${USER}";
endif

foreach podiobook ( `/usr/bin/grep --perl-regex 'xmlUrl=["'\''][^"'\'']+["'\'']' "${podiobooks_opml}" | /usr/bin/sed 's/.*xmlUrl=["\""'\'']\(http[^"\""'\'']\+\)["\""'\''].*/\1/g'` )
	printf "Checking: %s\n" "${podiobook}";
	wget --quiet -O podiobook.xml "${podiobook}";
	set is_finished = `/usr/bin/grep 'theend.mp3' podiobook.xml`;
	rm -f podiobook.xml;
	if( "${is_finished}" != "" ) then
		printf "\t[finished]\n";
		continue;
	endif
	
	printf "\t[unfinished]\nPlease wait while I subscribe to this podiobook.\n";
	if( ${?podiobooks_auto_subscribe} )
		${podcatcher}${podiobook} >> & /dev/null & ;
		wait;
	endif
end
