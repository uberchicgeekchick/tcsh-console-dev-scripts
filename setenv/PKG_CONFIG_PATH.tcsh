#!/bin/tcsh -f
set pkgconfig_path = ""
set deliminator = ""
if( -e /tmp/pkg-config.log ) rm -f /tmp/pkg-config.log
printf "Please wait while all pkgconfig directories are searched for.\nThis *will* take several minutes.\n"
( find / -type d -name pkgconfig > /tmp/pkg-config.log ) > & /dev/null
foreach pkgconfig_dir ( "`cat /tmp/pkg-config.log`" )
	set pkgconfig_path = "${pkgconfig_path}${deliminator}${pkgconfig_dir}"
	if( "${deliminator}" == "" ) set deliminator = ":"
end
rm -f /tmp/pkg-config.log

if( "${pkgconfig_path}" == "" ) exit

setenv PKG_CONFIG_PATH "${pkgconfig_path}"
printf "New PKG_CONFIG_PATH:\n\t%s\n" "${pkgconfig_path}"
