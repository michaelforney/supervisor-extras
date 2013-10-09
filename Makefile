# Makefile

PREFIX = /usr/local
SBINDIR = $(PREFIX)/sbin
ETCDIR = /etc
CC = gcc

SUPERVISORS = perp s6
SUPERVISOR_INSTALL_TARGETS = $(patsubst %,install-%,$(SUPERVISORS))

all: init

init.o: init.c
	$(CC) $(CFLAGS) -c -o $@ $<

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
	cp -f init $(DESTDIR)$(SBINDIR)
	mkdir -p $(DESTDIR)$(PREFIX)$(ETCDIR)
	cp -f rc rc.local $(DESTDIR)$(ETCDIR)

.PHONY: all clean install $(SUPERVISOR_INSTALL_TARGETS)

