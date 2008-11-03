#!/bin/tcsh

set killedProgies = "false";
set lastKilledProgie = "null";

foreach progiesName ( `echo "${1}-bin\n${1}-run\n${1}"` )
	foreach progiesPID ( `pidof -x ${progiesName}` )
		if ( ${?progiesPID} ) then
			if ( ${progiesPID} ) then
				
				if ( "${killedProgies}" == "false" ) set killedProgies = "true";

				if ( "${lastKilledProgie}" != "${progiesName}" ) then
					echo "Please wait while all instances of ${progiesName} are stopped:"
					set lastKilledProgie = "${progiesName}";
				endif
				
				kill -QUIT ${progiesPID}
				echo -n "\tTrying to stop PID ${progiesPID}"
				foreach a ( `echo ".\n.\n.\n.\n"` )
					echo -n "."
					/bin/sleep 1
				end
				
				set swordOfNines = "false";
				
				foreach progiesTestPID ( `pidof -x ${progiesName}` )
					if ( ${?progiesTestPID} ) then
						if ( ${progiesTestPID} == ${progiesPID} ) then
							set swordOfNines = "true";
							echo "\nI couldn't get ${progiesName} ( process #${progiesTestPID} ( ${progiesName} ) to exit.\n\tSo I'm gonna have to force it to quit instead.\n"
							kill -9 ${progiesTestPID}
						endif
					endif
				end
				
				if ( "${swordOfNines}" == "false" ) echo "\t\tdone"
			endif
		endif
	end
end

if ( "${killedProgies}" == "false" ) echo "${progiesName} isn't running."
