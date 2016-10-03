
$(D)/opkg-host: $(ARCHIVE)/opkg-$(OPKG_VER).tar.gz | $(TARGETPREFIX)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(UNTAR)/opkg-$(OPKG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_VER); \
		./autogen.sh; \
		CFLAGS="-I/usr/include" \
		LDFLAGS="-L/usr/lib" \
		PKG_CONFIG="/usr/bin/pkg-config" \
		PKG_CONFIG_PATH="/usr/lib/pkgconfig" \
		./configure \
			--prefix= \
			--disable-gpg \
			--disable-shared \
			--with-static-libopkg \
			; \
		$(MAKE) all; \
		cp -a src/opkg $(HOSTPREFIX)/bin
	ln -sf opkg $(HOSTPREFIX)/bin/opkg-cl
	$(REMOVE)/opkg-$(OPKG_VER)
	touch $@

$(D)/opkg: $(D)/opkg-host $(D)/libcurl $(D)/libarchive $(ARCHIVE)/opkg-$(OPKG_VER).tar.gz | $(TARGETPREFIX)
	$(RM_PKGPREFIX)
	$(REMOVE)/opkg-$(OPKG_VER)
	$(UNTAR)/opkg-$(OPKG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/opkg-$(OPKG_VER); \
		echo ac_cv_func_realloc_0_nonnull=yes >> config.cache; \
		test -f ./configure || ./autogen.sh && \
		$(BUILDENV) \
		LIBARCHIVE_LIBS="-L$(TARGETPREFIX)/lib -larchive" \
		LIBARCHIVE_CFLAGS="-I$(TARGETPREFIX)/include" \
		./configure $(CONFIGURE_OPTS) \
			--prefix= \
			--disable-gpg \
			--config-cache \
			--mandir=/.remove \
			--with-static-libopkg \
			; \
		$(MAKE) all ; \
		make install DESTDIR=$(TARGETPREFIX_BASE); \
		make install DESTDIR=$(PKGPREFIX_BASE); \
	rm -fr $(TARGETPREFIX_BASE)/.remove; rm -fr $(PKGPREFIX_BASE)/.remove
	rm -fr $(PKGPREFIX_BASE)/lib
	install -d -m 0755 $(PKGPREFIX_BASE)/var/lib/opkg
	install -d -m 0755 $(PKGPREFIX_BASE)/etc/opkg
	ln -sf opkg $(PKGPREFIX_BASE)/bin/opkg-cl
	install -d -m 0755 $(TARGETPREFIX_BASE)/var/lib/opkg
	install -d -m 0755 $(TARGETPREFIX_BASE)/etc/opkg
	ln -sf opkg $(TARGETPREFIX_BASE)/bin/opkg-cl
	rm -fr $(TARGETPREFIX_BASE)/lib/libopkg.*
	rm -fr $(TARGETPREFIX_BASE)/lib/pkgconfig/libopkg.pc
	PKG_VER=$(OPKG_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX_BASE)/bin` \
		$(OPKG_SH) $(CONTROL_DIR)/opkg
	$(REMOVE)/opkg-$(OPKG_VER)
	$(RM_PKGPREFIX)
	touch $@

XUPNP_DEFREF = r404
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
		git am $(PATCHES)/xupnp/svn$(XUPNP_DEFREF)/*.patch; \
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
	if [ "$(NO_USR_BUILD)" = "1" ]; then \
		mkdir -p $(PKGPREFIX)/usr; \
		mv $(PKGPREFIX)/share $(PKGPREFIX)/usr; \
		ln -sf usr/share $(PKGPREFIX)/share; \
	fi;
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

$(D)/mc: $(ARCHIVE)/mc-$(MC_VER).tar.xz $(D)/libncurses $(D)/libglib | $(TARGETPREFIX) find-autopoint
	$(REMOVE)/mc-$(MC_VER)
	$(RM_PKGPREFIX)
	$(UNTAR)/mc-$(MC_VER).tar.xz
	set -e; cd $(BUILD_TMP)/mc-$(MC_VER); \
		$(PATCH)/mc-4.8.1.diff; \
		$(PATCH)/mc-opkg.diff; \
		autoreconf -fi; \
		if [ ! "$(UCLIBC_BUILD)" = "1" ]; then \
			export LIBS="-lglib-2.0"; \
		fi; \
		$(BUILDENV) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=$(DEFAULT_PREFIX) \
			--without-gpm-mouse \
			--disable-doxygen-doc \
			--disable-doxygen-dot \
			--enable-charset \
			--with-screen=ncurses \
			--with-ncurses-includes="$(TARGETPREFIX)/include/ncurses" \
			--with-ncurses-libs="$(TARGETPREFIX)/lib" \
			--sysconfdir=/etc \
			--mandir=/.remove \
			--with-homedir=/var/tuxbox/config/mc \
			--without-x; \
			$(BUILDENV) $(MAKE) all; \
			make install DESTDIR=$(PKGPREFIX_BASE)
	rm -rf $(PKGPREFIX_BASE)/.remove
	rm -rf $(PKGPREFIX)/share/locale # who needs localization?
	install -m 0644 -D $(SCRIPTS)/mc-ini $(PKGPREFIX_BASE)/var/tuxbox/config/mc/ini
	install -m 0644 -D $(SCRIPTS)/mc-panels.ini $(PKGPREFIX_BASE)/var/tuxbox/config/mc/panels.ini
	if [ "$(NO_USR_BUILD)" = "1" ]; then \
		mkdir -p $(PKGPREFIX)/usr; \
		mv $(PKGPREFIX)/share $(PKGPREFIX)/usr; \
		ln -sf usr/share $(PKGPREFIX)/share; \
	fi;
	cp -a $(PKGPREFIX_BASE)/* $(TARGETPREFIX_BASE)/
	PKG_VER=$(MC_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/mc
	$(REMOVE)/mc-$(MC_VER)
	$(RM_PKGPREFIX)
	touch $@

$(HOSTPREFIX)/bin/glib-genmarshal: | $(HOSTPREFIX)/bin
	$(REMOVE)/glib-$(GLIB_VER)
	$(UNTAR)/glib-$(GLIB_VER).tar.xz
	set -e; cd $(BUILD_TMP)/glib-$(GLIB_VER); \
		export PKG_CONFIG=/usr/bin/pkg-config; \
		./autogen.sh; \
		./configure \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--enable-static=yes \
			--enable-shared=no \
			--prefix=`pwd`/out \
			; \
		$(MAKE) install; \
		strip out/bin/glib-* || true; \
		cp -a out/bin/glib-* $(HOSTPREFIX)/bin
	$(REMOVE)/glib-$(GLIB_VER)

#http://www.dbox2world.net/board293-coolstream-hd1/board314-coolstream-development/9363-idee-midnight-commander/
$(D)/libglib: $(ARCHIVE)/glib-$(GLIB_VER).tar.xz $(HOSTPREFIX)/bin/glib-genmarshal $(D)/zlib $(D)/libffi | $(TARGETPREFIX)
	$(REMOVE)/glib-$(GLIB_VER)
	$(RM_PKGPREFIX)
	$(UNTAR)/glib-$(GLIB_VER).tar.xz
	set -e; cd $(BUILD_TMP)/glib-$(GLIB_VER); \
		./autogen.sh; \
		echo "ac_cv_func_posix_getpwuid_r=yes" > config.cache; \
		echo "ac_cv_func_posix_getgrgid_r=yes" >> config.cache; \
		echo "glib_cv_stack_grows=no" >> config.cache; \
		echo "glib_cv_uscore=no" >> config.cache; \
		if [ "$(UCLIBC_BUILD)" = "1" ]; then \
			ICONV=--with-libiconv=gnu; \
		else \
			ICONV=; \
		fi; \
		$(BUILDENV) \
		./configure \
			$$ICONV \
			--cache-file=config.cache \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-static=yes \
			--enable-shared=yes \
			--with-html-dir=/.remove \
			--mandir=/.remove \
			--prefix= ;\
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	set -e; cd $(PKGPREFIX)/lib/pkgconfig; for i in *; do \
		mv $$i $(PKG_CONFIG_PATH); $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/$$i; done
	rm -rf $(PKGPREFIX)/share/locale # who needs localization?
	rm -f $(PKGPREFIX)/bin/glib-mkenums # no perl available on the box
	rm -f $(PKGPREFIX)/bin/gdbus-codegen # no python available on the box
	rm -f $(PKGPREFIX)/bin/gtester-report # no python available on the box
	sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX)/lib'," $(PKGPREFIX)/lib/*.la
	rm -f $(PKGPREFIX)/bin/gdbus
	if [ "$(NO_USR_BUILD)" = "1" ]; then \
		cp -a $(PKGPREFIX)/share $(TARGETPREFIX)/usr; \
		rm -fr $(PKGPREFIX)/share; \
	fi;
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cd $(PKGPREFIX) && \
		rm -fr include lib/*.so lib/*.la lib/*.a etc/bash_completion.d \
		bin/gtester-report bin/glib-gettextize lib/pkgconfig etc
	PKG_VER=$(GLIB_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libglib
	$(REMOVE)/glib-$(GLIB_VER)
	$(RM_PKGPREFIX)
	touch $@

$(D)/libffi: $(ARCHIVE)/libffi-$(LIBFFI_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libffi-$(LIBFFI_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libffi-$(LIBFFI_VER); \
		./configure \
			--prefix= \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--enable-shared=yes \
			--enable-static=yes; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX); \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libffi.pc
	$(REWRITE_LIBTOOL)/libffi.la
	rm -rf $(PKGPREFIX)/share $(PKGPREFIX)/lib/libffi-$(LIBFFI_VER) $(PKGPREFIX)/lib/pkgconfig
	rm -rf $(PKGPREFIX)/lib/*.*a $(PKGPREFIX)/lib/*.so
	PKG_VER=$(LIBFFI_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libffi
	rm -fr $(BUILD_TMP)/libffi-$(LIBFFI_VER)
	$(RM_PKGPREFIX)
	touch $@

ifeq ($(UCLIBC_BUILD), 1)
$(D)/gettext: $(ARCHIVE)/gettext-$(GETTEXT_VER).tar.xz | $(TARGETPREFIX)
	$(REMOVE)/gettext-$(GETTEXT_VER)
	$(RM_PKGPREFIX)
	$(UNTAR)/gettext-$(GETTEXT_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gettext-$(GETTEXT_VER); \
		$(BUILDENV) \
		LIBS="-lrt" \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-silent-rules \
			--prefix=$(DEFAULT_PREFIX) \
			--disable-java \
			--disable-native-java \
			--datarootdir=/.remove \
			--with-libxml2-prefix=$(TARGETPREFIX) \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX_BASE)
	rm -fr $(PKGPREFIX_BASE)/.remove
	cp -a $(PKGPREFIX_BASE)/* $(TARGETPREFIX_BASE)
	rm -fr $(PKGPREFIX)/include
	rm -f $(PKGPREFIX)/lib/*.a
	rm -f $(PKGPREFIX)/lib/*.la
	rm -f $(PKGPREFIX)/lib/*.so
	$(REWRITE_LIBTOOL)/libasprintf.la
	$(REWRITE_LIBTOOL)/libgettextlib.la
	$(REWRITE_LIBTOOL)/libgettextpo.la
	$(REWRITE_LIBTOOL)/libgettextsrc.la
	$(REWRITE_LIBTOOL)/libintl.la
	PKG_VER=$(GETTEXT_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/gettext
	$(REMOVE)/gettext-$(GETTEXT_VER)
	$(RM_PKGPREFIX)
	touch $@
endif

$(D)/kernelcheck: $(ARCHIVE)/kernelcheck-$(KERNELCHECK_VER).tar.xz | $(TARGETPREFIX)
	$(REMOVE)/kernelcheck-$(KERNELCHECK_VER)
	$(UNTAR)/kernelcheck-$(KERNELCHECK_VER).tar.xz
	## build for host
	set -e; cd $(BUILD_TMP)/kernelcheck-$(KERNELCHECK_VER); \
		$(MAKE) all BUILD_FOR_HOST=1; \
		make install DESTDIR=$(HOSTPREFIX)
	## build for target
	$(REMOVE)/kernelcheck-$(KERNELCHECK_VER)
	$(RM_PKGPREFIX)
	$(UNTAR)/kernelcheck-$(KERNELCHECK_VER).tar.xz
	set -e; cd $(BUILD_TMP)/kernelcheck-$(KERNELCHECK_VER); \
		make all CC=$(TARGET)-g++ STRIP=$(TARGET)-strip; \
		make install DESTDIR=$(PKGPREFIX); \
		make install DESTDIR=$(TARGETPREFIX)
	PKG_VER=$(KERNELCHECK_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/kernelcheck
	$(REMOVE)/kernelcheck-$(KERNELCHECK_VER)
	$(RM_PKGPREFIX)
	touch $@


EXTRAS_MC =
ifeq ($(UCLIBC_BUILD), 1)
EXTRAS_MC += $(D)/libiconv $(D)/gettext
endif
EXTRAS_MC += $(D)/libffi $(D)/libglib $(D)/mc
extras-mc: $(EXTRAS_MC)
