#!/bin/tcsh -f
set projects_dir="/projects";

switch ( "${1}" )
case "--editor=gedit":
case "--editor=connectED":
	shift;
	set my_editor = "${1}"
	breaksw
case "--editor=vi":
case "--editor=vim":
case "--editor=vim-enhanced":
	shift;
	set my_editor = `printf "%s -p" "vim-enhanced"`
	breaksw
default:
	set my_editor = `printf "%s -p" "vim-enhanced"`
	breaksw
endsw

cd "${projects_dir}";

if( ${?1} && "${1}" != "" && -d "${1}" ) then
	cd "${1}"
	${my_editor} */ChangeLog
else
	${my_editor} */*/ChangeLog
endif
