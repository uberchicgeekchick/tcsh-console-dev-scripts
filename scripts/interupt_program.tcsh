#!/bin/tcsh

if( ! "${?1}" ) then
	printf "Usage:\n\t${0} program\n\tprogram, program-bin, & program-run will all be interupted."
	exit -1;
endif

set found_pids = "false";

foreach program ( `echo "${1}\n${1}-bin\n${1}-run"` )
	set found_pids = "false";
	foreach pid ( `/bin/pidof -x "${program}"` )
		set found_pids = "true";
		printf "I'm trying to interupt ${program}, PID: ${pid}.\nPlease wait a few moments"
		foreach pause ( `printf ".\n.\n.\n.\n.\n.\n.\n.\n.\n."` )
			kill -INT "${pid}"
			set pid_test = `ps -A | grep "${pid}"`
			if( "${pid_test}" == "" ) then
				printf "\n${program}, PID ${pid}, has exited."
				exit 0;
			endif

			printf "${pause}"
			sleep 1
		end
		printf "\n\t${program}, PID: ${pid}, may still be running.\n\tHopefully its responding.  If not you may want to run: `kill_program.tcsh`";
	end
	if( "${found_pids}" == "false" ) printf "${program} is not running.\n";
end
