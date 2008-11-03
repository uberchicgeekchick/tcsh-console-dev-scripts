#!/bin/tcsh
/usr/bin/sudo /etc/init.d/alsasound restart>&/dev/null
/usr/bin/killall -9 gnome-volume-control>&/dev/null
/usr/bin/gnome-volume-control>&/dev/null &
