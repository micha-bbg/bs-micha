
IMAGE_BASE     = $(BUILD_TMP)/install_opkg
IMAGE_ROOT     = $(IMAGE_BASE)/root
IMAGE_IMAGES   = $(IMAGE_BASE)/images
IMAGE_TMP_ROOT = $(IMAGE_BASE)/tmp_root
IMAGE_TMP      = $(IMAGE_BASE)/tmp
KERNEL_IMG     = $(BUILD_TMP)/kernel-img

opkg-base-pkg-1: opkg-base-pkg-prepare opkg-base-pkg-libc opkg-base-pkg-helpers
opkg-base-pkg-2: opkg-base-pkg-provides opkg-base-pkg-strip
opkg-base-pkg-3: opkg-base-pkg-firmware opkg-base-pkg-skelroot
opkg-base-pkg-4: opkg-base-pkg-opkg

opkg-base-pkg-prepare:
	rm -fr $(IMAGE_ROOT)
	mkdir -p $(IMAGE_ROOT)
	#
	rm -fr $(IMAGE_TMP)
	mkdir -p $(IMAGE_TMP)
	#
	rm -fr $(IMAGE_TMP_ROOT)
	mkdir -p $(IMAGE_TMP_ROOT)/bin
	mkdir -p $(IMAGE_TMP_ROOT)/etc
	mkdir -p $(IMAGE_TMP_ROOT)/lib
	mkdir -p $(IMAGE_TMP_ROOT)/sbin
	#
	rm -fr $(IMAGE_BASE)/control
	mkdir -p $(IMAGE_BASE)/control
	cp -frd $(CONTROL_DIR)/aaa_base_pkg $(IMAGE_BASE)/control
	#
	rm -fr $(IMAGE_BASE)/tmp
	mkdir -p $(IMAGE_BASE)/tmp
	#
	mkdir -p $(IMAGE_BASE)/opkg

opkg-base-pkg-skelroot:
	cp -frd $(BASE_DIR)/skel-root.opkg/common/. $(IMAGE_TMP_ROOT)
	cp -frd $(BASE_DIR)/skel-root.opkg/$(PLATFORM)/. $(IMAGE_TMP_ROOT)
	find $(IMAGE_TMP_ROOT) -name .gitignore -type f -print0 | xargs --no-run-if-empty -0 rm -f

opkg-base-pkg-libc:
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/usr/lib/libstdc++.so; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/usr/lib/libstdc++.s*[!y] $(IMAGE_TMP_ROOT)/lib; \
	fi
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(IMAGE_TMP_ROOT)/lib; \
		if test ! -h $(CROSS_DIR)/$(TARGET)/lib -a -d $(CROSS_DIR)/$(TARGET)/lib; then \
			cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(IMAGE_TMP_ROOT)/lib; \
		fi; \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(IMAGE_TMP_ROOT)/lib; \
	fi

opkg-base-pkg-helpers:
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/sbin/ldconfig $(IMAGE_TMP_ROOT)/sbin; \
		touch $(IMAGE_TMP_ROOT)/etc/ld.so.conf; \
	fi
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/usr/bin/ldd; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/usr/bin/ldd $(IMAGE_TMP_ROOT)/bin; \
	fi
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/usr/bin/iconv; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/usr/bin/iconv $(IMAGE_TMP_ROOT)/bin; \
	fi

opkg-base-pkg-firmware:
	cp -frd $(SOURCE_DIR)/$(SOURCE_DRIVERS)/$(PLATFORM)$(DRIVERS_3x)/firmware $(IMAGE_TMP_ROOT)/lib

opkg-base-pkg-strip:
	@echo ""
	@echo "--- stripping begin -----------------------------------------------------------"
	@du -sh $(IMAGE_TMP_ROOT)
	@find $(IMAGE_TMP_ROOT) -name .gitignore -type f -print0 | xargs --no-run-if-empty -0 rm -f
	@find $(IMAGE_TMP_ROOT)/lib \( -name '*.a' -o -name '*.la' \) -print0 | xargs --no-run-if-empty -0 rm -f
	@find $(IMAGE_TMP_ROOT)/bin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	@find $(IMAGE_TMP_ROOT)/lib -path $(IMAGE_TMP_ROOT)/lib/modules -prune -o -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	@find $(IMAGE_TMP_ROOT)/sbin -type f -print0 | xargs -0 $(TARGET)-strip 2>/dev/null || true
	@echo ""
	@du -sh $(IMAGE_TMP_ROOT)
	@echo "--- stripping end -------------------------------------------------------------"
	@echo ""

opkg-base-pkg-provides:
	PROV=""; \
	for f in $(IMAGE_TMP_ROOT)/lib/*; do \
		if test -f $$f -a ! -h $$f; then \
			PROV+=$$($(TARGET)-objdump -p $$f | awk '/^  SONAME/{print $$2}')" "; \
		fi; \
	done; \
	PROV=$$(echo $$PROV); \
	PROV=$${PROV// /, }; \
	sed -i "s/@PROV@/$$PROV/" $(IMAGE_BASE)/control/aaa_base_pkg/control

OPKG_IMG_ENV  = PACKAGE_DIR=$(IMAGE_BASE)/opkg
OPKG_IMG_ENV += STRIP=$(TARGET)-strip
OPKG_IMG_ENV += DONT_STRIP=1
OPKG_IMG_ENV += MAINTAINER="$(MAINTAINER)"
OPKG_IMG_ENV += ARCH=$(BOXARCH)
OPKG_IMG_ENV += SOURCE=$(IMAGE_TMP_ROOT)
OPKG_IMG_ENV += BUILD_TMP=$(BUILD_TMP)
OPKG_IMG_SH   = $(OPKG_IMG_ENV) opkg.sh

opkg-base-pkg-opkg:
	$(OPKG_IMG_SH) $(IMAGE_BASE)/control/aaa_base_pkg
	rm -fr $(IMAGE_BASE)/control

## -----------------------------------------------------------------------

opkg-kernel-modules-pkg-prepare:
	rm -fr $(IMAGE_TMP)
	mkdir -p $(IMAGE_TMP)
	rm -fr $(IMAGE_TMP_ROOT)
	mkdir -p $(IMAGE_TMP_ROOT)/lib/modules
	mkdir -p $(IMAGE_IMAGES)/kernel-$(KERNEL_BUILD)

opkg-kernel-modules-pkg-modules:
	cp -frd $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION) $(IMAGE_TMP_ROOT)/lib/modules

opkg-kernel-modules-pkg-opkg:
	PKG_VER=$(KERNEL_BUILD) \
		$(OPKG_IMG_SH) $(CONTROL_DIR)/kernel-modules
	rm -f $(PACKAGE_DIR)/kernel-modules-*.opk
	cp -f $(IMAGE_BASE)/opkg/kernel-modules-*.opk $(PACKAGE_DIR)

opkg-kernel-pkg-images:
	@if test ! -e $(KERNEL_IMG)/vmlinux.ub.gz -o ! -e $(KERNEL_IMG)/u-boot.bin -o ! -e $(KERNEL_IMG)/uldr.bin ; then \
		echo ""; \
		echo "Kernel images missing, exit..."; \
		echo ""; \
		false; \
	fi;
	rm -f $(IMAGE_IMAGES)/kernel-$(KERNEL_BUILD)/*
	cp -f $(KERNEL_IMG)/vmlinux.ub.gz $(IMAGE_IMAGES)/kernel-$(KERNEL_BUILD)
	cp -f $(KERNEL_IMG)/u-boot.bin $(IMAGE_IMAGES)/kernel-$(KERNEL_BUILD)
	cp -f $(KERNEL_IMG)/uldr.bin $(IMAGE_IMAGES)/kernel-$(KERNEL_BUILD)

## -----------------------------------------------------------------------

opkg-base-pkg: opkg-base-pkg-1 opkg-base-pkg-2 opkg-base-pkg-3 opkg-base-pkg-4
opkg-kernel-pkg: opkg-kernel-modules-pkg-prepare opkg-kernel-modules-pkg-modules opkg-kernel-pkg-images opkg-kernel-modules-pkg-opkg
