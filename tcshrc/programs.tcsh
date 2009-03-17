#!/bin/tcsh -f
set programs=( "/programs/bin" "/programs/Mozilla/Firefox3/x86_64" "/programs/Mozilla/Thunderbird3/x86_64" "/programs/carrier/bin" "/programs/ion/3-20080825/bin" "/programs/linphone/bin" )
foreach program ( ${programs} )
	if(! -d ${program}" ) continue;
	set program_test="`printf '${program}' | sed 's/\//\\\//g'`"
	if ( "`echo '${PATH}' | /usr/bin/sed 's/.*:\(${program_test}\).*/\1/'`" == "${program_test}" ) continue
	setenv PATH "${PATH}:${program}"
end
setenv JAVA_HOME /usr/lib64/jvm/java-openjdk
unset program programs
