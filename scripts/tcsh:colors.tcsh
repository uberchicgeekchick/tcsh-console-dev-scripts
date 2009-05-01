#/bin/tcsh -f
@ colour=0;
while( $colour < 48 )
	printf "%%{^[[${colour}m%%}[ %%n@%%m ]%%{^[[0m%%}\n";
	@ colour++;
end
