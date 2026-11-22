PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin

CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra
LDFLAGS ?= -static

all: hoy

hoy: src/hoy.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

install: hoy
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 hoy $(DESTDIR)$(BINDIR)/hoy

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/hoy

clean:
	rm -f hoy

.PHONY: all install uninstall clean