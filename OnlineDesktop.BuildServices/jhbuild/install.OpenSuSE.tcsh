#!/bin/tcsh -f
cd /programs/src/OnlineDesktop
svn co http://svn.gnome.org/svn/jhbuild/trunk jhbuild
cd jhbuild
./autogen.sh --prefix /programs/OnlineDesktop
make
make install
rehash
jhbuild -m bootstrap buildone automake-1.4 automake-1.7 automake-1.8 automake-1.9 python waf libtool
jhbuild build
