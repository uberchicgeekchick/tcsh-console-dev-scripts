#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" && "${1}" != "--help")) then
	goto usage
endif
unsetenv GREP_OPTIONS;

while( ${?1} && "${1}" != "" )
next_option:
	set action="`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`";
	set opml="`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`";
	shift;
	switch ( "${action}" )
	case 'delete':
	case 'unsubscribe':
		set message="Delet";
		set action="del";
		breaksw
	case 'add':
	case 'subscribe':
		set message="Add";
		set action="add";
		breaksw
	default:
		printf "%s is not supported\t\t[skipped]\n", `echo ${action} | sed 's/[e]\?$$/ing/`;
		goto usage
	endsw

	foreach podcast ( "`/usr/bin/grep --perl-regexp '^[\t\ \s]+<outline.*xmlUrl=["\""'\''][^"\""'\'']+["\""]' '${opml}' | sed 's/^[\ \s\t]\+<outline.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/g'`" )
		printf "%sing:\n\t %s\n", "${message}", "${podcast}";
		( gpodder --${action}="${podcast}" > /dev/tty ) >& /dev/null;
		printf "\t\t[done]\n";
	end
end

exit 0;

usage:
	printf "Usage: %s --[add|subscribe|unsubscribe|delete]=OPML_file"
	if(!( ${?action })) exit -1;
	goto next_option;
