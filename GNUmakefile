.PHONY: all test time clean distclean dist build distcheck

all: test

build: Build
	./$<

distcheck dist distclean test tardist: Build
	./Build $@

Build: Build.PL
	perl $<

clean: distclean

time:
#	perl -mlib=$(DVL_HOME)/lib -T -d:DProf t/01-PL-new-set.t 

