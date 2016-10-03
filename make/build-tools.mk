# Makefile build tools for host

build-tools-clean:
	rm -fr $(BUILD_TOOLS)

build-tools: $(BUILD_TMP) $(BUILD_TOOLS)/bin/make $(BUILD_TOOLS)/bin/m4 $(BUILD_TOOLS)/bin/autoconf $(BUILD_TOOLS)/bin/automake $(BUILD_TOOLS)/bin/libtool

$(BUILD_TOOLS)/bin/make: $(ARCHIVE)/make-$(MAKE_VER).tar.bz2
	$(UNTAR)/make-$(MAKE_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/make-$(MAKE_VER); \
		patch -p1 -i $(PATCHES)/build-tools/make/make-arglength.patch; \
		patch -p1 -i $(PATCHES)/build-tools/make/make-fix_whitespace_tokenization.diff; \
		patch -p0 -i $(PATCHES)/build-tools/make/make-glob-faster.patch; \
		patch -p0 -i $(PATCHES)/build-tools/make/make-library-search-path.diff; \
		patch -p1 -i $(PATCHES)/build-tools/make/make-parallel-build.patch; \
		patch -p0 -i $(PATCHES)/build-tools/make/make-savannah-bug30612-handling_of_archives.diff; \
		patch -p0 -i $(PATCHES)/build-tools/make/make-savannah-bug30723-expand_makeflags_before_reexec.diff; \
		./configure \
			--prefix=$(BUILD_TOOLS) \
			--infodir=$(BUILD_TMP)/.remove \
			--mandir=$(BUILD_TMP)/.remove; \
		make; \
		make install-strip
	$(REMOVE)/make-$(MAKE_VER)
	$(REMOVE)/.remove

$(BUILD_TOOLS)/bin/m4: $(BUILD_TOOLS)/bin/make $(ARCHIVE)/m4-$(M4_VER).tar.xz
	$(UNTAR)/m4-$(M4_VER).tar.xz
	set -e; cd $(BUILD_TMP)/m4-$(M4_VER); \
		if [ "$(M4_VER)" = "1.4.16" ]; then \
			patch -p1 -i $(PATCHES)/build-tools/m4/m4-stdio.in.patch; \
		fi; \
		./configure \
			--prefix=$(BUILD_TOOLS) \
			--infodir=$(BUILD_TMP)/.remove \
			--mandir=$(BUILD_TMP)/.remove; \
		$(MAKE); \
		$(MAKE) install-strip
	$(REMOVE)/m4-$(M4_VER)
	$(REMOVE)/.remove

$(BUILD_TOOLS)/bin/autoconf: $(BUILD_TOOLS)/bin/make $(ARCHIVE)/autoconf-$(AUTOCONF_VER).tar.xz
	$(UNTAR)/autoconf-$(AUTOCONF_VER).tar.xz
	set -e; cd $(BUILD_TMP)/autoconf-$(AUTOCONF_VER); \
		patch -p0 -i $(PATCHES)/build-tools/autoconf/autoreconf-ltdl.diff; \
		./configure \
			--prefix=$(BUILD_TOOLS) \
			--infodir=$(BUILD_TMP)/.remove \
			--mandir=$(BUILD_TMP)/.remove; \
		$(MAKE); \
		$(MAKE) install-strip
	$(REMOVE)/autoconf-$(AUTOCONF_VER)
	$(REMOVE)/.remove

$(BUILD_TOOLS)/bin/automake: $(BUILD_TOOLS)/bin/make $(ARCHIVE)/automake-$(AUTOMAKE_VER).tar.$(AUTOMAKE_ARCH)
	$(UNTAR)/automake-$(AUTOMAKE_VER).tar.$(AUTOMAKE_ARCH)
	set -e; cd $(BUILD_TMP)/automake-$(AUTOMAKE_VER); \
		if [ "$(AUTOMAKE_VER)" = "1.13.4" -o "$(AUTOMAKE_VER)" = "1.12.1" ]; then \
			patch -p0 -i $(PATCHES)/build-tools/automake/automake-require_file.patch; \
		fi; \
		./configure \
			--prefix=$(BUILD_TOOLS) \
			--docdir=$(BUILD_TMP)/.remove \
			--infodir=$(BUILD_TMP)/.remove \
			--mandir=$(BUILD_TMP)/.remove; \
		$(MAKE); \
		$(MAKE) install-strip
	$(REMOVE)/automake-$(AUTOMAKE_VER)
	$(REMOVE)/.remove

$(BUILD_TOOLS)/bin/libtool: $(BUILD_TOOLS)/bin/make $(ARCHIVE)/libtool-$(LIBTOOL_VER).tar.xz
	$(UNTAR)/libtool-$(LIBTOOL_VER).tar.xz
	set -e; cd $(BUILD_TMP)/libtool-$(LIBTOOL_VER); \
		patch -p0 -i $(PATCHES)/build-tools/libtool/config-guess-sub-update.patch; \
		./configure \
			--prefix=$(BUILD_TOOLS) \
			--docdir=$(BUILD_TMP)/.remove \
			--infodir=$(BUILD_TMP)/.remove \
			--mandir=$(BUILD_TMP)/.remove; \
		$(MAKE); \
		$(MAKE) install-strip
	$(REMOVE)/libtool-$(LIBTOOL_VER)
	$(REMOVE)/.remove
