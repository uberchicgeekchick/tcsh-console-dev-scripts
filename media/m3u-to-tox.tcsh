#!/bin/tcsh -f
	set scripts_basename="`basename '${0}'`";
	alias ex "ex -E -X -n --noplugin";
	
	@ arg=0;
	set argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		
		set argument_file="./.escaped.argument.$scripts_basename.argv[$arg].`date '+%s'`.arg";
		printf "$argv[$arg]" >! "${argument_file}";
		ex -X -n --noplugin -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${argument_file}";
		set argument="`cat "\""${argument_file}"\""`";
		rm -f "${argument_file}";
		unset argument_file;
		
		set dashes="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\1/'`";
		if( "${dashes}" == "${argument}" ) \
			set dashes="";
		
		set option="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\2/'`";
		if( "${option}" == "${argument}" ) \
			set option="";
		
		set equals="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\3/'`";
		if( "${equals}" == "${argument}" ) \
			set equals="";
		
		set value="`printf "\""${argument}"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=)?(.*)"\$"/\4/'`";
		
		switch("${option}")
			case "edit-playlist":
				if(! ${?edit_playlist} ) \
					set edit_playlist;
				breaksw;
			
			case "insert-subdir":
				set insert_subdir="${value}";
				breaksw;
			
			case "strip-subdir":
				set strip_subdir="${value}";
				breaksw;
			
			case "clean-up":
				switch( "${value}" )
					case "force":
						set clean_up="-f";
						breaksw;
					
					default:
						set clean_up="-i";
						breaksw;
				endsw
				breaksw;
			
			default:
				if( -e "${value}" && "`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/.*(\.m3u)"\$"/\1/'`" == ".m3u" ) then
					set m3u_playlist="${value}";
					breaksw;
				endif
				
				if( "`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/.*(\.tox)"\$"/\1/'`" == ".tox" ) then
					set tox_playlist="${value}";
					breaksw;
				endif
				
				printf "**${scripts_basename} error:** ${dashes}${option}${equals}${value} is an unsupported option.\n\nSee "\`"${scripts_basename} -h|--help"\`" for more information.\n" > /dev/stderr;
				@ errno=-609;
				goto exit_script;
			breaksw;
		endsw
	end

if(! ${?m3u_playlist} ) then
	printf "\n\t**ERROR:** a valid m3u playlist has not been specified.\n";
	printf "Usage: "\`"${scripts_basename}"\`" playlist.m3u [toxine/playlist/filename.tox]\n";
	@ errno -1;
	goto exit_script;
endif

if(! ${?tox_playlist} ) then
	set tox_playlist="`printf "\""%s"\"" "\""${tox_playlist}"\"" | sed 's/\(.*\)\([^\/]\+\)\(\.m3u\)"\$"/\1\2\.tox/'`";
endif

if( "${m3u_playlist}" == "${tox_playlist}" ) then
	printf "Failed to generate a toxine playlist filename." > /dev/stderr;
	@ errno=-1;
	goto exit_script;
endif

if( ${?strip_subdir} ) then
	if( "${strip_subdir}" == "" ) then
		unset strip_subdir;
	else if( ${?insert_subdir} ) then
		if( "${strip_subdir}" == "${insert_subdir}" ) then
			set insert_subdir="";
			unset strip_subdir;
		endif
	endif
else if(! ${?insert_subdir} ) then
	set insert_subdir="";
endif


if( ${?edit_playlist} ) \
	${EDITOR} "${tox_playlist}";

printf "Converting: "\""${m3u_playlist}"\"" to "\""${tox_playlist}"\";

alias	ex	"ex -E -n -X --noplugin";

set m3u_playlist="`printf "\""%s"\"" "\""${m3u_playlist}"\"" | sed -r 's/([\(\)\ ])/\\\1/g'`";
printf '#toxine playlist\n\n' >! "${tox_playlist}";
ex -s "+2r ${m3u_playlist}" '+wq!' "${tox_playlist}";
ex -s '+3,$s/^\#.*\n//' "+3,"\$"s/\v^(\/[^\/]+\/[^\/]+\/)(.*\/)(.*)(\.[^.]+)"\$"/entry\ \{\r\tidentifier\ \=\ \3;\r\tmrl\ \=\ \1${insert_subdir}\2\3\4\;\r\tav_offset\ \=\ 3600;\r\}\;\r/" '+wq' "${tox_playlist}";

if( ${?strip_subdir} ) then
	ex -s "+2,"\$"s/\v^(\/[^\/]+\/[^\/]+\/)${strip_subdir}\/(.*\/)(.*)(\.([^\.]+)"\$"/\1\2\3\4/" '+wq' "${m3u_playlist}";
endif

ex -s '+1,$s/\v^(\tidentifier\ \=\ )(.*), released on.*;$/\1\2;/' '+wq' "${tox_playlist}";

printf '#END' >> "${tox_playlist}";

printf "\t\t[done]\n";

exit_script:
	if(! ${?errno} ) \
		@ errno=0;
	@ status=${errno};
	exit ${status};
#exit_script:

