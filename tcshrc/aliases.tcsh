#!/bin/tcsh -f
if(! ${?TCSH_RC_SESSION_PATH} ) \
	setenv TCSH_RC_SESSION_PATH "/projects/cli/console.pallet/tcshrc";

source "${TCSH_RC_SESSION_PATH}/argv:check" "aliases.tcsh" ${argv};

if( $args_handled > 0 ) then
	@ args_shifted=0;
	while( $args_shifted < $args_handled )
		@ args_shifted++;
		shift;
	end
	unset args_shifted;
endif
unset args_handled;

alias			set-alias	"source "\$"{TCSH_RC_SESSION_PATH}/../setenv/set-alias.tcsh";


complete		alias		'p/1/c/' 'p/2,/c,f/';
complete		set-alias	'p/1/c/' 'p/2,/c,f/';

set-alias		"feed:fetch-all:enclosures.tcsh" "${TCSH_RC_SESSION_PATH}/../xml-parsers/feed:fetch-all:enclosures.tcsh --disable=logging"
set-alias		most	"most -w";

set-alias		bc	"bc -q";

set-alias		ps	"/bin/ps -A -c -F --forest --heading";
set-alias		ps-g	"/bin/ps -A -c -F --forest --heading | egrep";

set-alias		ln	"ln --interactive";

set-alias		df	"df --human-readable";
set-alias		du	"du --summarize --human-readable";
set-alias		du-a	"du ./*";

set-alias		rd	rmdir;

set-alias		rm	"rm --verbose";
set-alias		rr	"rm --recursive";
set-alias		rf	"/bin/rm --recursive --force";

set-alias		pidof	"pidof -x";
complete		pidof	'p/*/c/';

#set-alias		cp	"cp --recursive --verbose -p --no-dereference --interactive";
#set-alias		cp	"cp --recursive --verbose -p --no-dereference";
#set-alias		cp	"cp -rvpP";
set-alias		cp	"cp -vp";

#set-alias		mv	"mv -iv";
set-alias		mv	"mv --interactive --verbose";

set-alias		mkdir	"mkdir -p";
set-alias		md	"mkdir";

set-alias		nautilus	"nautilus --geometry=800x700 --no-desktop --browser";

set-alias		hostname	"hostname --fqdn";
set-alias		wget		"wget --no-check-certificate";
set-alias		curl		"curl --location --fail --show-error --remote-name-all";
set-alias		shasum		"shasum --algorithm 512";

set-alias		screen-saver	"gnome-screensaver-command --activate &";
set-alias		unzip		"unzip -o -q";
set-alias		ispell		"aspell -a --sug-mode=normal";

set-alias		alsamixer	"alsamixer -V all";

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "aliases.tcsh";

