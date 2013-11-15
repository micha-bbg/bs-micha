
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
