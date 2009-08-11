#!/bin/tcsh -f

set programs=( "/programs/bin" "/programs/Mozilla/Firefox3/x86_64" "/programs/Mozilla/Thunderbird3/x86_64" "/programs/carrier/bin" "/programs/ion/3-20080825/bin" "/programs/linphone/bin" "/programs/connectED/bin" )
foreach program ( ${programs} )
	if(! -d ${program} ) continue;
	set program_test="`printf '${program}' | sed 's/\//\\\//g'`"
	if ( "`echo '${PATH}' | sed 's/.*:\(${program_test}\).*/\1/'`" == "${program_test}" ) continue
	setenv PATH "${PATH}:${program}"
end
unset program programs

if( -d /usr/lib64/jvm/java-openjdk ) then
	setenv JAVA_HOME /usr/lib64/jvm/java-openjdk
else if ( -d /usr/lib/jvm/java-openjdk ) then
	setenv JAVA_HOME /usr/lib/jvm/java-openjdk
endif

alias	thunderbird	'/programs/Mozilla/Thunderbird3/x86_64/thunderbird-bin -compose %s'

