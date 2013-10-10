# config.mk

PREFIX = /usr/local
SBINDIR = $(PREFIX)/sbin
DOCDIR = $(PREFIX)/share/doc
ETCDIR = /etc
PERP_BASE = $(ETCDIR)/perp

CC = gcc

SUPERVISORS = perp s6

STARTUP_COMMAND = "/etc/rc"
RECOVER_COMMAND = "/bin/bash"

