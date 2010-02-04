#!/bin/tcsh -f

if(!( "${1}" != "" && -e "${1}" )) goto usage;

set playlist="${1}";
shift;

if( "${1}" != "" && -d "${1}" ) then
	if( "${1}" != "${cwd}" ) then
		set search_dir="${1}";
		cd "${search_dir}";
	endif
	shift;
endif

if(! ${?eol} ) setenv eol '$';

set extensions="";
set message="";
while( "${1}" != "" )
	set dashes="`printf '%s' '${1}' | sed -r 's/([\-]{1,2})([^=]*)=?["\""'\''"\"""\""]?(.*)["\""'\''"\"""\""]?/\1/'`";
	set option="`printf '%s' '${1}' | sed -r 's/([\-]{1,2})([^=]*)=?["\""'\''"\"""\""]?(.*)["\""'\''"\"""\""]?/\2/'`";
	set value="`printf '%s' '${1}' | sed -r 's/([\-]{1,2})([^=]*)=?["\""'\''"\"""\""]?(.*)["\""'\''"\"""\""]?/\3/'`";
	switch( "${option}" )
		case "help":
			goto usage;
			breaksw;
		
		case "check-for-duplicates-in-subdir":
			if(! -d "${value}" ) then
				printf "--%s must specify a sub-directory of %s.\n" "${option}" "${cwd}" > /dev/stderr;
			else
				set duplicates_subdir="${value}";
			endif
			breaksw;
		
		case "skip-files-in-subdir":
		case "skip-subdir":
			if(! -d "${value}" ) then
				printf "--%s must specify a sub-directory of %s.\n" "${option}" "${cwd}" > /dev/stderr;
			else
				set skip_subdir="`printf '%s' "\""${value}"\"" | sed -r 's/\/${eol}//' | sed -r 's/^\///'`";
			endif
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
	next_option:
	shift;
end;

if(! ${?playlist} ) goto usage;

if( ${?skip_subdir} ) then
	if( "`/bin/ls ./`" == "${skip_subdir}" ) exit 0;
endif

if( ${?message} ) then
	printf "${message}";
endif

if(! ${?maxdepth} ) then
	set maxdepth=" -maxdepth 2 ";
endif

set this_dir="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
if( ${?debug} ) printf "Searching for missing multimedia files using:\n\tfind ./${maxdepth}-mindepth 2 -type f -iregex '.*${extensions}${eol}' | sed -r 's/"\""/"\""\\"\"""\""/g' | sed -r 's/[${eol}]/"\""\\${eol}"\""/g' | sed -r 's/\[/\\\[/g'";
@ removed_podcasts=0;
foreach podcast("`find ./${maxdepth}-mindepth 2 -type f -iregex '.*${extensions}${eol}' | sed -r 's/"\""/"\""\\"\"""\""/g' | sed -r 's/[${eol}]/"\""\\${eol}"\""/g' | sed -r 's/\[/\\\[/g'`")
	if( ${?skip_subdir} ) then
		if( "`printf '%s' "\""${podcast}"\"" | sed -r 's/^\.\/(${skip_subdir})\/.*/\1/'`" == "${skip_subdir}" ) continue;
	endif
	
	set podcast_file="`printf '%s' "\""${podcast}"\"" | sed -r "\""s/^\.\//${this_dir}\//"\""`";
	if( `/bin/grep "${podcast_file}" "${playlist}"` != "" ) continue;
	if( ${?debug} ) printf "**missing file:** [%s].\n" "${podcast_file}";
	
	if( ${?duplicates_subdir} ) then
		set duplicate_podcast="`printf '%s' "\""${podcast}"\"" | sed -r "\""s/^\.\//${this_dir}\/${duplicates_subdir}\//"\""`";
		if(! -e "${duplicate_podcast}" ) unset duplicate_podcast;
	endif
	
	if(! ${?remove} ) then
		printf "%s\n" "${podcast_file}";
		if( ${?create_script} ) then
			printf "%s\n" "${podcast_file}" >> "${create_script}";
		endif
		if( ${?duplicate_podcast} ) then
			printf "%s\n" "${duplicate_podcast}";
			if( ${?create_script} ) then
				printf "%s\n" "${duplicate_podcast}" >> "${create_script}";
			endif
		endif
		continue;
	endif
	
	set rm_confirmation=`rm -vf${remove} "${podcast_file}"`;
	if( ${status} == 0 && "${rm_confirmation}" != "" ) then
		@ removed_podcasts++;
		if( ${?create_script} ) then
			printf "rm -vf${remove} "\""${podcast_file}"\"";\n" >> "${create_script}";
		endif
		if( ${?duplicate_podcast} ) then
			@ removed_podcasts++;
			set rm_confirmation=`rm -vf${remove} "${duplicate_podcast}"`;
			if( ${?create_script} && ${status} == 0 && "${rm_confirmation}" != "" ) then
				printf "rm -vf${remove} "\""${duplicate_podcast}"\"";\n" >> "${create_script}";
			endif
		endif
	endif
	
	set podcast_dir=`dirname "${podcast_file}"`;
	if( "${podcast_dir}" == "${cwd}" ) continue;
	while( "${podcast_dir}" != "/" && "${podcast_dir}" != "${cwd}" )
		if( `ls "${podcast_dir}"` != "" ) break;
		rmdir -v "${podcast_dir}";
		if( ${?create_script} ) then
			printf "rmdir -v "\""${podcast_dir}"\"";\n" >> "${create_script}";
		endif
		set podcast_dir=`dirname "${podcast_dir}"`;
	end
	
	if(! ${?duplicate_podcast} ) continue;
	
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

if( $removed_podcasts == 0 && ${?create_script} ) rm "${create_script}";

if( ${?search_dir} ) then
	cd "${owd}";
	unset search_dir;
endif

if( ${?duplicates_subdir} ) unset duplicates_subdir;
if( ${?duplicate_podcast} ) unset duplicate_podcast;
unset podcast_dir podcast podcast_file playlist;
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
