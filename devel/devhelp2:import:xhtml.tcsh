#!/bin/tcsh -f
if ( ! ( ${?1} && -d "${1}" ) ) goto usage_error

usage_error:
printf "Usage: %s manual path toc index\n\n\tmanual\t\tThe name\n\n\tpath\t\tthe location of manual to create a devhelp entry for.\n\n\ttoc\t\tTable of Contents\n\n\tindex\t\tThe manual's index listing functions, properties, and etc.\n" "`basename '${0}'`"
