
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

$(SOURCE_DIR)/mtd-utils:
	cd $(SOURCE_DIR) && \
	git clone git://git.slknet.de/git/mtd-utils.git && \
	cd $(SOURCE_DIR)/mtd-utils && \
	git checkout --track -b work-cst origin/work-cst

$(ARCHIVE)/mtd-utils.tgz: $(SOURCE_DIR)/mtd-utils $(D)/liblzo | $(TARGETPREFIX)
	rm -f $(ARCHIVE)/mtd-utils.tgz
	cd $(SOURCE_DIR)/mtd-utils && \
#	git checkout work-cst && \
#	git pull && \
	tar -C $(SOURCE_DIR) -czf $(ARCHIVE)/mtd-utils.tgz mtd-utils

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

#MTD_TEST_MODE = 1

$(D)/mtd-utils: $(ARCHIVE)/mtd-utils.tgz $(D)/zlib $(D)/liblzo | $(TARGETPREFIX)
	# build for target
	rm -fr $(BUILD_TMP)/mtd-utils
	if [ "$(MTD_TEST_MODE)" = "1" ]; then \
		cp -frd $(SOURCE_DIR)/mtd-utils $(BUILD_TMP); \
	else \
		$(UNTAR)/mtd-utils.tgz; \
	fi; \
	set -e; cd $(BUILD_TMP)/mtd-utils; \
		$(MAKE) $(MTD_BUILDS) BUILDDIR=$(MTD_BUILDDIR) WITHOUT_XATTR=1 LZO_STATIC=1 \
			CROSS=$(CROSS_DIR)/bin/$(TARGET)- \
			ZLIBCPPFLAGS="-I$(TARGETPREFIX)/include" \
			X_LDLIBS="-L$(TARGETPREFIX)/lib" \
			X_LDSTATIC="$(TARGETPREFIX)/lib" && \
		$(CROSS_DIR)/bin/$(TARGET)-strip $(MTD_BUILDS) && \
		cp -a $(MTD_BUILDS) $(TARGETPREFIX)/sbin
	# build for host
	cd $(BUILD_TMP)
	rm -rf $(BUILD_TMP)/mtd-utils
	if [ "$(MTD_TEST_MODE)" = "1" ]; then \
		cp -frd $(SOURCE_DIR)/mtd-utils $(BUILD_TMP); \
	else \
		$(UNTAR)/mtd-utils.tgz; \
	fi; \
	set -e; cd $(BUILD_TMP)/mtd-utils; \
		$(MAKE) $(MTD_BUILDS_HOST) BUILDDIR=$(MTD_BUILDDIR) WITHOUT_XATTR=1 \
		X_LDSTATIC="/usr/lib" && \
		strip $(MTD_BUILDS_HOST) && \
		cp -a $(MTD_BUILDS_HOST) $(HOSTPREFIX)/bin && \
	rm -rf $(BUILD_TMP)/mtd-utils $(BUILD_TMP)/.remove ; \
	rm -f $(ARCHIVE)/mtd-utils.tgz; \
	if [ ! "$(MTD_TEST_MODE)" = "1" ]; then \
		touch $@; \
	fi

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
