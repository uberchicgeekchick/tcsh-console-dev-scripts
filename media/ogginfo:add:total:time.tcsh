#!/bin/tcsh -f
if(! ${?0} ) then
	printf "Cannot source.\n";
	exit -1;
endif

onintr exit_script;
@ arg=0;
@ argc=${#argv};

while( $arg < $argc )
	@ arg++;
	if(!( "$argv[$arg]" != "--help" &&  "$argv[$arg]" != "-h" && -e "$argv[$arg]" && `printf "%s" "$argv[$arg]" | sed -r 's/.*\.([^.]+)$/\1/'` == "ogg" )) then
		goto usage;
	endif

	if(! ${?oggfile_list} ) \
		set oggfile_list="`mktemp --tmpdir .filenames.for.ogginfo.XXXXXXXX`";
	printf "%s\n" "$argv[$arg]" >> "${oggfile_list}";
end
if(! ${?oggfile_list} ) then
	goto usage;
else if(! -e "${oggfile_list}" ) then
	goto usage;
else if(!( `wc -l "${oggfile_list}" | sed -r 's/^([0-9]+).*$/\1/'` > 0 )) then
	goto usage;
endif

set seconds;
set minutes;
foreach oggfile("`cat "\""${oggfile_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`")
	if( "${seconds}" != "" ) \
		set seconds="${seconds}+";
	set seconds="${seconds}`ogginfo "\""${oggfile}"\"" | grep 'Playback length:' | sed -r 's/.*Playback length: ([0-9]+)m:([0-9]+)\.([0-9]+)s/\2/'`";
	if( ${?debug} ) \
		printf "seconds: ${seconds}\n";
	if( "${minutes}" != "" ) \
		set minutes="${minutes}+";
	set minutes="${minutes}`ogginfo "\""${oggfile}"\"" | grep 'Playback length:' | sed -r 's/.*Playback length: ([0-9]+)m:([0-9]+)\.([0-9]+)s/\1/'`";
	if( ${?debug} ) \
		printf "minutes: ${minutes}\n";
end

set extra_minutes=`printf "(${seconds})/60\n" | bc`;
set seconds=`printf "(${seconds})%%60\n" | bc`;
set hours=`printf "(${extra_minutes}+${minutes})/60\n" | bc`;
set minutes=`printf "(${extra_minutes}+${minutes})%%60\n" | bc`;

if( $seconds < 10 ) \
	set seconds="0${seconds}";

if( $minutes < 10 ) \
	set minutes="0${minutes}";

if( $hours < 10 ) \
	set hours="0${hours}";

printf "hours: %s; minutes: %s; seconds: %s\n" "${hours}" "${minutes}" "${seconds}";

exit_script:
	if( ${?oggfile_list} ) then
		if( -e "${oggfile_list}" ) then
			rm -f "${oggfile_list}";
		endif
	endif
	exit 0;
#goto exit_script;

usage:
	printf "Usage: %s oggfiles..." "`basename "\""${0}"\""`";
	goto exit_script;
#goto usage:
