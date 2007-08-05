.PHONY: all test time clean distclean dist build distcheck

all: test

build: Build
	./$<

distcheck dist distclean test tardist: Build
	./Build $@

Build: Build.PL
	perl $<

clean: distclean
