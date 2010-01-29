subdir=.
SUBDIRS=data po php scripts src

all-recursive install-recursive uninstall-recursive distclean-recursive clean-recursive:
	@failcom='exit 1'; \
	for f in x $$MAKEFLAGS; do \
	case $$f in \
	*=* | --[!k]*);; \
	*k*) failcom='fail=yes';; \
	esac; \
	done; \
	target=`echo $@ | sed s/-recursive//`; \
	list='$(SUBDIRS)'; for subdir in $$list; do \
	echo "Making $$target in $$subdir"; \
	(cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) $$target) \
	|| eval $$failcom; \
	done; \
	test -z "$$fail"

all: all-recursive
install: install-recursive
uninstall: uninstall-recursive
clean: clean-recursive
distclean: distclean-recursive
