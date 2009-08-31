#!/bin/tcsh
set projects_name = "Lightning";
set projects_version = "Nightly-Build";

set dl_dir = "/home/uberchicgeekchick/Downloads/Mozilla/Nightly-Builds";
set tb_profile_dir = "/home/uberchicgeekchick/Settings/Mozilla/thunderbird/Profiles/uberChicGeekChick";

set extensions_subdir = "extensions/{e2fda1a4-762b-4020-b5ad-a41df1933103}";
set projects_xpi = "lightning.xpi";
set dl_URI = "http://ftp.mozilla.org/pub/mozilla.org/calendar/lightning/nightly/latest-trunk/linux-xpi/${projects_xpi}";


cd "${dl_dir}";
printf "Please wait while I download %s's latest %s\n\t" $projects_name $projects_version;
wget --quiet "${dl_URI}";

if( ! ( -e "${projects_xpi}.1" ) ) then
	printf "\a[ failed ]\n";
	exit -1;
endif

printf "[ done ]\n\nPlease wait while I install %s's latest %s\n\t" $projects_name $projects_version;

mv --force "${projects_xpi}.1" "${projects_xpi}";

cd "${tb_profile_dir}/${extensions_subdir}";
unzip -o --qq "${dl_dir}/${projects_xpi}";
printf "[ done ]\n\n\t\t(^_^) Have fun girl! (^_^)\n";
