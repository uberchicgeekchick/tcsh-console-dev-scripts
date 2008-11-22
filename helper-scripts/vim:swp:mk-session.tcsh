#!/bin/tcsh -f
set session_exec = "vim.session"
set search_dir = "./"
if ( "${?1}" != "0" && "${1}" != "" && -d "${1}" ) set search_dir = "${1}"

printf '#\!/bin/tcsh -f\nvim-enhanced -p \n' >! "${session_exec}"
find ${search_dir} -iregex '.*\.swp$' >> "${session_exec}"
ex -s '+3,$s/\(.*\)\/\.\(.*\.opml\).swp[\r\n]\+/"\1\/\2"\ /g' '+2s/[\r\n]\+//' '+wq' "${session_exec}"
chmod +x "${session_exec}"
