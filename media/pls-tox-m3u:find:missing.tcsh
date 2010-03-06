#!/bin/tcsh -f
init:
	if(! ${?eol} ) then
		set eol='$';
		set eol_set;
	endif
	
	set script_name="tcsh-script.tcsh";
	
	if( `printf '%s' "${0}" | sed -r 's/^[^\.]*(csh)$/\1/'` == "csh" ) then
		set status=-1;
		printf "%s does not support being sourced and can only be executed.\n" "${script_name}";
		goto usage;
	endif
	
	set argc=${#argv};
	if( ${argc} < 2 ) goto usage;
	
	set old_owd="${cwd}";
	cd "`dirname '${0}'`";
	set script_path="${cwd}";
	cd "${owd}";
	set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	set owd="${old_owd}";
	unset old_owd;
	
	set script="${script_path}/${script_name}";
	
	set message="";
	set extensions="";
	
	alias	ex	"ex -E -n -X --noplugin";
	
	goto parse_argv;
#init:

main:
	if(! ${?playlist} ) goto usage;

	if( ${?message} ) then
		printf "${message}";
	endif

	if(! ${?maxdepth} ) then
		set maxdepth=" -maxdepth 2";
	endif

	if(! ${?mindepth} ) then
		set mindepth=" ";
	endif
#main:

find_missing_media:
if( ${?debug} ) printf "Searching for missing multimedia files using:\n\tfind -L ${cwd}/${maxdepth}${mindepth} -type f -iregex '.*${extensions}${eol}' | sed -r 's/[${eol}]/"\""\\${eol}"\""/g' | sed -r 's/([\\\[])/\\\1/g'";
@ removed_podcasts=0;
foreach podcast("`find -L ${cwd}/${maxdepth}${mindepth}-type f -iregex '.*${extensions}${eol}' | sed -r 's/[${eol}]/"\""\\${eol}"\""/g' | sed -r 's/([\\\[])/\\\1/g'`")
	if( ${?skip_subdirs} ) then
		foreach skip_subdir( "`printf "\""${skip_subdirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ ${eol}//'`" )
			if( "`printf '%s' "\""${podcast}"\"" | sed -r 's/^${escaped_cwd}\/(${skip_subdir})\/.*/\1/'`" == "${skip_subdir}" ) then
				unset skip_subdir;
				break;
			endif
		end
		if(! ${?skip_subdir} ) continue;
	endif
	
	if( `/bin/grep "${podcast}" "${playlist}"` != "" ) continue;
	
	if( ${?duplicates_subdirs} ) then
		foreach duplicates_subdir ( "`printf "\""${duplicates_subdirs}"\"" | sed -r 's/^\ //' | sed -r 's/\ ${eol}//'`" )
			set duplicate_podcast="`printf '%s' "\""${podcast}"\"" | sed -r "\""s/^${escaped_cwd}\//${escaped_cwd}\/${duplicates_subdir}\//"\""`";
			if(! -e "${duplicate_podcast}" ) continue;
			if(! ${?dublicate_podcasts} ) then
				set duplicate_podcasts=("${duplicate_podcast}");
			else
				set duplicate_podcasts=( "${duplicate_podcasts}" "\n" "${duplicate_podcast}");
			endif
		end
		unset duplicate_podcast;
	endif
	
	if(! ${?remove} ) then
		printf "%s\n" "${podcast}";
		if( ${?create_script} ) then
			printf "%s\n" "${podcast}" >> "${create_script}";
		endif
		if( ${?duplicate_podcasts} ) then
			foreach duplicate_podcast ( "`printf "\""${duplicate_podcasts}"\"" | sed -r 's/^\ //' | sed -r 's/\ ${eol}//'`" )
				printf "%s\n" "${duplicate_podcast}";
				if( ${?create_script} ) then
					printf "%s\n" "${duplicate_podcast}" >> "${create_script}";
				endif
			end
		endif
		continue;
	endif
	
	set podcast="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r "\""s/\\([\\\[])/\1/g"\""`";
	
	set rm_confirmation=`rm -vf${remove} "${podcast}"`;
	if(!( ${status} == 0 && "${rm_confirmation}" != "" )) continue;
	
	@ removed_podcasts++;
	if( ${?create_script} ) then
		printf "rm -vf${remove} "\""${podcast}"\"";\n" >> "${create_script}";
	endif
	
	set podcast_dir=`dirname "${podcast}"`;
	if( "${podcast_dir}" == "${cwd}" ) continue;
	while( "${podcast_dir}" != "/" && "${podcast_dir}" != "${cwd}" )
		if( `ls "${podcast_dir}"` != "" ) break;
		rmdir -v "${podcast_dir}";
		if( ${?create_script} ) then
			printf "rmdir -v "\""${podcast_dir}"\"";\n" >> "${create_script}";
		endif
		set podcast_dir=`dirname "${podcast_dir}"`;
	end
	
	if(! ${?duplicate_podcasts} ) continue;
	
	foreach duplicate_podcast ( "`printf "\""${duplicate_podcasts}"\"" | sed -r 's/^\ //' | sed -r 's/\ ${eol}//'`" )
		set duplicate_podcast="`printf "\""%s"\"" "\""${duplicate_podcast}"\"" | sed -r "\""s/\\([\\\[])/\1/g"\""`";
		@ removed_podcasts++;
		set rm_confirmation=`rm -vf${remove} "${duplicate_podcast}"`;
		if( ${?create_script} && ${status} == 0 && "${rm_confirmation}" != "" ) then
			printf "rm -vf${remove} "\""${duplicate_podcast}"\"";\n" >> "${create_script}";
		endif
		
		set podcast_dir=`dirname "${duplicate_podcast}"`;
		if( "${podcast_dir}" == "${cwd}" ) continue;
		while( "${podcast_dir}" != "/" && "${podcast_dir}" != "${cwd}" )
			if( `ls "${podcast_dir}"` != "" ) break;
			rmdir -v "${podcast_dir}";
			if( ${?create_script} ) then
				printf "rmdir -v "\""${podcast_dir}"\"";\n" >> "${create_script}";
			endif
			set podcast_dir=`dirname "${podcast_dir}"`;
		end
	end
	unset duplicate_podcasts;
end
#find_missing_media:

if( $removed_podcasts == 0 && ${?create_script} ) then
	rm "${create_script}";
endif

if( ${?old_owd} ) then
	cd "${owd}";
	set owd="${old_owd}";
	unset old_owd;
endif

if( ${?duplicates_subdir} ) unset duplicates_subdir;
if( ${?duplicate_podcast} ) unset duplicate_podcast;
unset podcast_dir podcast playlist;
set status=0;

exit_script:
	exit ${status};

usage:
	printf "\nUsage:\n\t%s playlist [directory] [--(extension|extensions)=] [--maxdepth=] [--skip-subdir=<sub-directory>] [--check-for-duplicates-in-subdir=<sub-directory>] [--remove[=(interactive|force)]]\n\tfinds any files in [directory], or its sub-directories, up to files of --maxdepth.  If the file is not not found in playlist,\n\tThe [directory] that's searched is [./] by default unless another absolute, or relative, [directory] is specified.\n\t[--(extension|extensions)=] is optional and used to search for files with extension(s) matching the string or escaped regular expression, e.g. --extensions='\\(mp3\\|ogg\\)' only. Otherwise all files are searched for.\n--remove is also optional.  When this option is given %s will remove podcasts which aren't in the specified playlist.  Unless --remove is set to force you'll be prompted before each file is actually deleted.  If, after the file(s) are deleted, the parent directory is empty it will also be removed.\n" "`basename '${0}'`" "`basename '${0}'`";
	set status=-1;
	if( ${?option} ) then
		if( "${option}" == "help" ) then
			set status=0;
		else
			goto next_option;
		endif
	endif
	goto exit_script;
#usage:

parse_argv:
	@ argc=${#argv};
	
	if( ${argc} == 0 ) goto main;
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		if( "$argv[$arg]" != "--debug" ) continue;
		printf "Enabling debug mode (via "\$"argv[%d])\n" $arg;
		set debug;
		break;
	end
	
	if( ${arg} == 1 ) then
		@ arg++;
		if( $arg > $argc ) goto usage;
	else
		@ arg=1;
	endif
	
	if(!( "$argv[$arg]" != "" && -e "$argv[$arg]" ))	\
		goto usage;
	
	set playlist="$argv[$arg]";
	
	@ arg++;
	if( $arg > $argc ) goto usage;
	if(!( "$argv[$arg]" != "" && -d "$argv[$arg]" )) then
		goto usage;
	else if( "$argv[$arg]" != "${cwd}" ) then
		set old_owd="${owd}";
		cd "$argv[$arg]";
	endif
	
	if( ${?debug} ) printf "Checking %s's argv options.  %d total.\n" "$argv[1]" "${argc}";
#parse_argv:

parse_arg:
	while( $arg < $argc )
		@ arg++;
		
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\3/'`";
		if( "${value}" == "$argv[$arg]" ) then
			@ arg++;
			if( $arg > $argc ) continue;
			set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`";
			set option="`printf "\""$argv[$arg]}"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/'`";
			set value="`printf "\""$argv[$arg]}"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\3/'`";
			if(!("${dashes}" == "$argv[$arg]" && "${option}" == "$argv[$arg]" && "${value}" == "$argv[$arg]")) then
				@ arg--;
				set value="";
			else
				set value="$argv[$arg]";
			endif
		endif
		set equals="";
		if( "${value}" != "$argv[$arg]" ) then
			set equals="=";
		else
			set value="";
		endif
		
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/'`";
		if( "${option}" == "$argv[$arg]" ) set option="";
		
		if( ${?debug} )		\
			printf "**debug** parsed %sargv[%d] (%s).\n\tParsed option: %s%s%s%s\n" "${eol}" "${arg}" "$argv[$arg]" "${dashes}" "${option}" "${equals}" "${value}";
		
		switch( "${option}" )
			case "help":
				goto usage;
				breaksw;
			
			case "check-for-duplicates-in-subdir":
			case "skip-files-in-subdir":
			case "skip-subdir":
				set value="`printf '%s' "\""${value}"\"" | sed -r 's/^\///' | sed -r 's/\/${eol}//'`";
				if( ! -d "${value}" && ! -L "${value}" ) then
					printf "--%s must specify a sub-directory of %s.\n" "${option}" "${cwd}" > /dev/stderr;
					continue;
				endif
				
				switch("${option}")
					case "check-for-duplicates-in-subdir":
						if(! ${?duplicates_subdirs} ) then
							set duplicates_subdirs=("${value}");
						else
							set duplicates_subdirs=( "${duplicates_subdirs}" "\n" "${value}");
						endif
						breaksw;
					
					case "skip-files-in-subdir":
					case "skip-subdir":
						if(! ${?skip_subdirs} ) then
							set skip_subdirs=("${value}");
						else
							set skip_subdirs=( "${skip_subdirs}" "\n" "${value}" );
						endif
						breaksw;
					
				endsw
				breaksw;
			
			case "enable":
				switch("${value}")
					case "logging":
						breaksw;
					
					default:
						printf "%s cannot be enabled.\n" "${value}" > /dev/stderr;
						shfit;
						continue;
						breaksw;
					
				endsw
			case "create-script":
			case "mk-script":
				if("${value}" != "" &&  "${value}" != "logging") then
					set create_script="${value}";
				else
					set create_script="clean-up:script.tcsh";
				endif
				if(! -e "${create_script}" ) then
					printf "#\!/bin/tcsh -f\n" > "${create_script}";
					chmod u+x "${create_script}";
				endif
				breaksw;
			
			case "extension":
			case "extensions":
				if( "${value}" != "" ) set extensions="${value}";
				breaksw;
			
			case "debug":
				set debug;
				breaksw;
			
			case "remove":
				switch("${value}")
					case "force":
						set remove="";
						set message="**Files found in\n\t\t[${cwd}]\n\twhich are not in the playlist\n\t\t[${playlist}]\n\twill be removed.**\n\n";
						breaksw;
					
					case "interactive":
					default:
						set remove="i";
						set message="**Files found in\n\t\t[${cwd}]\n\twhich are not in the playlist\n\t\t[${playlist}]\n\twill be prompted for removal.**\n\n";
						breaksw;
					
				endsw
				breaksw;
			
			case "recursive":
				set maxdepth=" ";
				breaksw;
			
			case "search-subdirs-only":
				set mindepth=" -mindepth 2 ";
				breaksw;
			
			case "maxdepth":
				if( ${value} != "" && `printf '%s' "${value}" | sed -r 's/^([\-]).*/\1/'` != "-" ) then
					set value=`printf '%s' "${value}" | sed -r 's/.*([0-9]+).*/\1/'`
					if( ${value} > 2 ) set maxdepth=" -maxdepth ${value} ";
				endif
				if(! ${?maxdepth} ) printf "--maxdepth must be an integer value that is gretter than 2" > /dev/null;
				breaksw;
			
			default:
				printf "\n%s%s is an unsupported option.\n\tRun %s%s --help%s for supported options and details.\n" "${dashes}" "${option}" '`' "`basename '${0}'`" '`' > /dev/stderr;
				breaksw;
			
		endsw
	end
	goto main;
#parse_arg:

