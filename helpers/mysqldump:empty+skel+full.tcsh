#!/bin/tcsh
set database = "${1}"
set dir_to_dump_to = "./"

set password = ""
#printf "Please enter your MySQL password:"
#set password << "\n"

set mysql_socket = "/srv/mysql/mysql.sock"
if( ${?2} && -d "${2}" ) set dir_to_dump_to = "${2}"
set dump_types = ("empty" "skel" "full")

set mysqldump_and_options = "mysqldump --databases --comment --no-autocommit --extended-insert --socket=${mysql_socket} --routines -u${USER} -p${password}"

foreach dump_type ( ${dump_types} )
	switch(${dump_type})
	case "empty":
		${mysqldump_and_options} --no-data ${database} >! ${dir_to_dump_to}/${database}.${dump_type}.sql
		breaksw
	default:
		${mysqldump_and_options} ${database} >! ${dir_to_dump_to}/${database}.${dump_type}.sql
		breaksw
	endsw
end
