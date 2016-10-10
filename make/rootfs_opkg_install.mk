
OPKG_CONF  = $(IMAGE_BASE)/opkg/opkg.conf
OPKG_CMD   = opkg --conf $(OPKG_CONF) --add-arch $(BOXARCH):10

OPKG_INSTALLS = \
	cs-libs \
	libdvbsi++ \
	openssl-libs \
	libz \
	librtmp \
	libcurl \
	curl \
	e2fsprogs \
	libiconv \
	libncurses \
	giflib \
	libjpeg-turbo \
	libpng \
	libxml2 \
	libarchive \
	opkg \
	lua \
	luaposix \
	libfreetype \
	libsigc++ \
	libpugixml \
	expat \
	procps \
	ntfs-3g \
	ffmpeg \
	libbluray \
	readline \
	parted \
	ntp \
	libOpenThreads \
	vsftpd \
	xupnpd \
	neutrino-hd

OPKG_EXTRA_INSTALLS = \
	fuse \
	exfat-utils \
	fuse-exfat \
	gdbserver \
	ncftp \
	openvpn \
	kernelcheck \
	logoview \
	rsync

OPKG_EXTRA_INSTALLS_MC = \
	libffi \
	libmount \
	libpcre \
	gettext \
	libglib \
	mc


opkg-make-opkg-conf:
	@test -d $(IMAGE_BASE)/opkg || mkdir -p $(IMAGE_BASE)/opkg
	@echo "option ignore_uid 1"                > $(OPKG_CONF)
	@echo "option offline_root $(IMAGE_ROOT)" >> $(OPKG_CONF)

pkg_path_loc = $(IMAGE_BASE)/opkg/$$(cat $(IMAGE_BASE)/opkg/.cache2/$(1))
pkg_path_sys = $(PACKAGE_DIR)/$$(cat $(PACKAGE_DIR)/.cache2/$(1))

opkg-install-base-pkgs: opkg-make-opkg-conf opkg-base-pkg opkg-kernel-pkg
	rm -fr $(IMAGE_ROOT); mkdir -p $(IMAGE_ROOT)
	@$(OPKG_CMD) install $(call pkg_path_loc,aaa_base_pkg)
	@$(OPKG_CMD) install $(call pkg_path_loc,kernel-modules)
	@$(OPKG_CMD) install $(call pkg_path_sys,busybox)
	@rm -fr $(IMAGE_ROOT)/sbin/findfs
	@rm -fr $(IMAGE_ROOT)/sbin/fsck
	@echo "Install base pkgs done."

opkg-install-image-pkgs: opkg-make-opkg-conf
	@for f in $(OPKG_INSTALLS); do \
		$(OPKG_CMD) install $(call pkg_path_sys,$$f); \
	done;
	echo "Install image pkgs done."

opkg-install-extra-pkgs: opkg-make-opkg-conf
	@for f in $(OPKG_EXTRA_INSTALLS); do \
		$(OPKG_CMD) install $(call pkg_path_sys,$$f); \
	done;
	@echo "Install extra pkgs done."

opkg-install-mc-pkgs: opkg-make-opkg-conf
	@for f in $(OPKG_EXTRA_INSTALLS_MC); do \
		$(OPKG_CMD) install $(call pkg_path_sys,$$f); \
	done;
	@echo "Install mc pkgs done."

opkg-clean-rootfs:
	rm -fr $(IMAGE_ROOT)

opkg-clean-all:
	rm -fr $(IMAGE_BASE)

opkg-rootfs: opkg-clean-rootfs opkg-install-base-pkgs opkg-install-image-pkgs

opkg-rootfs-all: opkg-rootfs opkg-install-extra-pkgs opkg-install-mc-pkgs

opkg-make-pkg-index:
	@cd $(PACKAGE_DIR); \
		rm -fr pkg; mkdir -p pkg; \
		cp *.opk pkg;\
		cd pkg; \
		P=Packages; \
		rm -f $${P}*; \
		opkg-make-index.sh . > $${P}; \
		cp $${P} $${P}.tmp; \
		gzip $${P}; \
		mv $${P}.tmp $${P}

opkg-test:
	@echo ""
	$(OPKG_CMD) $(M_CMD)
	@echo ""


## aaa_base:
# ld-uClibc.so.0
# libatomic.so.1
# libcrypt.so.0
# libdl.so.0
# libgcc_s.so.1
# libitm.so.1
# libm.so.0
# libpthread.so.0
# libresolv.so.0
# librt.so.0
# libstdc++.so.6
# libthread_db.so.1
# libc.so.0
# libutil.so.0
