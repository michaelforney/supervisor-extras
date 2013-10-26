# Makefile

include config.mk

SUPERVISOR_INSTALL_TARGETS = $(SUPERVISORS:%=install-%)
RC_LOCAL_SCRIPTS := \
    hostname.sh     \
    keymap.sh       \
    sysctl.sh       \

ifeq ($(ENABLE_UDEV), 1)
RC_LOCAL_SCRIPTS += udev.sh
endif

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
	mkdir -p $(DESTDIR)$(PERP_BASE)/.boot
	cp -f perp/boot/rc.perp $(DESTDIR)$(PERP_BASE)/.boot/rc.perp
	cp -f perp/boot/rc.log $(DESTDIR)$(PERP_BASE)/.boot/rc.log
	mkdir -p $(DESTDIR)$(PERP_BASE)/.default
	cp -f perp/default/rc.log $(DESTDIR)$(PERP_BASE)/.default
	mkdir -p $(DESTDIR)$(PERP_BASE)/.getty
	cp -f perp/getty/rc.main $(DESTDIR)$(PERP_BASE)/.getty
	mkdir -p -m +t $(DESTDIR)$(PERP_BASE)/getty@tty1
	ln -s ../.getty/rc.main $(DESTDIR)$(PERP_BASE)/getty@tty1

install-s6:
	mkdir -p $(DESTDIR)$(ETCDIR)/s6/.default
	cp -f s6/log-run $(DESTDIR)$(ETCDIR)/s6/.default
	cp -f s6/getty-run $(DESTDIR)$(ETCDIR)/s6/.default

install: all $(SUPERVISOR_INSTALL_TARGETS)
	mkdir -p $(DESTDIR)$(SBINDIR)
	cp -f init reboot poweroff $(DESTDIR)$(SBINDIR)
	mkdir -p $(DESTDIR)$(ETCDIR)
	cp -f rc rc.local $(DESTDIR)$(ETCDIR)
	mkdir -p $(DESTDIR)$(ETCDIR)/rc.local.d
	cp -f $(addprefix rc.local.d/,$(RC_LOCAL_SCRIPTS)) \
	    $(DESTDIR)$(ETCDIR)/rc.local.d
	mkdir -p $(DESTDIR)$(DOCDIR)
	cp -f rc.conf.sample.perp rc.conf.sample.s6 $(DESTDIR)$(DOCDIR)

.PHONY: all clean install $(SUPERVISOR_INSTALL_TARGETS)

