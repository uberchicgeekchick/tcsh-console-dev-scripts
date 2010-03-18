#!/bin/tcsh -f
if( ! ( -d "./raydium" && - "./libraydium.a" - "./libraydium.so" )  ) then
	printf "I was unable to find "
	exit
endif
set program = `echo "${1}" | sed '+s/\.c//'`
if( ! ${?OCOMP_FLAGS} ) setenv OCOMP_FLAGS ""

gcc -g "${1}" -Wall -o "${program}" -L/usr/X11R6/lib/ -lXinerama -lGL -lGLU -lm -lopenal -lalut -ljpeg \
	-Iraydium/ode/include/ raydium/ode/ode/src/libode.a -lvorbis -lvorbisfile -logg \
	-Iraydium/php/ -Iraydium/php/include -Iraydium/php/main/ -Iraydium/php/Zend -Iraydium/php/TSRM \
	-I/usr/include/curl -I/usr/include \
	raydium/php/libs/libphp5.a \
	-lresolv -lcrypt -lz -lcurl -lxml2 -lGLEW -lcal3d ${OCOMP_FLAGS}
sync
shift
if( -x ./$program ) `"./${program}" "${argv}"`

