#!/bin/tcsh -f
if ( ! ( "${?1}" == "1" && -d "${1}" ) ) goto usage_error

usage_error:
printf "Usage: %s manual path toc index\
	\
	manual		The name \
	\
	path		the location of manual to create a devhelp entry for.\
	\
	toc		Table of Contents\
	\
	index		The manual's index listing functions, properties, and etc.\n" "`basename '${0}'`"
