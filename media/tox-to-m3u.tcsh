#!/bin/tcsh -f
	if(! ${?echo_style} ) then
		set echo_style_set;
		set echo_style=both;
	else
		if( "${echo_style}" != "both" ) then
			set original_echo_style="${echo_style}";
			set echo_style_set;
			set echo_style=both;
		endif
	endif
	if( "`alias echo`" != "echo -n" ) then
		if( "`alias echo`" != "" ) \
			set original_echo_alias="`alias echo`";
		alias echo "echo -n";
		set echo_alias_set;
	endif
	
if( "${1}" != "" && "${1}" == "--edit-playlist" ) then
	set edit_playlist;
	shift;
endif

if( ! ( ${?1} && -e "${1}" && "${1}" != "" && `echo ${1} | sed -r 's/([\!\$\"])/"\\\1"/g' | sed -r 's/.*(\.tox)$/\1/'` == ".tox" ) ) then
	if( "`echo -n "\""${1}"\"" | sed 's/.*\(\.m3u\)"\$"/\1/'`" != ".tox" ) \
		echo -n "\n\t**ERROR:** ${1} is not a valid toxine playlist.\n";
	echo -n "Usage: `basename '${0}'` playlist.tox [toxine/playlist/filename.m3u]\n";
	@ errno -1;
	goto exit_script;
endif

set tox_playlist=`echo ${1} | sed -r 's/([\!\$\"])/"\\\1"/g'`;
shift;

if( ! ( "${1}" != "" && `echo ${1} | sed -r 's/([\!\$\"])/"\\\1"/g' | sed -r 's/.*(\.m3u)$/\1/g'` == ".m3u" ) ) then
	set m3u_playlist=`echo ${m3u_playlist} | sed 's/\(.*\)\([^\/]\+\)\(\.m3u\)"\$"/\1\2\.tox/'`;
else
	set m3u_playlist=`echo ${1} | sed -r 's/([\!\$\"])/"\\\1"/g'`;
	shift;
endif

set insert_subdir="";
if( `echo ${1} | sed -r 's/([\!\$\"])/"\\\1"/g' | sed -r 's/[\-]{1,2}([^=]+)=(.*)/\1/'` == "insert-subdir" ) then
	set insert_subdir=`echo ${1} | sed -r 's/([\!\$\"])/"\\\1"/g' | sed -r 's/[\-]{1,2}([^=]+)=?(.*)/\2/'`;
	if( "${insert_subdir}" == "" ) \
		unset insert_subdir;
	shift;
endif

if( `echo ${1} | sed -r 's/([\!\$\"])/"\\\1"/g' | sed -r 's/[\-]{1,2}([^=]+)=(.*)/\1/'` == "strip-subdir" ) then
	set strip_subdir=`echo ${1} | sed -r 's/([\!\$\"])/"\\\1"/g' | sed -r 's/[\-]{1,2}([^=]+)=?(.*)/\2/'`;
	if( "${strip_subdir}" == "" ) then
		unset strip_subdir;
	else if( "${strip_subdir}" == "${insert_subdir}" ) then
		set insert_subdir="";
		unset strip_subdir;
	endif
	shift;
endif

if( "${tox_playlist}" == "${m3u_playlist}" ) then
	echo -n "Failed to generate tox filename.";
	@ errno=-1;
	goto exit_script;
endif

if( ${?edit_playlist} ) ${EDITOR} "${tox_playlist}";

printf "Converting "\""${tox_playlist}"\"" to "\""${m3u_playlist}"\";

alias	ex	"ex -E -n -X --noplugin";

set tox_playlist=`echo ${tox_playlist} | sed -r 's/([\(\)\ ])/\\\1/g'`;
ex -s "+1r ${tox_playlist}" '+wq!' "${m3u_playlist}";
ex -s '+2,$s/^\#.*[\r\n]//' '+2,$s/^entry\ {[\r\n]\+//' '+2,$s/^};$//' "+2,"\$"s/\v^\tmrl\ \=\ (\/[^\/]+\/[^\/]+\/)(.*\/)([^\/]+)(\.[^\.]+);"\$"/\#EXTINF\:,\3\r\1${insert_subdir}\2\3\4/" '+2,$s/^\t.*;[\r\n]\+//' '+1,$s/^[\r\n]\+//' '+$d' '+wq' "${m3u_playlist}";

if( ${?strip_subdir} ) then
	ex -s "+3,"\$"s/\v^(\/[^\/]+\/[^\/]+\/)${strip_subdir}\/(.*\/)[^\/]+)(\.([^\.]+)"\$"/\1\2\3\4/" '+wq' "${m3u_playlist}";
endif

ex -s '+1,$s/\v^(\#EXTINF\:,)(.*), released on.*$/\1\2/' '+wq' "${m3u_playlist}";

printf "\t[done]\n";

exit_script:
	if( ${?original_echo_style} ) then
		set echo_style="${original_echo_style}";
		unset original_echo_style;
	else if( ${?echo_style_set} ) then
		unset echo_style;
	endif
	if( ${?echo_alias_set} ) then
		if( ${?original_echo_alias} ) then
			alias echo "${original_echo_alias}";
			unset original_echo_alias;
		endif
		unset echo_alias_set;
	endif
	
	if(! ${?errno} ) \
		@ errno=0;
	@ status=${errno};
	exit ${status};
#exit_script:

