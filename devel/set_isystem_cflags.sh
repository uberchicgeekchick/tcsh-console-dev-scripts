#!/bin/sh -f
if `test "$1" == ""`; then
	echo "Usage: `basename ${0}` [pkg-config packages]"
fi

PACKAGES="${1}"

packages_dirs=`pkg-config --cflags "${PACKAGES}" | sed 's/^\(.\)/\ \1/g' | sed 's/\ \-[^I][^\ ]\+//g' | sed 's/\ \-I\(\/[^\ ]\+\)/\ \1/g'`
isystem="";
for package_dir in ${packages_dirs} 
do
	isystem="${isystem} -isystem ${package_dir}";
	for include_dir in `find ${package_dir} -type d`
	do
		isystem="${isystem} -isystem ${include_dir}";
	done
done

extra_cflags=`pkg-config --cflags "${PACKAGES}" | sed 's/^\([^\ ]\)/\ \1/g' | sed 's/\ \-I\/[^\ ]\+//g'`
if `test "${extra_cflags}" != ""`; then
	if `test "${isystem}" == ""`; then
		isystem="${extra_cflags}";
	else
		isystem="${extra_cflags}${isystem}";
	fi
fi
unset extra_cflags


if `test "$isystem" != ""`; then
	if `test "$CFLAGS_ISYSTEM" != ""`; then
		export CFLAGS_ISYSTEM="$isystem";
	else
		export CFLAGS_ISYSTEM="$CFLAGS_ISYSTEM$isystem"
	unset isystem
	echo "$CFLAGS_ISYSTEM"
fi

if `test "$include_dir" != ""`; then unset include_dir; fi
unset packages
unset package_dirs
unset packages_dir

