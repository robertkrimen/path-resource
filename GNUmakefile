.PHONY: all test time clean distclean dist distcheck upload distupload

all: test

dist distclean test tardist: Makefile
	make -f $< $@

test: Makefile
	make -f $< $@
	TEST_WIN32=1 make -f $< $@

Makefile: Makefile.PL
	perl $<

clean: distclean

reset: clean
	perl Makefile.PL
	make -f Makefile test
