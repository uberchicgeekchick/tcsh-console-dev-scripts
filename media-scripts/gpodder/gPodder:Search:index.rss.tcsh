#!/bin/tcsh -f
if ( "${?1}" != "0" && ( "${1}" == "--output" || "${1}" == "-o" ) ) then
	set output_file = "true"
	shift
endif

if ( "${?1}" == "0" || "${1}" == "" ) then
	printf "Usage:\n\t%s [-o, --output] seach_term" $0
	exit -1
endif

search:
set gpodder_dl_dir = `grep "download_dir" "${HOME}/.config/gpodder/gpodder.conf" | cut -d= -f2 | cut -d" " -f2`
foreach index ( `find "${gpodder_dl_dir}" -name index.xml` )
	set index_file = `/usr/bin/grep --perl-regexp --with-filename "${1}" "${index}" | cut -d':' -f1 | uniq`
	if ( "${index_file}" != "" && -e "${index_file}" ) then
		printf "%s\n" ${index_file}
		if ( "${?output_file}" == "1" ) then
			set files_size = `cat "${index_file}" | wc -l`
			cat "${index_file}" | /usr/bin/grep --color --line-number --context="${files_size}" "${1}"
		endif
	endif
end

shift
if ( "${?1}" != "0" && "${1}" != "" ) goto search
