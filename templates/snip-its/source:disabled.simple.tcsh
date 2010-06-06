if(! ${?0} ) then
	printf "This script can, not sourced, only be executed.\n" > /dev/stderr;
	set status=-1;
	exit ${status};
endif


