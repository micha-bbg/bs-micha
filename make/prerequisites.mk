# makefile for basic prerequisites

TOOLCHECK  = find-git find-svn find-gzip find-bzip2 find-patch find-gawk
TOOLCHECK += find-makeinfo find-automake find-gcc find-libtool
TOOLCHECK += find-yacc find-flex find-tic find-pkg-config
TOOLCHECK += find-cmake find-gperf find-makedepend

SYS_TOOLS1 = procps busybox vsftpd rsync e2fsprogs ntfs-3g wget timezone fuse parted readline
SYS_TOOLS2 = liblzo mtd-utils unrar
SYS_TOOLS3 = gdb gdb-remote

sys-tools1: $(SYS_TOOLS1)

sys-tools2: $(SYS_TOOLS2)

sys-tools3: $(SYS_TOOLS3)

PREQS = download neutrino-source $(D)
PREQS += cst-sources-$(PLATFORM)

preqs: $(PREQS)

$(D):
	mkdir $(D)

download:
	@echo
	@echo "Download directory missing:"
	@echo "==========================="
	@echo "You need to make a directory named 'download' by executing 'mkdir download'"
	@echo "or create a symlink to the directory where you keep your sources, e.g. by"
	@echo "typing 'ln -s /path/to/my/Archive download'."
	@echo
	@false

$(N_HD_SOURCE):
	@echo ' ============================================================================== '
	@echo "                  Cloning neutrino-hd git repo"
	@echo ' ============================================================================== '
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone -b master $(GITSOURCE)/$(SOURCE_NEUTRINO).git neutrino-hd && \
		cd neutrino-hd && \
		git checkout --track -b $(NEUTRINO_BRANCH) origin/$(NEUTRINO_BRANCH)
ifneq ($(NEUTRINO_BRANCH), $(NEUTRINO_WORK_BRANCH))
	cd $(SOURCE_DIR)/neutrino-hd && \
		git checkout -b $(NEUTRINO_WORK_BRANCH)
endif
		@echo "Cloning neutrino-hd git repo OK"

$(PLUGIN_DIR):
	mkdir -p $(SOURCE_DIR)
	cd $(SOURCE_DIR) && \
		git clone $(GITORIOUS)/neutrino-hd/neutrino-hd-plugins.git
$(CST_GIT):
	mkdir -p $@

$(CST_GIT)/%: | $(CST_GIT)
	cd $(CST_GIT) && git clone $(GITSOURCE)/$(notdir $@).git

find-%:
	@TOOL=$(patsubst find-%,%,$@); \
		type -p $$TOOL >/dev/null || \
		{ echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK)
	@echo "All required tools seem to be installed."
	@echo
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != bash; then \
		echo "WARNING: /bin/sh is not linked to bash."; \
		echo "         This configuration might work, but is not supported."; \
		echo; \
	fi

neutrino-source: $(N_HD_SOURCE)

cst-sources-apollo: $(CST_GIT)/$(SOURCE_DRIVERS)

cst-sources-kronos: $(CST_GIT)/$(SOURCE_DRIVERS)

cst-sources-nevis: $(CST_GIT)/$(SOURCE_DRIVERS)

