#!/bin/sh
if ! test -e "/var/tmp/cronlog-${USER}"; then
	touch "/var/tmp/cronlog-${USER}";
fi
printf "\n\nRunning xsession-errors clean-up script @ %s.\n" "`date '+%c'`" >> "/var/tmp/cronlog-${USER}";

if test -f "${HOME}/.xsession-errors"; then
	ex -E -n -X --noplugin '+0,$d' '+wq!' -V0"/var/tmp/cronlog-${USER}" "${HOME}/.xsession-errors" >> "/var/tmp/cronlog-${USER}" 2>> "/var/tmp/cronlog-${USER}";
fi

if test -f "${HOME}/.xsession-errors.old"; then
	rm -fv "${HOME}/.xsession-errors.old" >> "/var/tmp/cronlog-${USER}" 2>> "/var/tmp/cronlog-${USER}";
fi

if test "${USER}" == "uberChick"; then
	exit;
fi

if ! test -e "/var/tmp/cronlog-uberChick"; then
	touch "/var/tmp/cronlog-uberChick";
fi

printf "\n\nRunning xsession-errors clean-up script.\n" >> "/var/tmp/cronlog-uberChick";

if test -f "/uberChick/.xsession-errors"; then
	ex -E -n -X --noplugin '+0,$d' '+wq!' -V0"/var/tmp/cronlog-uberChick" "/uberChick/.xsession-errors" >> "/var/tmp/cronlog-uberChick" 2>> "/var/tmp/cronlog-uberChick";
fi

if test -f "/uberChick/.xsession-errors.old"; then
	rm -fv "/uberChick/.xsession-errors.old" >> "/var/tmp/cronlog-uberChick" 2>> "/var/tmp/cronlog-uberChick";
fi


