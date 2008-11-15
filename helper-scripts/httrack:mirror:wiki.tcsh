#!/bin/tcsh
set top_uri = `dirname ${1}`
set project_name = "`basename ${top_uri} | sed 's/_/\ /g'`"
httrack ${1} -O ${project_name} --stay-on-same-address --stay-on-same-dir --search-index --cookies=1 +${top_uri}*"
