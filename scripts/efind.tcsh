#!/bin/tcsh

	#if ( ! ( ${?1} && ${2} ) ) then
	#	echo "usage: efind path extendRegularExpression\nruns: find "'"path"'" --regextype posix-extended --regexp "'"extendRegularExpression"'
	#	exit -1
	#endif

	find '${1}' -regextype posix-extended -regex '${2}'

