#!/bin/tcsh -f
set gPodders_prefix = "/usr"

rm -rf ${gPodders_prefix}/share/gpodder ${gPodders_prefix}/share/pixmaps/gpodder* ${gPodders_prefix}/share/applications/gpodder.desktop ${gPodders_prefix}/share/man/man1/gpodder.1 ${gPodders_prefix}/bin/gpodder ${gPodders_prefix}/lib*/python?.?/site-packages/gpodder* ${gPodders_prefix}/share/locale/*/LC_MESSAGES/gpodder.mo

#My hack to add 64bit uninstall support & to remove gpodder-*-py2.5.egg-info
rm -rf ${gPodders_prefix}/lib*/python?.?/site-packages/gpodder* >2 /dev/null

