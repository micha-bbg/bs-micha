#master makefile

SHELL = /bin/bash
UID := $(shell id -u)
ifeq ($(UID), 0)
warn:
	@echo "You are running as root. Don't do this, it's dangerous."
	@echo "Refusing to build. Good bye."
else

include make/environment.mk

############################################################################
#  A print out of environment variables
#
# maybe a help about all supported targets would be nice here, too...
#
printenv:
	@echo '============================================================================== '
	@echo "Build Environment Varibles:"
	@echo "CROSS_DIR:   $(CROSS_DIR)"
	@echo "CROSS_BASE:  $(CROSS_BASE)"
	@echo "TARGET:      $(TARGET)"
	@echo "BASE_DIR:    $(BASE_DIR)"
	@echo "BUILD:       $(BUILD)"
	@echo "PATH:        `type -p fmt>/dev/null&&echo $(PATH)|sed 's/:/ /g' |fmt -65|sed 's/ /:/g; 2,$$s/^/             /;'||echo $(PATH)`"
	@echo "N_HD_SOURCE: $(N_HD_SOURCE)"
	@echo "BOXARCH:     $(BOXARCH)"
	@echo "PLATFORM:    $(PLATFORM)"
	@echo "KVERSION:    $(KVERSION)"
	@echo "GITSOURCE:   $(GITSOURCE)"
	@echo "MAINTAINER:  $(MAINTAINER)"
	@echo '============================================================================== '
	@echo "LOCAL_NEUTRINO_BUILD_OPTIONS:  $(LOCAL_NEUTRINO_BUILD_OPTIONS)"
	@echo "LOCAL_NEUTRINO_CFLAGS:  $(LOCAL_NEUTRINO_CFLAGS)"
	@echo ""
	@echo "'make help' lists useful targets."
	@echo "The doc/ directory contains documentation. Read it."
	@echo ""
	@make --no-print-directory toolcheck
ifeq ($(MAINTAINER),)
	@echo "##########################################################################"
	@echo "# The MAINTAINER variable is not set. It defaults to your name from the  #"
	@echo "# passwd entry, but this seems to have failed. Please set it in 'config'.#"
	@echo "##########################################################################"
	@echo
endif
	@LC_ALL=C make -n preqs|grep -q "Nothing to be done" && P=false || P=true; \
	test -d $(TARGETPREFIX) && T=false || T=true; \
	type -p $(TARGET)-pkg-config >/dev/null 2>&1 || T=true; \
	PATH=$(PATH):$(CROSS_DIR)/bin; \
	type -p $(TARGET)-gcc >/dev/null 2>&1 && C=false || C=true; \
	if $$P || $$T || $$C; then \
		echo "Your next steps are most likely (in this order):"; \
		$$P && echo "	* 'make preqs'		for prerequisites"; \
		$$C && echo "	* 'make crosstool'	for the cross compiler"; \
		$$T && echo "	* 'make bootstrap'	to prepare the target root"; \
		echo; \
	fi

	@if ! test -e $(BASE_DIR)/config; then \
		echo;echo "If you want to change the configuration, copy 'doc/config.example' to 'config'"; \
		echo "and edit it to fit your needs. See the comments in there."; echo; fi

help:
	@echo "a few helpful make targets:"
	@echo "* make preqs               - downloads necessary stuff"
	@echo "* make crosstool           - build cross toolchain"
	@echo "* make bootstrap           - prepares for building"
	@echo "* make neutrino            - builds neutrino"
	@echo "* make neutrino-pkg        - builds neutrino pkg"
#	@echo "* make minimal-system-pkgs - build enough to have a bootable system, consult"
#	@echo "                             doc/README.opkg-bootstrap how to continue from there"
#	@echo "* make devel-tools         - build gdb and strace for the target"
	@echo "* make print-targets       - print out all available targets"
	@echo ""
	@echo "later, you might find those useful:"
	@echo "* make update-self         - update the build system"
	@echo "* make update-neutrino     - update the neutrino source"
	@echo "* make update-driver       - update the cst drivers"
	@echo ""
	@echo "cleantargets:"
	@echo "make clean                 - clean neutrino build dir"
	@echo "make rebuild-clean         - additionally remove \$$TARGETPREFIX, but keep the toolchain"
	@echo "                             after that you need to restart with 'bootstrap'"
	@echo "make all-clean             - additionally remove the crosscompiler"
	@echo "                             you usually don't want to do that."
	@echo

# define package versions first...
include make/versions.mk
include make/build-tools.mk
include make/prerequisites.mk
include make/bootstrap.mk
include make/system-libs.mk
include make/system-tools.mk
include make/devel-tools.mk
include make/nfsd.mk
include make/neutrino.mk
#include make/cleantargets.mk
include make/linuxkernel.mk
include make/archives.mk
include make/extras1.mk
include make/extras2.mk
#include make/extras3.mk
#include make/gstreamer.mk
#include make/packages.mk
#include make/plugins.mk
#include make/example.mk
include make/flashimage.mk
include make/rootfs.mk
include make/crosstool.mk
include make/tuxwetter.mk
-include make/micha-seine.mk

update-self:
	git pull

# only updates important(?) stuff, no crosstool etc.
# not useful on tripledragon, because that SVN never changes
update-svn: | $(SOURCE_DIR)/svn/THIRDPARTY/lib
	for i in $(SOURCE_DIR)/svn/COOLSTREAM \
		$(SOURCE_DIR)/svn/CROSSENVIROMENT/coolstream; \
	do \
		if [ -d $$i ]; then \
			echo "updating $$i..."; \
			(cd $$i && $(SVN) up); \
		else true; fi \
	done
	for i in $(SOURCE_DIR)/svn/THIRDPARTY/*; \
	do \
		if [ -d $$i ]; then \
			echo "updating $$i..."; \
			(cd $$i && $(SVN) up *); \
		else true; fi \
	done

update-driver:
	cd $(SOURCE_DIR)/$(SOURCE_DRIVERS) && \
		git checkout master && \
		git pull

update-neutrino:
	cd $(SOURCE_DIR)/neutrino-hd && \
		git checkout $(NEUTRINO_BRANCH) && \
		git pull && \
ifneq ($(NEUTRINO_BRANCH), $(NEUTRINO_WORK_BRANCH))
		git checkout $(NEUTRINO_WORK_BRANCH) && \
		git rebase $(NEUTRINO_BRANCH)
endif
		@echo "Update neutrino-hd git repo OK"

update-cst:
	set -e; cd $(CST_GIT); \
		for i in cst-*; do \
			( echo updating $$i; cd $$i; git pull; ); \
		done


all:
	@echo "'make all' is not a valid target. Please read the documentation."

# target for testing only. not useful otherwise
everything: $(shell sed -n 's/^\$$.D.\/\(.*\):.*/\1/p' make/*.mk)

# print all present targets...
print-targets:
	sed -n 's/^\$$.D.\/\(.*\):.*/\1/p; s/^\([a-z].*\):\( \|$$\).*/\1/p;' \
		`ls -1 make/*.mk|grep -v make/unmaintained.mk` Makefile | \
		sort | fmt -65

$(BUILD_TMP)/Makefile.archivecheck: | $(BUILD_TMP)
	rm -f $@
	BOXARCH=$(BOXARCH) scripts/archivecheck.pl > $@

archivecheck: $(BUILD_TMP)/Makefile.archivecheck
	make -f $(BUILD_TMP)/Makefile.archivecheck

# for local extensions, e.g. special plugins or similar...
# put them into $(BASE_DIR)/local since that is ignored in .gitignore
-include ./Makefile.local

# debug target, if you need that, you know it. If you don't know if you need
# that, you don't need it.
.print-phony:
	@echo $(PHONY)

PHONY += $(BUILD_TMP)/Makefile.archivecheck
PHONY += everything print-targets
PHONY += all printenv .print-phony
PHONY += update-svn update-svn-target update-neutrino update-self
.PHONY: $(PHONY)

# this makes sure we do not build top-level dependencies in parallel
# (which would not be too helpful anyway, running many configure and
# downloads in parallel...), but the sub-targets are still built in
# parallel, which is useful on multi-processor / multi-core machines
.NOTPARALLEL:
