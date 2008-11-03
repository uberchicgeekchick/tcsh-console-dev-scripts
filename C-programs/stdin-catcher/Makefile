SHELL = /bin/tcsh

install:
	gcc -Wall -o stdin-catcher stdin-catcher.c

test:
	if( !-x ./input-catcher ) install:
	echo "Testing input-catcher" | ./stdin-catcher test.log
	cat test.log
	rm test.log

clean:
	rm -f stdin-catcher test.log
