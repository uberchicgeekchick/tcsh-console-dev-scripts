#!/bin/tcsh -f
if ( -x "/usr/bin/ghb" ) then
	alias	handbrake	"/usr/bin/ghb"
	alias	HandBrake	"handbrake"
	alias	HandBrakeGTK	"handbrake"
	alias	HandBrakeGUI	"handbrake"
endif

if ( -x "/usr/bin/id3v2" ) alias	mp3info	"id3v2 --list"

if(!(${?DEBUG_EXEC})) then
	setenv output " >& /dev/null &";
else
	setenv output " &";
endif
									
set starting_path=${cwd};

cd "/projects/cli/launchers";
foreach launcher ( "`find . -type f -perm '/u=x' -printf '%f\n'`" )
	if( "${launcher}" == "template" ) continue;
	
	if( "`echo ${launcher} | sed 's/.*\(\.init\)${eol}/\1/g'`" == ".init" ) then
		source ${launcher};
	else
		alias "${launcher}" "${cwd}/${launcher}";
	endif
end

cd ${starting_path};
unsetenv output

