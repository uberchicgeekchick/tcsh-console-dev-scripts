#!/bin/tcsh -f

if( ! "${?1}" ) then
	printf "Usage:\n\t${0} program\n\tprogram, program-bin, & program-run will all be interupted."
	exit -1;
endif

foreach program ( "${1}" "${1}-bin" "${1}-run" )
	foreach pid(`/bin/ps -A -c -F | /bin/grep --perl-regexp "^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ ${program}" | sed -r 's/^[0-9]+[\\ ]+([0-9]+).*[\r\n]*/\1/'`)
		if(! ${?found_pids} ) \
			set found_pids;
		printf "Please be patient:\n\tInterupting ${program} ( pid: ${pid} )"
		@ pauses=0;
		while ( $pauses < 10 )
			@ pauses++;
			kill -INT "${pid}"
			set pid_test = `ps -A | grep "${pid}"`
			if( "${pid_test}" == "" ) then
				printf "[done]\n${program}, pid ${pid}, has exited."
				break;
			endif

			printf "."
			sleep 1
		end
		printf "[finished]\n\t${program}, pid: ${pid}, may still be running.\n\tHopefully its responding.\n\tIf not you may want to run: `kill_program.tcsh`";
	end
end
	if(! ${?found_pids} ) \
		printf "${program} is not running.\n";
