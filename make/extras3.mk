
$(D)/gettext: $(ARCHIVE)/gettext-$(GETTEXT_VER).tar.xz | $(TARGETPREFIX)
	$(UNTAR)/gettext-$(GETTEXT_VER).tar.xz
	set -e; cd $(BUILD_TMP)/gettext-$(GETTEXT_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-java \
			--disable-native-java \
			--datarootdir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)



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


$(D)/samba3: $(ARCHIVE)/samba-$(SAMBA3_VER).tar.gz | $(TARGETPREFIX)
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
