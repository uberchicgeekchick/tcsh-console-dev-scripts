#!/bin/tcsh -f
if( ${?0} ) then
	printf "This script is only useful when sourced from within tcsh.\n";
	exit -1;
endif


if( "${1}" != "--reset" ) then
	setenv MANPATH "/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/share/doc/packages/slang-devel/examples/slsh/doc/man:/usr/share/doc/packages/pyxml/doc/man:/programs/linphone/share/man:/programs/ion/3-20080825/share/man:/programs/mozilla/src/firefox-srcdir/js/ctypes/libffi/man:/programs/mozilla/src/thunderbird-srcdir/mozilla/js/ctypes/libffi/man:/programs/carrier/share/man:/programs/anjuta/share/man:/programs/src/HandBrake-0.9.4/build/contrib/lame/lame/doc/man:/programs/src/HandBrake-0.9.4/build/contrib/mp4v2/mp4v2-trunk-r355/doc/man:/programs/src/HandBrake-0.9.4/build/contrib/man:/programs/src/HandBrake-0.9.4/build/contrib/share/man:/programs/share/man:/programs/share/share/man";
	exit 0;
endif

	set dirs=("/usr" "/programs");
	foreach dir( ${dirs} )
		foreach man_dir("`/usr/bin/find -H /programs/ -iregex '.*[^\/][^\.].*\/man$' -type d`")
			set escaped_man_dir="`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/([\/\.\+])/\\\1/g'`";
			if("`printf "\""%s"\"" "\""${PATH}"\"" | sed -r 's/.*\:?(${escaped_man_path})\:?.*/\1/'`" != "${man_path}" ) \
				setenv "${PATH}:${man_path}";
		end
	end

