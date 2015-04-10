#Makefile to build devel-tools

$(D)/strace: $(ARCHIVE)/strace-$(STRACE_VER).tar.xz | $(TARGETPREFIX)
	$(RM_PKGPREFIX)
	$(UNTAR)/strace-$(STRACE_VER).tar.xz
ifeq ($(PLATFORM), tripledragon)
	cd $(BUILD_TMP)/strace-$(STRACE_VER) && \
		$(PATCH)/strace-add-TD-ioctls.diff
endif
	set -e; cd $(BUILD_TMP)/strace-$(STRACE_VER); \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGETPREFIX)/include -I$(TARGETPREFIX_BASE)/include" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove; \
		$(MAKE) all; \
		make install prefix=$(PKGPREFIX_BASE)
	cp -a $(PKGPREFIX_BASE)/* $(TARGETPREFIX_BASE)
	rm $(PKGPREFIX_BASE)/bin/strace-graph
	PKG_VER=$(STRACE_VER) $(OPKG_SH) $(CONTROL_DIR)/strace
	$(REMOVE)/strace-$(STRACE_VER)
	$(REMOVE)/.remove
	$(RM_PKGPREFIX)
	touch $@

#  NOTE:
#  gdb built for target or local-PC
$(D)/gdb: $(ARCHIVE)/gdb-$(GDB_VER).tar.bz2 $(D)/libncurses $(D)/zlib | $(TARGETPREFIX)
	$(RM_PKGPREFIX)
	$(UNTAR)/gdb-$(GDB_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VER); \
		$(PATCH)/gdb-7.1-remove-builddate.diff; \
		$(BUILDENV) \
		./configure \
			--nfp --disable-werror \
			--prefix=/opt/pkg \
			--mandir=$(BUILD_TMP)/.remove \
			--infodir=$(BUILD_TMP)/.remove \
			--build=$(BUILD) --host=$(TARGET); \
		$(MAKE) all-gdb; \
		make install-gdb prefix=$(PKGPREFIX_BASE)/opt/pkg
	cp -a $(PKGPREFIX_BASE)/* $(TARGETPREFIX_BASE)
	rm -fr $(PKGPREFIX_BASE)/opt/pkg/share
	rm -f $(PKGPREFIX_BASE)/opt/pkg/bin/gdbtui
	rm -rf $(BUILD_TMP)/gdb-tmp
	mkdir $(BUILD_TMP)/gdb-tmp
	mv $(PKGPREFIX_BASE)/opt/pkg/bin/gdbserver $(BUILD_TMP)/gdb-tmp
	PKG_VER=$(GDB_VER) $(OPKG_SH) $(CONTROL_DIR)/gdb/gdb
	$(RM_PKGPREFIX)
	mkdir -p $(PKGPREFIX_BASE)/bin
	cp $(BUILD_TMP)/gdb-tmp/gdbserver $(TARGETPREFIX_BASE)/bin
	mv $(BUILD_TMP)/gdb-tmp/gdbserver $(PKGPREFIX_BASE)/bin
	PKG_VER=$(GDB_VER) $(OPKG_SH) $(CONTROL_DIR)/gdb/gdbserver
	$(REMOVE)/gdb-$(GDB_VER) $(BUILD_TMP)/gdb-tmp $(BUILD_TMP)/.remove
	$(RM_PKGPREFIX)
	touch $@

#  NOTE:
#  gdb-remote built for local-PC or target
$(D)/gdb-remote: $(ARCHIVE)/gdb-$(GDB_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/gdb-$(GDB_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/gdb-$(GDB_VER); \
		./configure \
			--nfp --disable-werror \
			--prefix=$(HOSTPREFIX) \
			--build=$(BUILD) --host=$(BUILD) --target=$(TARGET); \
		$(MAKE) all-gdb; \
		make install-gdb; \
	$(REMOVE)/gdb-$(GDB_VER)
	touch $@

devel-tools: $(D)/strace $(D)/gdb
devel-tools-all: devel-tools $(D)/gdb-remote

PHONY += devel-tools devel-tools-all
