
$(D)/openssh: $(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/openssh-$(OPENSSH_VER)
	$(UNTAR)/openssh-$(OPENSSH_VER).tar.gz
	set -e; cd $(BUILD_TMP)/openssh-$(OPENSSH_VER); \
		CC=$(TARGET)-gcc; \
		./configure \
			$(CONFIGURE_OPTS) \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--sysconfdir=/etc/ssh \
			--libexecdir=/sbin \
			--with-privsep-path=/share/empty \
			--with-cppflags=-I$(TARGETPREFIX)/include \
			--with-ldflags=-L$(TARGETPREFIX)/lib; \
		$(MAKE); \
		patch -p0 < $(PATCHES)/$(PLATFORM)/Openssh_Makefile.diff; \
		rm -fr $(TARGETPREFIX)/OpensshTest; \
		make install-nokeys prefix=$(TARGETPREFIX)/OpensshTest

#	rm -fr $(BUILD_TMP)/openssh-$(OPENSSH_VER) $(BUILD_TMP)/.remove
#	touch $@

$(D)/liblzo: $(ARCHIVE)/lzo-$(LZO_VER).tar.gz | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/lzo-$(LZO_VER)
	$(UNTAR)/lzo-$(LZO_VER).tar.gz
	set -e; cd $(BUILD_TMP)/lzo-$(LZO_VER); \
		CC=$(TARGET)-gcc; \
		./configure \
			$(CONFIGURE_OPTS) \
			--prefix= \
			--program-prefix= \
			--enable-static=yes \
			--enable-shared=no \
			--datarootdir=$(BUILD_TMP)/.remove \
			--includedir=$(TARGETPREFIX)/include \
			--libdir=$(TARGETPREFIX)/lib; \
		$(MAKE); \
		make install; \
	rm -fr $(BUILD_TMP)/lzo-$(LZO_VER) $(BUILD_TMP)/.remove ; \
	touch $@

MTD_BUILDDIR = `pwd`/build
MTD_BUILDS_HOST = \
	$(MTD_BUILDDIR)/mkfs.jffs2 \
	$(MTD_BUILDDIR)/sumtool \
	$(MTD_BUILDDIR)/jffs2reader \
	$(MTD_BUILDDIR)/jffs2dump

MTD_BUILDS = \
	$(MTD_BUILDS_HOST) \
	$(MTD_BUILDDIR)/flash_erase \
	$(MTD_BUILDDIR)/nanddump \
	$(MTD_BUILDDIR)/nandwrite \
	$(MTD_BUILDDIR)/nandtest

$(D)/mtd-utils: $(ARCHIVE)/mtd-utils-$(MTD_UTILS_VER).tar.xz $(D)/zlib $(D)/liblzo | $(TARGETPREFIX)
	# build for target
	$(RM_PKGPREFIX)
	rm -fr $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER)
	$(UNTAR)/mtd-utils-$(MTD_UTILS_VER).tar.xz; \
	set -e; cd $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER); \
		$(MAKE) $(MTD_BUILDS) BUILDDIR=$(MTD_BUILDDIR) WITHOUT_XATTR=1 LZO_STATIC=1 \
			CROSS=$(CROSS_DIR)/bin/$(TARGET)- \
			ZLIBCPPFLAGS="-I$(TARGETPREFIX)/include" \
			X_LDLIBS="-L$(TARGETPREFIX)/lib" \
			X_LDSTATIC="$(TARGETPREFIX)/lib" && \
		mkdir -p $(PKGPREFIX)/sbin && \
		cp -a $(MTD_BUILDS) $(PKGPREFIX)/sbin && \
		$(CROSS_DIR)/bin/$(TARGET)-strip $(MTD_BUILDS) && \
		cp -a --remove-destination $(MTD_BUILDS) $(TARGETPREFIX)/sbin
	PKG_VER=$(MTD_UTILS_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/mtd-utils
	$(RM_PKGPREFIX)
	# build for host
	cd $(BUILD_TMP)
	rm -rf $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER)
	$(UNTAR)/mtd-utils-$(MTD_UTILS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER); \
		$(MAKE) $(MTD_BUILDS_HOST) BUILDDIR=$(MTD_BUILDDIR) WITHOUT_XATTR=1 \
		X_LDSTATIC="/usr/lib" && \
		strip $(MTD_BUILDS_HOST) && \
		cp -a $(MTD_BUILDS_HOST) $(HOSTPREFIX)/bin && \
	rm -fr $(BUILD_TMP)/mtd-utils-$(MTD_UTILS_VER)
	touch $@

$(D)/unrar: $(ARCHIVE)/unrarsrc-$(UNRAR_VER).tar.gz | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/unrar
	$(UNTAR)/unrarsrc-$(UNRAR_VER).tar.gz
	set -e; cd $(BUILD_TMP)/unrar; \
		patch -p1 < $(PATCHES)/unrar_makefile.diff; \
		export CROSS=$(TARGET)-; \
		export DEST=$(TARGETPREFIX); \
		make && \
		make install && \
		rm -fr $(BUILD_TMP)/unrar
		touch $@
