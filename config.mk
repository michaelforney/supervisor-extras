# config.mk

PREFIX = /usr/local
SBINDIR = $(PREFIX)/sbin
DOCDIR = $(PREFIX)/share/doc
ETCDIR = /etc

CC = gcc

SUPERVISORS = perp s6

STARTUP_COMMAND = "/etc/rc"
RECOVER_COMMAND = "/bin/bash"

