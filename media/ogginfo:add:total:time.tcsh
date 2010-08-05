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
	unset escaped_value;
	printf "%s\n" "${value}" >> "${oggfile_list}";
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
if(! ${?ogginfo_file} ) \
	set ogginfo_file="`mktemp --tmpdir .escaped.ogginfo.XXXXXXXX`";
foreach oggfile("`cat "\""${oggfile_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`")
	if( "${seconds}" != "" ) \
		set seconds="${seconds}+";
	set oggfile="`printf "\""%s"\"" "\""${oggfile}"\""`";
	ogginfo "${oggfile}" >! "${ogginfo_file}";
	set playback_length=`grep 'Playback length:' "${ogginfo_file}" | sed -r 's/.*Playback length: ([0-9]+m:[0-9]+\.[0-9]+s)/\1/'`;
	printf "Length of:\n\t<file://%s>\n\t\t%s\n" "${oggfile}" "${playback_length}";
	set seconds="`printf "\""%s%s"\"" "\""${seconds}"\"" "\""${playback_length}"\"" | sed -r 's/([0-9]+)m:([0-9]+)\.([0-9]+)s/\2/'`";#+0\.\3/'`";
	if( ${?debug} ) \
		printf "seconds: ${seconds}\n";
	if( "${minutes}" != "" ) \
		set minutes="${minutes}+";
	set minutes="`printf "\""%s%s"\"" "\""${minutes}"\"" "\""${playback_length}"\"" | sed -r 's/([0-9]+)m:([0-9]+)\.([0-9]+)s/\1/'`";
	if( ${?debug} ) \
		printf "minutes: ${minutes}\n";
end
if( -e "${ogginfo_file}" ) then
	rm -f "${ogginfo_file}";
	unset ogginfo_file;
endif

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
	if( ${?ogginfo_file} ) then
		if( -e "${ogginfo_file}" ) then
			rm -f "${ogginfo_file}";
		endif
	endif
	exit 0;
#goto exit_script;

usage:
	printf "Usage: %s oggfiles..." "`basename "\""${0}"\""`";
	goto exit_script;
#goto usage:
