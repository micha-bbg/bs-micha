$(D)/mc: $(ARCHIVE)/mc-$(MC_VER).tar.xz $(D)/libncurses $(D)/libglib | $(TARGETPREFIX) find-autopoint
	$(UNTAR)/mc-$(MC_VER).tar.xz
	set -e; cd $(BUILD_TMP)/mc-$(MC_VER); \
		$(PATCH)/mc-4.8.1.diff; \
		$(BUILDENV) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CONFIG_SHELL=/bin/bash \
		GLIB_LIBS=$(TARGETPREFIX)/lib \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/opt/pkg \
			--without-gpm-mouse \
			--with-glib-static \
			--with-included-gettext \
			--with-screen=ncurses \
			--mandir=/.remove \
			--without-x; \
			$(BUILDENV) $(MAKE) all; \
			make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	rm -rf $(PKGPREFIX)/opt/pkg/share/locale # who needs localization?
	rm $(PKGPREFIX)/opt/pkg/share/mc/mc.h*.* # mc.hint.*, mc.hlp.*
	$(OPKG_SH) $(CONTROL_DIR)/mc
#	$(REMOVE)/mc-$(MC_VER) $(PKGPREFIX)
#	touch $@


######
# build glib-tools for the host, for build systems that don't have those
# installed already.
# TODO: check if we this built glib-genmarshal is new enough for the glib
#       version we're trying to build
######
$(HOSTPREFIX)/bin/glib-genmarshal: | $(HOSTPREFIX)/bin
	$(UNTAR)/glib-$(GLIB_VER).tar.xz
	set -e; cd $(BUILD_TMP)/glib-$(GLIB_VER); \
		export PKG_CONFIG=/usr/bin/pkg-config; \
		./configure \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--enable-static=yes \
			--enable-shared=no \
			--prefix=`pwd`/out \
			; \
		$(MAKE) install ; \
		cp -a out/bin/glib-* $(HOSTPREFIX)/bin
	$(REMOVE)/glib-$(GLIB_VER)

#http://www.dbox2world.net/board293-coolstream-hd1/board314-coolstream-development/9363-idee-midnight-commander/
$(D)/libglib: $(ARCHIVE)/glib-$(GLIB_VER).tar.xz $(D)/zlib $(D)/libiconv $(D)/libffi | $(TARGETPREFIX)
	type -p glib-genmarshal || $(MAKE) $(HOSTPREFIX)/bin/glib-genmarshal
	rm -fr $(BUILD_TMP)/glib-$(GLIB_VER)
	$(UNTAR)/glib-$(GLIB_VER).tar.xz
	set -e; cd $(BUILD_TMP)/glib-$(GLIB_VER); \
		./autogen.sh; \
		echo "ac_cv_func_posix_getpwuid_r=yes" > config.cache; \
		echo "ac_cv_func_posix_getgrgid_r=ys" >> config.cache; \
		echo "glib_cv_stack_grows=no" >> config.cache; \
		echo "glib_cv_uscore=no" >> config.cache; \
		$(BUILDENV) \
		./configure \
			--cache-file=config.cache \
			--disable-gtk-doc \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-static=yes \
			--enable-shared=no \
			--with-html-dir=/.remove \
			--mandir=/.remove \
			--prefix= ;\
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX); \
			--prefix=/opt/pkg;\
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	set -e; cd $(PKGPREFIX)/opt/pkg/lib/pkgconfig; for i in *; do \
		mv $$i $(PKG_CONFIG_PATH); $(REWRITE_PKGCONF_OPT) $(PKG_CONFIG_PATH)/$$i; done
	rm -rf $(PKGPREFIX)/opt/pkg/share/locale # who needs localization?
	rm -f $(PKGPREFIX)/opt/pkg/bin/glib-mkenums # no perl available on the box
	sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX)/opt/pkg/lib'," $(PKGPREFIX)/opt/pkg/lib/*.la
	sed -i '/^dependency_libs=/{ s#/opt/pkg/lib#$(TARGETPREFIX)/opt/pkg/lib#g }' $(PKGPREFIX)/opt/pkg/lib/*.la
	rm -f $(PKGPREFIX)/opt/pkg/bin/gdbus
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cd $(PKGPREFIX)/opt/pkg && \
		rm -fr include lib/*.so lib/*.la share etc/bash_completion.d \
		bin/gtester-report bin/glib-gettextize
	rm -fr $(PKGPREFIX)/opt/pkg/lib/pkgconfig $(PKGPREFIX)/opt/pkg/etc
	PKG_VER=$(GLIB_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libglib
	$(REMOVE)/glib-$(GLIB_VER) $(PKGPREFIX)
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
		make install DESTDIR=$(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/libffi-$(LIBFFI_VER)
	touch $@

$(D)/gettext: $(ARCHIVE)/gettext-$(GETTEXT_VER).tar.gz $(D)/libiconv | $(TARGETPREFIX)
	$(UNTAR)/gettext-$(GETTEXT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/gettext-$(GETTEXT_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-java \
			--disable-native-java \
			--datarootdir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX)/GetText



$(D)/gnutls: $(ARCHIVE)/gnutls-$(GNUTLS_VER).tar.xz $(D)/nettle | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/gnutls-$(GNUTLS_VER)
	$(UNTAR)/gnutls-$(GNUTLS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gnutls-$(GNUTLS_VER); \
		$(CONFIGURE) \
			--prefix= \
			--with-included-libtasn1 \
			--with-libnettle-prefix=$(TARGETPREFIX) \
			--with-libz-prefix=$(TARGETPREFIX) \
			--mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX)/GNUTLS

#	rm -fr $(BUILD_TMP)/gnutls-$(GNUTLS_VER)
#	touch $@


$(D)/nettle: $(ARCHIVE)/nettle-$(NETTLE_VER).tar.gz $(D)/gmp | $(TARGETPREFIX)
	$(UNTAR)/nettle-$(NETTLE_VER).tar.gz
	set -e; cd $(BUILD_TMP)/nettle-$(NETTLE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-assembler \
			--disable-documentation\
			--mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/hogweed.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/nettle.pc
	rm -fr $(BUILD_TMP)/nettle-$(NETTLE_VER)
	touch $@



$(D)/gmp: $(ARCHIVE)/gmp-$(GMP_VER).tar.xz | $(TARGETPREFIX)
	$(UNTAR)/gmp-$(GMP_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gmp-$(GMP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--enable-cxx \
			--mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(BUILD_TMP)/TMP
	cp -frd $(BUILD_TMP)/TMP/include $(TARGETPREFIX)
	cp -frd $(BUILD_TMP)/TMP/lib $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/TMP
	rm -fr $(BUILD_TMP)/gmp-$(GMP_VER)
	touch $@


$(D)/samba3: $(ARCHIVE)/samba-$(SAMBA3_VER).tar.gz $(D)/libiconv | $(TARGETPREFIX)
#	$(UNTAR)/samba-$(SAMBA3_VER).tar.gz
	cd $(BUILD_TMP)/samba-$(SAMBA3_VER) && \
#		$(PATCH)/samba-3.3.9.diff && \
		cd source && \
		export CONFIG_SITE=$(PATCHES)/samba-3.3.9-config.site && \
#		./autogen.sh && \
#		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
#			--prefix=/ --mandir=/.remove \
#			--sysconfdir=/etc/samba \
#			--with-configdir=/etc/samba \
#			--with-privatedir=/etc/samba \
#			--with-modulesdir=/lib/samba \
#			--datadir=/var/samba \
#			--localstatedir=/var/samba \
#			--with-piddir=/tmp \
#			--with-libiconv=/lib \
#			--with-cifsumount --without-krb5 --without-ldap --without-ads --disable-cups --disable-swat \
#			&& \
#		$(MAKE) && \
#		$(MAKE) install DESTDIR=$(TARGETPREFIX)/Samba3; \
		$(MAKE) uninstallmo DESTDIR=$(TARGETPREFIX)/Samba3
#	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/XXX.pc
#	rm -f -r $(TARGETPREFIX)/.remove
#	$(REMOVE)/samba-$(SAMBA3_VER)
#	touch $@
