#/bin/tcsh -f
@ colour=0;
while( $colour < 48 )
	printf "%%{^[[%s%%}[ %%n@%%m ]%%{^[[0m%%}\n" "${colour}m";
	@ colour++;
end
