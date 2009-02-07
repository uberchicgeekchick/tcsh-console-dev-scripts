#!/bin/tcsh -f
cd "`dirname '${0}'`"

/programs/connectED/bin/connectED &
/programs/Mozilla/Firefox/64bit/nightly-builds/firefox -P KaityGB &

