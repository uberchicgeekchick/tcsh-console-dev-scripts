#!/bin/tcsh -f
if(! ( ${?1} && "${1}" != "" ) ) then
	echo "Usage: `basename ${0}` [pkg-config packages]"
endif


set PACKAGES="${1}"
foreach package_dir ( `pkg-config --cflags "${PACKAGES}" | sed 's/^\([^\ ]\)/\ \1/g' | sed 's/\ \-[^I][^\ ]\+//g' | sed 's/\ \-I\(\/[^\ ]\+\)/\ \1/g'`)
	if(! ${?isystem} ) set isystem="";
	set isystem="${isystem} -isystem ${package_dir}";
	foreach include_dir ( `find "${package_dir}" -type d` )
		set isystem="${isystem} -isystem ${include_dir}";
	end
end
if( ${?include_dir} && "$include_dir" != "" ) unset $include_dir;
unset packages_dirs

set extra_cflags=`pkg-config --cflags "${PACKAGES}" | sed 's/^\([^\ ]\)/\ \1/g' | sed 's/\ \-I\/[^\ ]\+//g'`
if( "${extra_cflags}" != "" ) then
	if(! ${?isystem} ) then
		set isystem="${extra_cflags}";
	else
		set isystem="${extra_cflags}${isystem}";
	endif
endif
unset extra_cflags

if( ${?isystem} ) then
	setenv CFLAGS_ISYSTEM "${isystem}";
	unset isystem
	echo "${CFLAGS_ISYSTEM}"
endif

