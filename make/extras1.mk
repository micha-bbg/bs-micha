
$(DEPDIR)/opkg: $(ARCHIVE)/opkg-$(OPKG_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/opkg-$(OPKG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_VER); \
		$(PATCH)/opkg-$(OPKG_VER)-dont-segfault.diff; \
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
		make install prefix=$(PKGPREFIX); \
		make distclean; \
		./configure \
		--prefix= \
		--disable-curl \
		--disable-gpg \
		--disable-shared \
		--with-opkglibdir=/var/lib; \
		$(MAKE) all; \
		cp -a src/opkg-cl $(HOSTPREFIX)/bin
	install -d -m 0755 $(PKGPREFIX)/var/lib/opkg
	install -d -m 0755 $(PKGPREFIX)/etc/opkg
	echo "# example config file, copy to opkg.conf and edit" > $(PKGPREFIX)/etc/opkg/opkg.conf.example
	echo "src server http://server/dist/$(PLATFORM)" >> $(PKGPREFIX)/etc/opkg/opkg.conf.example
	echo "# add an optional cache directory, important if too few  flash memory is available!" >> $(PKGPREFIX)/etc/opkg/opkg.conf.example
	echo "# directory must be exists, before executing of opkg" >> $(PKGPREFIX)/etc/opkg/opkg.conf.example
	echo "option cache /tmp/media/sda1/.opkg" >> $(PKGPREFIX)/etc/opkg/opkg.conf.example
	$(REMOVE)/opkg-$(OPKG_VER) $(PKGPREFIX)/.remove
	cp -fr $(PKGPREFIX)/share/* $(TARGETPREFIX)/share
	rm -fr $(PKGPREFIX)/share
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libopkg.pc
	rm -rf $(PKGPREFIX)/lib $(PKGPREFIX)/include
	PKG_VER=$(OPKG_VER) $(OPKG_SH) $(CONTROL_DIR)/opkg
	rm -rf $(PKGPREFIX)
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

$(D)/xupnpd: $(SOURCE_DIR)/xupnp/src/Makefile | $(TARGETPREFIX)
	set -e; cd $(SOURCE_DIR)/xupnp; \
		git checkout work; \
		cd src; \
		make clean; \
		make embedded \
			CC=$(TARGET)-gcc \
			STRIP=$(TARGET)-strip \
			LUAFLAGS="-I$(TARGETPREFIX)/include -L$(TARGETPREFIX)/lib"; \
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/bin
	cp -a $(SOURCE_DIR)/xupnp/src/xupnpd $(PKGPREFIX)/bin
	mkdir -p $(PKGPREFIX)/usr/share/xupnpd/playlists/example
	cp -a $(SOURCE_DIR)/xupnp/src/playlists/example/* $(PKGPREFIX)/usr/share/xupnpd/playlists/example
	cp -fd $(SOURCE_DIR)/xupnp/src/playlists/* $(PKGPREFIX)/usr/share/xupnpd/playlists/example > /dev/null 2>&1 || true
	mkdir -p $(PKGPREFIX)/usr/share/xupnpd/plugins
	cp -a $(SOURCE_DIR)/xupnp/src/plugins/* $(PKGPREFIX)/usr/share/xupnpd/plugins
	mkdir -p $(PKGPREFIX)/usr/share/xupnpd/profiles
	cp -a $(SOURCE_DIR)/xupnp/src/profiles/* $(PKGPREFIX)/usr/share/xupnpd/profiles
	mkdir -p $(PKGPREFIX)/usr/share/xupnpd/ui
	cp -a $(SOURCE_DIR)/xupnp/src/ui/* $(PKGPREFIX)/usr/share/xupnpd/ui
	mkdir -p $(PKGPREFIX)/usr/share/xupnpd/www
	cp -a $(SOURCE_DIR)/xupnp/src/www/* $(PKGPREFIX)/usr/share/xupnpd/www
	cp -a $(SOURCE_DIR)/xupnp/src/*.lua  $(PKGPREFIX)/usr/share/xupnpd
	install -m 0755 -D $(SCRIPTS)/xupnpd.init $(PKGPREFIX)/etc/init.d/xupnpd
	ln -sf xupnpd $(PKGPREFIX)/etc/init.d/S80xupnpd
	ln -sf xupnpd $(PKGPREFIX)/etc/init.d/K20xupnpd
	cp -frd $(PKGPREFIX)/. $(TARGETPREFIX)
	ln -s /usr/share $(PKGPREFIX)/share
	cd $(SOURCE_DIR)/xupnp; \
		XUPNP_SVN=$$(git svn find-rev master --before HEAD); \
		PKG_VER=svnr$$XUPNP_SVN \
			PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
				$(OPKG_SH) $(CONTROL_DIR)/xupnpd
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libxml2: $(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz $(D)/libiconv | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/libxml2-$(LIBXML2_VER).tar.gz $(PKGPREFIX)
	$(UNTAR)/libxml2-$(LIBXML2_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libxml2-$(LIBXML2_VER); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--disable-static \
			--datarootdir=/.remove \
			--without-python \
			--without-debug \
			--without-sax1 \
			--without-legacy \
			--without-catalog \
			--without-docbook \
			--without-lzma \
			--without-schematron; \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(PKGPREFIX);
	mv $(PKGPREFIX)/bin/xml2-config $(HOSTPREFIX)/bin
	rm -fr $(PKGPREFIX)/lib/*.sh
	rm -fr $(PKGPREFIX)/.remove
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -fr $(PKGPREFIX)/lib/pkgconfig
	rm -fr $(PKGPREFIX)/lib/*.la
	rm -fr $(PKGPREFIX)/include
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc $(HOSTPREFIX)/bin/xml2-config
	sed -i 's/^\(Libs:.*\)/\1 -lz/' $(PKG_CONFIG_PATH)/libxml-2.0.pc
	$(REWRITE_LIBTOOL)/libxml2.la
	PKG_VER=$(LIBXML2_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libxml2
	$(REMOVE)/libxml2-$(LIBXML2_VER) $(PKGPREFIX)
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
	rm -fr $(BUILD_TMP)/libbluray-$(LIBBLURAY_VER).tar.bz2 $(PKGPREFIX)
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
				--without-libxml2; \
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
	$(REMOVE)/libbluray-$(LIBBLURAY_VER) $(PKGPREFIX)
	touch $@
