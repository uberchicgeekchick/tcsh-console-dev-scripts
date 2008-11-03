#ifndef _F_TWO_FEW_ARGS
#define _F_TWO_FEW_ARGS -1
#endif

#ifndef _F_INPUT_LOG
#define _F_INPUT_LOG -2
#endif


#include <stdio.h>
#include <stdlib.h>

int main(int argv, char **argc ) {
	if( argv != 2 ) {
		printf("Usage: %s [output-filename]\n", argc[0]);
		return _F_TWO_FEW_ARGS;
	}

	FILE *fp;

	if( ! (fp=fopen(argc[1], "w")) ) {
		printf( "I couldn't open the file needed to place all input.\nI tried to open: %s\n", argc[1] );
		return _F_INPUT_LOG;
	}

	char *input_string;
	input_string=malloc( (sizeof(8*1024)) );

	while( (fscanf(stdin, input_string)) )
		fprintf(fp, "%s", input_string);

	fclose(fp);

	return 0;
}
