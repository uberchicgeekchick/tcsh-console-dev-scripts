#!/bin/tcsh
#my gnome-panel, basically, restart script.

/usr/bin/killall -9 bluetooth-applet>&/dev/null
/usr/bin/killall -9 gizmo-run>&/dev/null
/usr/bin/killall -9 gizmo-bin>&/dev/null
/usr/bin/killall -9 gizmo>&/dev/null
/usr/bin/killall -9 gnome-power-manager>&/dev/null
/usr/bin/killall -9 nm-applet>&/dev/null

/usr/bin/bluetooth-applet &
/usr/bin/gnome-power-manager &
/usr/bin/nm-applet &

#yippie Gizmo
/Progies/gizmo-project/gizmo-run &

