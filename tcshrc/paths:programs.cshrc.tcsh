#!/bin/tcsh -f

set programs=( "/programs/bin" "/programs/Mozilla/Firefox3/x86_64" "/programs/Mozilla/Thunderbird3/x86_64" "/programs/carrier/bin" "/programs/ion/3-20080825/bin" "/programs/linphone/bin" "/programs/connectED/bin" )
set programs_path="";
foreach program ( ${programs} )
	if(! -d ${program} ) continue;
	set programs_path="${programs_path}:${program}"
end
setenv PATH "${PATH}:${programs_path}"
unset program programs programs_path

if( -d /usr/lib64/jvm/java-openjdk ) then
	setenv JAVA_HOME /usr/lib64/jvm/java-openjdk
else if( -d /usr/lib/jvm/java-openjdk ) then
	setenv JAVA_HOME /usr/lib/jvm/java-openjdk
endif

alias	thunderbird	'/programs/Mozilla/Thunderbird3/x86_64/thunderbird-bin -compose %s'

