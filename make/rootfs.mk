
INSTALL = $(BUILD_TMP)/install
INSTALL_TMP = $(INSTALL)/_TMP_

ifeq ($(PLATFORM), apollo)

$(D)/rootfs:
	rm -rf $(INSTALL)
	mkdir -p $(INSTALL)

	cp -a $(BASE_DIR)/skel-root/common/* $(INSTALL)/
	cp -a $(BASE_DIR)/skel-root/$(PLATFORM)/* $(INSTALL)/

	cp -a $(TARGETPREFIX)/bin $(INSTALL)
	cp -a $(TARGETPREFIX)/etc $(INSTALL)
	cp -a $(TARGETPREFIX)/home $(INSTALL)
	cp -a $(TARGETPREFIX)/lib $(INSTALL)
	cp -a $(TARGETPREFIX)/mnt $(INSTALL)
	cp -a $(TARGETPREFIX)/opt $(INSTALL)
	cp -a $(TARGETPREFIX)/perf $(INSTALL)
	cp -a $(TARGETPREFIX)/proc $(INSTALL)
	cp -a $(TARGETPREFIX)/root $(INSTALL)
	cp -a $(TARGETPREFIX)/sbin $(INSTALL)
	cp -a $(TARGETPREFIX)/share $(INSTALL)
	cp -a $(TARGETPREFIX)/usr $(INSTALL)
	cp -a $(TARGETPREFIX)/var $(INSTALL)
	cp -a $(TARGETPREFIX)/video_app $(INSTALL)

	mkdir -p $(INSTALL)/dev $(INSTALL)/sys $(INSTALL)/tmp

	ln -s bin/busybox $(INSTALL)/linuxrc
#	ln -s usr/share $(INSTALL)/share

	rm -fr $(INSTALL)/lib/engines
	rm -fr $(INSTALL)/lib/pkgconfig

	## last neutrino pkg
	mkdir -p $(INSTALL_TMP)/data
	cp -f $(PACKAGE_DIR)/neutrino-hd*.opk $(INSTALL_TMP)
	cd $(INSTALL_TMP); \
		ar -x neutrino-hd*.opk; \
		tar -C $(INSTALL_TMP)/data -xf data.tar.gz; \
		cp -frd $(INSTALL_TMP)/data/* $(INSTALL); \
		cp -f $(INSTALL_TMP)/data/.version $(INSTALL)
	cd $(INSTALL); \
	rm -fr $(INSTALL_TMP)

	find $(INSTALL) -name .gitignore -type f -print0 | xargs --no-run-if-empty -0 rm -f
	find $(INSTALL)/lib \( -name '*.a' -o -name '*.la' \) -print0 | xargs --no-run-if-empty -0 rm -f
	@echo ""
	du -sh $(INSTALL)
	@echo ""
	find $(INSTALL)/bin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/opt -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/sbin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/usr -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/lib -path $(INSTALL)/lib/modules -prune -o -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/var/bin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/var/sbin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	@echo ""
	du -sh $(INSTALL)

endif # ($(PLATFORM), apollo)

ifeq ($(PLATFORM), nevis)

$(D)/rootfs:
	rm -rf $(INSTALL)
	mkdir -p $(INSTALL)

	cp -a $(BASE_DIR)/skel-root/common/* $(INSTALL)/
	cp -a $(BASE_DIR)/skel-root/$(PLATFORM)/* $(INSTALL)/

	cp -a $(TARGETPREFIX)/bin $(INSTALL)
	cp -a $(TARGETPREFIX)/etc $(INSTALL)
	cp -a $(TARGETPREFIX)/lib $(INSTALL)
	cp -a $(TARGETPREFIX)/mnt $(INSTALL)
	cp -a $(TARGETPREFIX)/opt $(INSTALL)
	cp -a $(TARGETPREFIX)/proc $(INSTALL)
	cp -a $(TARGETPREFIX)/root $(INSTALL)
	cp -a $(TARGETPREFIX)/sbin $(INSTALL)
	cp -a $(TARGETPREFIX)/usr $(INSTALL)
	cp -a $(TARGETPREFIX)/var $(INSTALL)

	mkdir -p $(INSTALL)/dev $(INSTALL)/sys $(INSTALL)/tmp
	ln -s usr/share $(INSTALL)/share

	rm -fr $(INSTALL)/lib/engines
	rm -fr $(INSTALL)/lib/pkgconfig

	## last neutrino pkg
	mkdir -p $(INSTALL_TMP)/data
	cp -f $(PACKAGE_DIR)/neutrino-hd*.opk $(INSTALL_TMP)
	cd $(INSTALL_TMP); \
		ar -x neutrino-hd*.opk; \
		tar -C $(INSTALL_TMP)/data -xf data.tar.gz; \
		cp -frd $(INSTALL_TMP)/data/* $(INSTALL); \
		cp -f $(INSTALL_TMP)/data/.version $(INSTALL)
	cd $(INSTALL); \
	rm -fr $(INSTALL_TMP)

	find $(INSTALL) -name .gitignore -type f -print0 | xargs --no-run-if-empty -0 rm -f
	find $(INSTALL)/lib \( -name '*.a' -o -name '*.la' \) -print0 | xargs --no-run-if-empty -0 rm -f
	@echo ""
	du -sh $(INSTALL)
	@echo ""
	find $(INSTALL)/bin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/opt -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/sbin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/usr -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/lib -path $(INSTALL)/lib/modules -prune -o -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/var/bin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	find $(INSTALL)/var/sbin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	@echo ""
	du -sh $(INSTALL)

endif # ($(PLATFORM), nevis)
