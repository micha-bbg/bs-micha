
$(D)/opkg: $(ARCHIVE)/opkg-$(OPKG_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/opkg-$(OPKG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_VER); \
		$(PATCH)/opkg-0.2.0-dont-segfault.diff; \
		autoreconf -v --install; \
		echo ac_cv_func_realloc_0_nonnull=yes >> config.cache; \
		$(CONFIGURE) \
		--prefix= \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--disable-curl \
		--disable-gpg \
		--disable-shared \
		--config-cache \
		--with-opkglibdir=/var/lib \
		--mandir=$(BUILD_TMP)/.remove; \
		$(MAKE) all exec_prefix=; \
		make install prefix=$(PKGPREFIX_BASE); \
		make distclean; \
		CFLAGS= \
		./configure \
		--prefix= \
		--disable-curl \
		--disable-gpg \
		--disable-shared \
		--with-opkglibdir=/var/lib; \
		$(MAKE) all; \
		cp -a src/opkg-cl $(HOSTPREFIX)/bin
	install -d -m 0755 $(PKGPREFIX_BASE)/var/lib/opkg
	install -d -m 0755 $(PKGPREFIX_BASE)/etc/opkg
	ln -sf opkg-cl $(PKGPREFIX_BASE)/bin/opkg # convenience symlink
	OPKG_EXAMPLE=$(PKGPREFIX_BASE)/etc/opkg/opkg.conf.example; \
		echo "# example config file, copy to opkg.conf and edit"					 > $$OPKG_EXAMPLE; \
		echo "src server http://server/dist/$(PLATFORM)"						>> $$OPKG_EXAMPLE; \
		echo "# add an optional cache directory, important if not enough flash memory is available!"	>> $$OPKG_EXAMPLE; \
		echo "# directory must exist before executing of opkg"						>> $$OPKG_EXAMPLE; \
		echo "option cache /tmp/media/sda1/.opkg"							>> $$OPKG_EXAMPLE
	$(REMOVE)/opkg-$(OPKG_VER) $(PKGPREFIX_BASE)/.remove
	cp -fr $(PKGPREFIX_BASE)/share/* $(TARGETPREFIX_BASE)/share
	rm -fr $(PKGPREFIX_BASE)/share
	cp -a $(PKGPREFIX_BASE)/* $(TARGETPREFIX_BASE)
	$(REWRITE_PKGCONF_BASE) $(PKG_CONFIG_PATH_BASE)/libopkg.pc
	$(REWRITE_LIBTOOL_BASE)/libopkg.la
	rm -rf $(PKGPREFIX_BASE)/lib $(PKGPREFIX_BASE)/include
	PKG_VER=$(OPKG_VER) $(OPKG_SH) $(CONTROL_DIR)/opkg
	$(RM_PKGPREFIX)
	touch $@

XUPNP_DEFREF = r392
XUPNP_DL_PATH = http://tsdemuxer.googlecode.com/svn/trunk/xupnpd

$(SOURCE_DIR)/xupnp/src/Makefile:
	if [ -e $(SOURCE_DIR)/xupnp ]; then \
		rm -fr $(SOURCE_DIR)/xupnp; \
	fi; \
	mkdir -p $(SOURCE_DIR)/xupnp;
	cd $(SOURCE_DIR)/xupnp; \
		git svn init $(XUPNP_DL_PATH) --ignore-paths="^src/lua-5" ; \
		git svn fetch --revision=360:HEAD; \
		git svn rebase; \
		ID=$$(git svn find-rev $(XUPNP_DEFREF)); \
		git checkout $$ID; \
		git checkout -b work; \
		git am $(PATCHES)/xupnp/*.patch; \
		git rebase master

xupnpd-update: $(SOURCE_DIR)/xupnp/src/Makefile | $(TARGETPREFIX)
	cd $(SOURCE_DIR)/xupnp; \
		REV1=$$(git svn find-rev master --before HEAD); \
		git checkout master; \
		git svn fetch; \
		git svn rebase; \
		git checkout work; \
		REV2=$$(git svn find-rev master --before HEAD); \
		if [ ! "$$REV1" = "$$REV2" ]; then \
			echo "before: r$$REV1, after: r$$REV2"; \
			echo "git rebase master"; \
			git rebase master; \
		else \
			echo "before: r$$REV1, after: r$$REV2"; \
			echo "No changes..."; \
		fi

$(D)/xupnpd: $(D)/lua $(SOURCE_DIR)/xupnp/src/Makefile | $(TARGETPREFIX)
	set -e; cd $(SOURCE_DIR)/xupnp; \
		git checkout work; \
		cd src; \
		make clean; \
		make embedded \
			CC=$(TARGET)-gcc \
			STRIP=$(TARGET)-strip \
			LUAFLAGS="-I$(TARGETPREFIX)/include -L$(TARGETPREFIX)/lib -L$(TARGETPREFIX_BASE)/lib"; \
	$(RM_PKGPREFIX)
	mkdir -p $(PKGPREFIX)/bin
	cp -a $(SOURCE_DIR)/xupnp/src/xupnpd $(PKGPREFIX)/bin
	mkdir -p $(PKGPREFIX)/share/xupnpd/playlists/example
	cp -a $(SOURCE_DIR)/xupnp/src/playlists/example/* $(PKGPREFIX)/share/xupnpd/playlists/example
	cp -fd $(SOURCE_DIR)/xupnp/src/playlists/* $(PKGPREFIX)/share/xupnpd/playlists/example > /dev/null 2>&1 || true
	mkdir -p $(PKGPREFIX)/share/xupnpd/plugins
	cp -a $(SOURCE_DIR)/xupnp/src/plugins/* $(PKGPREFIX)/share/xupnpd/plugins
	cp -r $(SOURCE_DIR)/cst-public-plugins-scripts-lua/xupnpd/* $(PKGPREFIX)/share/xupnpd/plugins
	mkdir -p $(PKGPREFIX)/share/xupnpd/profiles
	cp -a $(SOURCE_DIR)/xupnp/src/profiles/* $(PKGPREFIX)/share/xupnpd/profiles
	mkdir -p $(PKGPREFIX)/share/xupnpd/ui
	cp -a $(SOURCE_DIR)/xupnp/src/ui/* $(PKGPREFIX)/share/xupnpd/ui
	mkdir -p $(PKGPREFIX)/share/xupnpd/www
	cp -a $(SOURCE_DIR)/xupnp/src/www/* $(PKGPREFIX)/share/xupnpd/www
	cp -a $(SOURCE_DIR)/xupnp/src/*.lua  $(PKGPREFIX)/share/xupnpd
	install -m 0755 -D $(SCRIPTS)/xupnpd.init $(PKGPREFIX)/etc/init.d/xupnpd
	ln -sf xupnpd $(PKGPREFIX)/etc/init.d/S80xupnpd
	ln -sf xupnpd $(PKGPREFIX)/etc/init.d/K20xupnpd
	cp -frd $(PKGPREFIX)/. $(TARGETPREFIX)
	cd $(SOURCE_DIR)/xupnp; \
		XUPNP_SVN=$$(git svn find-rev master --before HEAD); \
		PKG_VER=svnr$$XUPNP_SVN \
			PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
				$(OPKG_SH) $(CONTROL_DIR)/xupnpd
	$(RM_PKGPREFIX)
	touch $@

$(D)/libxslt: $(D)/libxml2 $(ARCHIVE)/libxslt-git-snapshot.tar.gz | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/libxslt-git-snapshot.tar.gz $(PKGPREFIX)
	$(UNTAR)/libxslt-git-snapshot.tar.gz
	set -e; cd $(BUILD_TMP)/libxslt-$(LIBXSLT_VER); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--disable-static \
			--datarootdir=/.remove \
			--without-crypto \
			--without-python \
			--with-libxml-include-prefix=$(TARGETPREFIX)/include/libxml2 \
			--with-libxml-libs-prefix=$(TARGETPREFIX)/lib; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	mv $(PKGPREFIX)/bin/xslt-config $(HOSTPREFIX)/bin
	rm -fr $(PKGPREFIX)/lib/*.sh
	rm -fr $(PKGPREFIX)/.remove
	rm -fr $(PKGPREFIX)/lib/libxslt-plugins/
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -fr $(PKGPREFIX)/lib/pkgconfig
	rm -fr $(PKGPREFIX)/lib/*.la
	rm -fr $(PKGPREFIX)/include
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libexslt.pc $(HOSTPREFIX)/bin/xslt-config
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxslt.pc
	$(REWRITE_LIBTOOL)/libexslt.la
	$(REWRITE_LIBTOOL)/libxslt.la
	PKG_VER=$(LIBXML2_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libxslt
	$(REMOVE)/libxslt-$(LIBXSLT_VER) $(PKGPREFIX)
	touch $@

$(D)/libbluray: $(ARCHIVE)/libbluray-$(LIBBLURAY_VER).tar.bz2 $(D)/freetype | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/libbluray-$(LIBBLURAY_VER).tar.bz2
	$(RM_PKGPREFIX)
	$(UNTAR)/libbluray-$(LIBBLURAY_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libbluray-$(LIBBLURAY_VER); \
		$(PATCH)/libbluray-0001-Optimized-file-I-O-for-chained-usage-with-libavforma.patch; \
		$(PATCH)/libbluray-0003-Added-bd_get_clip_infos.patch; \
		$(PATCH)/libbluray-0005-Don-t-abort-demuxing-if-the-disc-looks-encrypted.patch; \
			$(CONFIGURE) \
				--prefix= \
				--enable-shared \
				--disable-static \
				--disable-extra-warnings \
				--disable-doxygen-doc \
				--disable-doxygen-dot \
				--disable-doxygen-html \
				--disable-doxygen-ps \
				--disable-doxygen-pdf \
				--disable-examples \
				--without-libxml2 \
				--without-freetype; \
			$(MAKE); \
			$(MAKE) install DESTDIR=$(PKGPREFIX)
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -fr $(PKGPREFIX)/lib/pkgconfig
	rm -fr $(PKGPREFIX)/lib/*.la
	rm -fr $(PKGPREFIX)/include
	PKG_VER=$(LIBBLURAY_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libbluray
	$(REWRITE_LIBTOOL)/libbluray.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libbluray.pc
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	$(RM_PKGPREFIX)
	touch $@
