#!/bin/tcsh -f
set online_desktop_checkout = "${HOME}/Downloads/OnlineDesktop"
set online_desktep_install = "/programs/OnlineDesktop/install"

if ( ! -d "${online_desktop_checkout}" ) mkdir -p "${online_desktop_checkout}"
cd "${online_desktop_checkout}"
mkdir checkout
mkdir -p install/var/lib/dbus
ln -s /var/lib/dbus/machine-id install/var/lib/dbus/
