#!/bin/tcsh -f
cd "`dirname '${0}'`"

/programs/connectED/bin/connectED &
/programs/mozilla/firefox/x86_64/firefox -P uberChick &

