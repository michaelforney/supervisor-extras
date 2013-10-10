# Makefile

include config.mk

SUPERVISOR_INSTALL_TARGETS = $(patsubst %,install-%,$(SUPERVISORS))

all: init

init.o: init.c
	$(CC) $(CFLAGS) \
		-DSTARTUP_COMMAND=\"$(STARTUP_COMMAND)\" \
		-DRECOVER_COMMAND=\"$(RECOVER_COMMAND)\" \
		-c -o $@ $<

init: init.o
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f init init.o

install-perp:
	mkdir -p $(DESTDIR)$(ETCDIR)/perp/.default
	cp -f perp/rc.log $(DESTDIR)$(ETCDIR)/perp/.default
	cp -f perp/getty-rc.main $(DESTDIR)$(ETCDIR)/perp/.default

install-s6:
	mkdir -p $(DESTDIR)$(ETCDIR)/s6/.default
	cp -f s6/log-run $(DESTDIR)$(ETCDIR)/s6/.default
	cp -f s6/getty-run $(DESTDIR)$(ETCDIR)/s6/.default

install: all $(SUPERVISOR_INSTALL_TARGETS)
	mkdir -p $(DESTDIR)$(SBINDIR)
	cp -f init reboot poweroff $(DESTDIR)$(SBINDIR)
	mkdir -p $(DESTDIR)$(ETCDIR)
	cp -f rc rc.local $(DESTDIR)$(ETCDIR)
	mkdir -p $(DESTDIR)$(DOCDIR)
	cp -f rc.conf.sample.perp rc.conf.sample.s6 $(DESTDIR)$(DOCDIR)

.PHONY: all clean install $(SUPERVISOR_INSTALL_TARGETS)

