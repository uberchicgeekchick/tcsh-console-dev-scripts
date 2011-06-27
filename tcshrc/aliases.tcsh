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

if(! ${?TCSH_RC_DEBUG} ) then
	set set_alias_args;
else
	set set_alias_args=" --debug";
endif

alias set-alias "source "\$"{TCSH_RC_SESSION_PATH}/../setenv/set-alias.tcsh${set_alias_args}";


complete alias 'p/1/c/' 'p/2-/c/';
complete set-alias 'p/1/c/' 'p/2-/c/';

set-alias "feed:fetch:enclosures.tcsh" "${TCSH_RC_SESSION_PATH}/../xml-parsers/feed:fetch:enclosures.tcsh --disable=logging";
#set-alias "feed:fetch:enclosures:latest.tcsh" "feed:fetch:enclosures.tcsh --download-limit=1";
#set-alias "feed:fetch:enclosures:latest:podiobooks.com.tcsh" "feed:fetch:enclosures.tcsh --start-with=2 --download-limit=1";

set-alias "most" "most -w";
set-alias "tiv" "/programs/bin/tiv -p";

set-alias bc "bc -q";

set-alias ps "/bin/ps -A -c -F --forest";
set-alias ps-g "/bin/ps -A -c -F --forest --heading | egrep";

set-alias df "df --human-readable";
set-alias du "du --summarize --human-readable";
set-alias du-a "du ./*";

set-alias rd "rmdir -v";

set-alias rm "rm --verbose";
set-alias rr "rm --recursive";
#set-alias rf "/bin/rm --recursive --force";
set-alias rf "/bin/rm --recursive";

set-alias pidof "pidof -x";
complete pidof 'p/*/c/';

#set-alias cp "cp -iPprv";
#set-alias cp "cp --interactive --no-dereference --preserve=all --recursive --verbose";
#set-alias cp "cp -iPpv";
#set-alias cp "cp --interactive --no-dereference --preserve=all --verbose";
#set-alias cp 'cp --dereference --perserve=mode,ownership,timestamps --verbose';
set-alias cp 'cp -Lpv';

#set-alias mv "mv -iv";
set-alias mv "mv --interactive --verbose";

#set-alias ln "ln -iv";
set-alias ln "ln --interactive --verbose";

set-alias mkdir "mkdir -v";
set-alias md "mkdir -p";

set-alias nautilus "nautilus --geometry=800x700 --no-desktop --browser";

set-alias hostname "hostname --fqdn";
set-alias wget "wget --no-check-certificate";
set-alias curl "curl --location --fail --show-error --remote-name-all";
set-alias shasum "shasum --algorithm 512";

set-alias screen-saver "gnome-screensaver-command --activate &";
set-alias unzip "unzip -o -q";
set-alias aspell "aspell -a --sug-mode=normal";
set-alias ispell "aspell";

set-alias alsamixer "alsamixer -V all";

if( "${set_alias_args}" != "" ) \
	alias set-alias "source "\$"{TCSH_RC_SESSION_PATH}/../setenv/set-alias.tcsh";
unset set_alias_args;

source "${TCSH_RC_SESSION_PATH}/argv:clean-up" "aliases.tcsh";

