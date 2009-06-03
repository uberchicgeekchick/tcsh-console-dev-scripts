#!/bin/tcsh -f
set search_dir = "./"
set my_editor = "`printf '${0}' | sed 's/.*\/\([^:]\+\).*/\1/g'`"

while ( ${?1} && "${1}" != "" )
	switch ( "${1}" )
	case -d:
		set search_dir = "${1}"
		breaksw
	
	case "--clean-up":
		set clean_up
		breaksw
	
	default:
		set my_editor = "${1}"
		breaksw
	endsw
	shift
end

foreach editor ( "`where '${my_editor}'`" )
	if( ! -e "${my_editor}" ) then
		set my_editor = "${editor}"
	endif
end
if ( ! -e ${my_editor} ) set my_editor = "${EDITOR}"

set my_editor = `basename "${my_editor}"`

set session_exec = "./${my_editor}.session.tcsh"

foreach swp ( "`find ${search_dir} -iregex '\..*\.\(sw.\|~\)' | sort`" )
	if ( ! ${?session_started} ) then
		set session_started
		#this has vim load with the cursur on the second to last line.
		#this is really helpful while editing xml files. I'll make this optional later.
		printf '#\!/bin/tcsh -f\nset my_editor = "`printf "\\""${0}"\\"" | sed '\''s/.*\/\([^\.]\+\).*/\\1/g'\''`"\nswitch ( "${my_editor}" )\ncase "connectED":\ncase "gedit":\n\tbreaksw\ncase "vi":\ncase "vim":\ncase "vim-enhanced":\ndefault:\n\tset my_editor = `printf "%%s -p" "vim-enhanced"`\n\tbreaksw\nendsw\n\n${my_editor}' >! "${session_exec}"
	endif
	set file = "`echo ${swp} | sed 's/\/\.\(.*\)\.\(sw.\|~\)/\/\1/g'`"
	
	printf " %s${file}%s" '"' '"' >> "${session_exec}"
	if ( ${?clean_up} ) rm "${swp}"
end

if ( ! ${?session_started} ) exit

printf "\n" >> "${session_exec}"
chmod +x "${session_exec}"

