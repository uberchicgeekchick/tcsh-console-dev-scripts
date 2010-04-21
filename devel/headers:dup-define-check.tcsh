#!/bin/tcsh -f
if( "${1}" != "" && -d "${1}" ) cd "${1}";

alias egrep 'grep --binary-files=without-match --color --with-filename --line-number --initial-tab --no-messages --perl-regexp';

set keywords=( "ifndef" "define" );
foreach keyword( ${keywords} )
	set duplicate_files=();
	foreach h ( *.h )
		set define="`egrep '#${keyword}[\ \t]+__[A-Z_]+_H__' '${h}' | sed -r 's/.*#${keyword}[\ \t]+(.*)"\$"/\1/'`";
		set define_egrep="`egrep '#${keyword}[\ \t]+${define}' *.h | sed -r 's/(.*)[\ \t]*:[\ \t]*[0-9]+.*/\1/'`";
		if(!( ${#define_egrep} > 1 )) continue;
		foreach dup_h ( ${duplicate_files} )
			if( "${dup_h}" != "${h}" ) unset dup_h;
		end
		if( ${?dup_h} ) continue;
		printf "#%s %s's is processed multiple times.\nIn the following header files:" "${keyword}" "${define}";
		@ duplicate_defines=0;
		foreach h ( ${define_egrep} )
			if( ${duplicate_defines} > 0 ) printf "\n\t\tand";
			printf "\n\t<%s>" "${h}";
			set duplicate_files=( ${duplicate_files} "${h}" );
			@ duplicate_defines++;
		end
		printf "\n\n";
	end
end

