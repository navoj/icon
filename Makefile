#  Makefile for Version 9.4 of Icon
#
#  Things have changed since Version 9.3.
#  See doc/install.htm for instructions.


#  configuration parameters
VERSION=v941
name=unspecified
csw=custom
dest=/must/specify/dest/


##################################################################
#
# Default targets.

All:	Icont Ilib Ibin

config/unix/$(name)/status src/h/define.h:
	:
	: To configure Icon, run either
	:
	:	make Configure name=xxxx     [for no graphics]
	: or	make X-Configure name=xxxx   [with X-Windows graphics]
	:
	: where xxxx is one of
	:
	@cd config/unix; ls -d `find * -type d -prune -print`
	:
	@exit 1


##################################################################
#
# Code configuration.


# Configure the code for a specific system.

Configure:	config/unix/$(name)/status
		$(MAKE) Pure >/dev/null
		cd config/unix; sh setup.sh $(name) NoGraphics $(csw)

X-Configure:	config/unix/$(name)/status
		$(MAKE) Pure >/dev/null
		cd config/unix; sh setup.sh $(name) Graphics $(csw)


# Get the status information for a specific system.

Status:
		@cat config/unix/$(name)/status


##################################################################
#
# Compilation.


# The interpreter: icont and iconx.

Icont bin/icont: Common
		cd src/icont;		$(MAKE)
		cd src/runtime;		$(MAKE) 


# The compiler: rtt, the run-time system, and iconc.
# (NO LONGER SUPPORTED OR MAINTAINED.)

Iconc bin/iconc: Common
		cd src/runtime;		$(MAKE) comp_all
		cd src/iconc;		$(MAKE)


# Common components.

Common:		src/h/define.h
		cd src/common;		$(MAKE)
		cd src/rtt;		$(MAKE)


# The Icon program library.

Ilib:		bin/icont
		cd ipl;			$(MAKE)

Ibin:		bin/icont
		cd ipl;			$(MAKE) Ibin


##################################################################
#
# Installation and packaging.


# Installation:  "make Install dest=new-icon-directory"

D=$(dest)
Install:
		test -d $D || mkdir $D
		test -d $D/bin || mkdir $D/bin
		test -d $D/lib || mkdir $D/lib
		test -d $D/doc || mkdir $D/doc
		test -d $D/man || mkdir $D/man
		test -d $D/man/man1 || mkdir $D/man/man1
		rm -f $D/bin/icon* $D/lib/* $D/doc/* $D/man/man1/*
		cp README $D
		cp bin/[abcdefghijklmnopqrstuvwxyz]* $D/bin
		rm -f $D/bin/libXpm* $D/bin/rt* $D/bin/icon
		(cd $D/bin; ln -s icont icon)
		cp lib/*.* $D/lib
		cp doc/*.* $D/doc
		cp man/man1/*.* $D/man/man1


# Bundle up for binary distribution.

DIR=icon.$(VERSION)
Package:
		rm -rf $(DIR)
		umask 002; $(MAKE) Install dest=$(DIR)
		tar cf - icon.$(VERSION) | gzip -9 >icon.$(VERSION).tgz
		rm -rf $(DIR)


##################################################################
#
# Tests.

Test    Test-icont:	; cd tests; $(MAKE) Test
Samples Samples-icont:	; cd tests; $(MAKE) Samples

Test-iconc:		; cd tests; $(MAKE) Test-iconc
Samples-iconc:		; cd tests; $(MAKE) Samples-iconc


#################################################################
#
# Run benchmarks.

Benchmark:
		$(MAKE) Benchmark-icont

Benchmark-iconc:
		cd tests/bench;		$(MAKE) benchmark-iconc

Benchmark-icont:
		cd tests/bench;		$(MAKE) benchmark-icont


##################################################################
#
# Cleanup.
#
# "make Clean" removes intermediate files, leaving executables and library.
# "make Pure"  also removes binaries, library, and configured files.

Clean:
		touch Makedefs
		rm -rf icon.*
		cd src;			$(MAKE) Clean
		cd ipl;			$(MAKE) Clean
		cd tests;		$(MAKE) Clean

Pure:
		touch Makedefs
		rm -rf icon.*
		rm -rf bin/[abcdefghijklmnopqrstuvwxyz]*
		rm -rf lib/[abcdefghijklmnopqrstuvwxyz]*
		cd ipl;			$(MAKE) Pure
		cd src;			$(MAKE) Pure
		cd tests;		$(MAKE) Pure
		cd config/unix; 	$(MAKE) Pure



#  (This is used at Arizona to prepare source distributions.)

Dist-Clean:
		rm -rf xx `find * -type d -name CVS`
		rm -f  xx `find * -type f | xargs grep -l '<<ARIZONA-[O]NLY>>'`
