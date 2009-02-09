#!/bin/tcsh -f
cd "/programs/Mozilla";

if ( "${?GREP_OPTIONS}" == "1" ) unsetenv GREP_OPTIONS

if ( ! -d "src" ) mkdir "src"
cd src/

switch ( "${1}" )
case "firefox":
	set build_mozilla="firefox";
	set mercurial_repo="mozilla-central"
	breaksw
case "thunderbird":
default:
	set build_mozilla="thunderbird";
	set mercurial_repo="comm-central"
	breaksw
endsw

if ( ! -d "src/${build_mozilla}-src" ) then
	hg clone "http://hg.mozilla.org/${mercurial_repo}/" "${build_mozilla}-src"
else
	cd "${build_mozilla}-src"
	hg up
	cd ..
endif

cd "${build_mozilla}-src"
if ( ! -e ".mozconfig" ) then
	
	switch ( "${build_mozilla}" )
	case "firefox":
		set enable_mozilla="--enable-application=browser"
		breaksw
	case "thunderbird":
	default:
		set enable_mozilla="--enable-application=mail --enable=calendar"
		breaksw
	endsw
	
	printf "ac_add_options ${enable_mozilla} --enable-installer --disable-pedantic --enable-static --disable-shared --enable-optimize --enable-default-toolkit=cairo-gtk2 --disable-tests --disable-mochitest\nmk_add_options MOZ_OBJDIR=@TOPSRCDIR@/../${object_dir_ext}-objdir\nmk_add_options AUTOCONF=autoconf-2.13\n" > ".mozconfig"
endif

if ( -e client.py ) python client.py checkout

make -f client.mk build

cd "../${build_mozilla}-objdir"

make package

cp mozilla/dist/${build_mozilla}*.tar.bz2 /uberChick/Downloads/Mozilla/Nightly-Builds/

