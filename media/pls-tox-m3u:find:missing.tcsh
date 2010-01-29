#!/bin/tcsh -f

if( "${1}" != "" && -e "${1}" ) then
	set playlist="${1}";
	shift;
endif

if( "${1}" == "" ) then
	cd .;
else if( -d "${1}" ) then
	set search_dir="${1}";
	cd "${search_dir}";
	shift;
endif

set extension="";
while( "${1}" != "" )
	set option="`echo '${1}' | sed -r 's/[\-]{2}([^=]*)=?["\""'\''"\"""\""]?(.*)["\""'\''"\"""\""]?/\1/'`";
	set value="`echo '${1}' | sed -r 's/[\-]{2}([^=]*)=?["\""'\''"\"""\""]?(.*)["\""'\''"\"""\""]?/\2/'`";
	switch( "${option}" )
		case 'h':
		case 'help':
			goto usage;
			breaksw;
		case 'check-for-duplicates-in-subdir':
			set duplicates_subdir="${value}";
			breaksw;
		case 'enable':
			if( "${value}" != "logging" ) breaksw;
		case 'create-script':
		case 'mk-script':
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
		case 'extension':
		case 'extensions':
			if( "${value}" != "" ) set extension="${value}";
			breaksw;
		case "debug":
			set debug;
			breaksw;
		case "remove":
			set remove="";
			if( "${value}" == "interactive" ) then
				set remove="i";
				printf "**Podcasts not found in [%s] will be prompted for removal.**\n" "${playlist}";
			else
				printf "**Podcasts not found in [%s] will be removed.**\n" "${playlist}";
			endif
			breaksw;
		case "recursive":
			set recursive;
			breaksw;
		default:
			printf "%s is an unsupported option.\n" "${option}";
			goto usage;
			breaksw;
	endsw
	shift;
end;

if(! ${?playlist} ) goto usage;

if(! ${?eol} ) setenv eol '$';

if(! ${?recursive} ) then
	set maxdepth=" -maxdepth 2 ";
else
	set maxdepth=" ";
endif

set this_dir="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
foreach podcast("`find ./${maxdepth}-mindepth 2 -type f -iregex '.*${extension}${eol}' | sed -r 's/"\""/"\""\\"\"""\""/g' | sed -r 's/[${eol}]/"\""\\${eol}"\""/g'`")
	if( "`echo "\""${podcast}"\"" | sed -r 's/^\.\/(nfs)\/.*/\1/'`" == "nfs" ) continue;
	
	set podcast_file="`echo "\""${podcast}"\"" | sed -r "\""s/^\.\//${this_dir}\//"\""`";
	if( ${?debug} ) printf "Searching for [%s].\n" "${podcast_file}";
	if( `/bin/grep "${podcast_file}" "${playlist}"` != "" ) continue;
	
	if( ${?duplicates_subdir} ) then
		set duplicate_podcast="`echo "\""${podcast}"\"" | sed -r "\""s/^\.\//${this_dir}\/${duplicates_subdir}\//"\""`";
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
		if( ${?create_script} ) then
			printf "rm -vf${remove} "\""${podcast_file}"\"";\n" >> "${create_script}";
		endif
		if( ${?duplicate_podcast} ) then
			set rm_confirmation=`rm -vf${remove} "${duplicate_podcast}"`;
			if( ${?create_script} && ${status} == 0 && "${rm_confirmation}" != "" ) then
				printf "rm -vf${remove} "\""${duplicate_podcast}"\"";\n" >> "${create_script}";
			endif
		endif
	endif
	
	set podcast_dir=`dirname "${podcast_file}"`;
	if( "${podcast_dir}" == "${cwd}" ) continue;
	while( "${podcast_dir}" != "/" )
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
	while( "${podcast_dir}" != "/" )
		if( `ls "${podcast_dir}"` != "" ) break;
		rmdir -v "${podcast_dir}";
		if( ${?create_script} ) then
			printf "rmdir -v "\""${podcast_dir}"\"";\n" >> "${create_script}";
		endif
		set podcast_dir=`dirname "${podcast_dir}"`;
	end
end

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
	printf "Usage:\n\t%s playlist [directory] [--extension=] [--check-for-duplicates-in-subdir=subdir] [--remove[=interactive]]\n\tfinds any files in directory not found in playlist,\n\t[directory] searches [./] by default is [./].\n\t[--extension=] is optional and used to search for files with that extension only. Otherwise all files are searched for.\n--remove is also optional.  When this option is given %s will remove podcasts which aren't in the specified playlist.  When --remove is set to interactive you'll be prompted before each file is actually deleted.  If, after the file(s) are deleted, the parent directory is empty it will also be removed.\n" "`basename '${0}'`" "`basename '${0}'`";
	set status=-1;
	if( ${?option} ) then
		if( "${option}" == "help" ) set status=0;
	endif
	goto exit;
