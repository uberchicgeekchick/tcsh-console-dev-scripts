#!/usr/tcsh -f
alias startx 'if ( ! -x /usr/bin/startx ) echo "No startx installed";\
	if (   -x /usr/bin/startx ) /usr/bin/startx |& tee ${HOME}/.xsession-error'

