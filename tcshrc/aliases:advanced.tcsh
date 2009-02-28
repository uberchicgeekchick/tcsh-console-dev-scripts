#!/usr/tcsh -f
alias startx 'if ( ! -x /usr/bin/startx ) echo "No startx installed";\
	if (   -x /usr/bin/startx ) /usr/bin/startx |& tee ${HOME}/.xsession-error'

#alias make 'if ( "${?GREP_OPTIONS}" == "1" ) then\
#	set grep_options="${GREP_OPTIONS}";\
#	unsetenv $GREP_OPTIONS;\
#	make;\
#	setenv GREP_OPTIONS "${grep_options}";\
#else\
#	make\
#endif'

