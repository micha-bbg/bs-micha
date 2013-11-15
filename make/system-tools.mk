# Makefile to build system tools

$(D)/vsftpd: $(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/vsftpd-$(VSFTPD_VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/vsftpd-$(VSFTPD_VER); \
		$(PATCH)/vsftpd.diff; \
		make clean; \
		TARGETPREFIX=$(TARGETPREFIX) make CC=$(TARGET)-gcc CFLAGS="-pipe -O2 -g0 -I$(TARGETPREFIX)/include" LDFLAGS="$(LD_FLAGS) -Wl,-rpath-link,$(TARGETLIB)"
	install -d $(PKGPREFIX)/share/empty
	install -D -m 755 $(BUILD_TMP)/vsftpd-$(VSFTPD_VER)/vsftpd $(PKGPREFIX)/sbin/vsftpd
	install -D -m 644 $(SCRIPTS)/vsftpd.conf $(PKGPREFIX)/etc/vsftpd.conf
	install -D -m 644 $(SCRIPTS)/banner.ftp $(PKGPREFIX)/etc/banner.ftp
	install -D -m 755 $(SCRIPTS)/vsftpd.init $(PKGPREFIX)/etc/init.d/vsftpd
	# it is important that vsftpd is started *before* inetd to override busybox ftpd...
	ln -sf vsftpd $(PKGPREFIX)/etc/init.d/S53vsftpd
	cp -frd $(PKGPREFIX)/share/* $(TARGETPREFIX)/share
	rm -fr $(PKGPREFIX)/share
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)/
	$(OPKG_SH) $(CONTROL_DIR)/vsftpd
	$(REMOVE)/vsftpd-$(VSFTPD_VER) $(PKGPREFIX)
	touch $@

$(D)/rsync: $(ARCHIVE)/rsync-$(RSYNC_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/rsync-$(RSYNC_VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/rsync-$(RSYNC_VER); \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --mandir=$(BUILD_TMP)/.remove; \
		$(MAKE) all; \
		make install prefix=$(PKGPREFIX)
	$(REMOVE)/rsync-$(RSYNC_VER) $(BUILD_TMP)/.remove
	install -D -m 0755 $(SCRIPTS)/rsyncd.init $(PKGPREFIX)/etc/init.d/rsyncd
	ln -sf rsyncd $(PKGPREFIX)/etc/init.d/K40rsyncd
	ln -sf rsyncd $(PKGPREFIX)/etc/init.d/S60rsyncd
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cd $(TARGETPREFIX)/etc && { \
		test -e rsyncd.conf    || cp $(SCRIPTS)/rsyncd.conf . ; \
		test -e rsyncd.secrets || cp $(SCRIPTS)/rsyncd.secrets . ; }; true
	cp -a $(SCRIPTS)/rsyncd.{conf,secrets} $(PKGPREFIX)/etc
	$(OPKG_SH) $(CONTROL_DIR)/rsync
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/procps: $(D)/libncurses $(ARCHIVE)/procps-$(PROCPS_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/procps-$(PROCPS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/procps-$(PROCPS_VER); \
		$(PATCH)/procps-3.2.8-avoid-ICE-with-gcc-4.3.2-arm.diff; \
		$(PATCH)/procps-3.2.8-fix-unknown-HZ-compatible.diff; \
		make CC=$(TARGET)-gcc LDFLAGS="$(LD_FLAGS)" \
			CPPFLAGS="-pipe -O2 -g -I$(TARGETPREFIX)/include -I$(TARGETPREFIX)/include/ncurses -D__GNU_LIBRARY__" proc/libproc-$(PROCPS_VER).so; \
		make CC=$(TARGET)-gcc LDFLAGS="$(LD_FLAGS) proc/libproc-$(PROCPS_VER).so" \
			CPPFLAGS="-pipe -O2 -g -I$(TARGETPREFIX)/include -I$(TARGETPREFIX)/include/ncurses -D__GNU_LIBRARY__" top ps/ps; \
		mkdir -p $(TARGETPREFIX)/bin; \
		rm -f $(TARGETPREFIX)/bin/ps $(TARGETPREFIX)/bin/top; \
		install -m 755 top ps/ps $(TARGETPREFIX)/bin; \
		install -m 755 proc/libproc-$(PROCPS_VER).so $(TARGETPREFIX)/lib
	$(REMOVE)/procps-$(PROCPS_VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib $(PKGPREFIX)/bin
	cp -a $(TARGETPREFIX)/bin/{ps,top} $(PKGPREFIX)/bin
	cp -a $(TARGETPREFIX)/lib/libproc-$(PROCPS_VER).so $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/procps
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/busybox: $(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2 | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/busybox-$(BUSYBOX_VER)
	$(UNTAR)/busybox-$(BUSYBOX_VER).tar.bz2
	rm -rf $(PKGPREFIX) $(BUILD_TMP)/bb-control
	set -e; cd $(BUILD_TMP)/busybox-$(BUSYBOX_VER); \
	\
		$(PATCH)/bb_fixes-1.21.0/busybox-1.21.0-mdev.patch; \
		$(PATCH)/bb_fixes-1.21.0/busybox-1.21.0-platform.patch; \
		$(PATCH)/bb_fixes-1.21.0/busybox-1.21.0-xz.patch; \
		$(PATCH)/bb_fixes-1.21.0/busybox-1.21.0-ntfs.patch; \
	\
		$(PATCH)/busybox-1.18-hack-init-s-console.patch; \
		$(PATCH)/busybox-mdev-1.21.c.diff; \
		$(PATCH)/busybox-1.20-ifupdown.c.diff; \
		cp $(PATCHES)/$(PLATFORM)/busybox-$(PLATFORM)-1.21.config .config; \
		sed -i -e 's#^CONFIG_PREFIX.*#CONFIG_PREFIX="$(PKGPREFIX)"#' .config; \
		grep -q DBB_BT=AUTOCONF_TIMESTAMP Makefile.flags && \
		sed -i 's#AUTOCONF_TIMESTAMP#"\\"$(PLATFORM)\\""#' Makefile.flags || true; \
		$(MAKE) busybox CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"; \
		make install CROSS_COMPILE=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	install -m 0755 $(SCRIPTS)/run-parts $(PKGPREFIX)/bin
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cp -a $(CONTROL_DIR)/busybox $(BUILD_TMP)/bb-control
	# "auto-provides/conflicts". let's hope opkg can deal with this...
	printf "Provides:" >> $(BUILD_TMP)/bb-control/control
	for i in `find $(PKGPREFIX)/ ! -type d ! -name busybox`; do printf " `basename $$i`," >> $(BUILD_TMP)/bb-control/control; done
	sed -i 's/,$$//' $(BUILD_TMP)/bb-control/control
	sed -i 's/\(^Provides:\)\(.*$$\)/\1\2\nConflicts:\2/' $(BUILD_TMP)/bb-control/control
	echo >> $(BUILD_TMP)/bb-control/control
	PKG_VER=$(BUSYBOX_VER) $(OPKG_SH) $(BUILD_TMP)/bb-control
	$(REMOVE)/busybox-$(BUSYBOX_VER) $(PKGPREFIX) $(BUILD_TMP)/bb-control
	touch $@

$(D)/e2fsprogs: $(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/e2fsprogs-$(E2FSPROGS_VER).tar.gz
	set -e; cd $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER); \
		ln -sf /bin/true ./ldconfig; \
		CC=$(TARGET)-gcc \
		RANLIB=$(TARGET)-ranlib \
		CFLAGS="-Os" \
		PATH=$(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER):$(PATH) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=/ \
			--infodir=/.remove \
			--mandir=/.remove \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-debugfs \
			--disable-imager \
			--disable-resizer \
			--disable-uuidd \
			--enable-fsck \
			--disable-defrag \
			--with-gnu-ld \
			--enable-symlink-install \
			--disable-nls; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(PKGPREFIX); \
		$(MAKE) -C lib/uuid  install DESTDIR=$(PKGPREFIX); \
		$(MAKE) -C lib/blkid install DESTDIR=$(PKGPREFIX); \
		:
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER) $(PKGPREFIX)/.remove
	cp -a --remove-destination $(PKGPREFIX)/* $(TARGETPREFIX)/
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/blkid.pc
	cd $(PKGPREFIX) && rm sbin/badblocks sbin/dumpe2fs sbin/blkid sbin/logsave \
		sbin/e2undo sbin/filefrag sbin/e2freefrag bin/chattr bin/lsattr bin/uuidgen \
		lib/*.so && rm -r lib/pkgconfig include && rm -f lib/*.a
	PKG_VER=$(E2FSPROGS_VER) $(OPKG_SH) $(CONTROL_DIR)/e2fsprogs
	rm -rf $(PKGPREFIX)
	touch $@

$(TARGETPREFIX)/lib/libuuid.so.1:
	@echo
	@echo "to build libuuid.so.1, you have to build either the 'e2fsprogs'"
	@echo "or the 'libuuid' target. Using 'e2fsprogs' is recommended."
	@echo
	@false

$(D)/ntfs-3g: $(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz | $(TARGETPREFIX)
	$(UNTAR)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz
	set -e; cd $(BUILD_TMP)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER); \
		CFLAGS="-pipe -O2 -g" ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-ldconfig \
			--disable-ntfsprogs \
			--disable-static \
			; \
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER) $(PKGPREFIX)/.remove
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -r $(PKGPREFIX)/include $(PKGPREFIX)/lib/*.la $(PKGPREFIX)/lib/*.so \
		$(PKGPREFIX)/lib/pkgconfig/ $(PKGPREFIX)/bin/ntfs-3g.{usermap,secaudit}
	find $(PKGPREFIX) -name '*lowntfs*' | xargs rm
	PKG_VER=$(NTFS_3G_VER) \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/ntfs-3g
	rm -rf $(PKGPREFIX)
	touch $@

ifeq ($(PLATFORM), apollo)
SMB_PREFIX=/usr
else
SMB_PREFIX=/opt/pkg
endif
$(D)/samba2: $(ARCHIVE)/samba-$(SAMBA2_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/samba-$(SAMBA2_VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/samba-$(SAMBA2_VER); \
		$(PATCH)/samba_2.2.12.diff; \
		$(PATCH)/samba_2.2.12-noprint.diff; \
		cd source; \
		rm -f config.guess; \
		rm -f config.sub; \
		autoconf configure.in > configure; \
		automake --add-missing || true; \
		./configure \
			--build=$(BUILD) \
			--prefix=$(SMB_PREFIX) \
			samba_cv_struct_timespec=yes \
			samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
			--with-configdir=$(SMB_PREFIX)/etc \
			--with-privatedir=$(SMB_PREFIX)/etc/samba/private \
			--with-lockdir=/var/lock \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log/ \
			--disable-cups \
			--with-swatdir=$(PKGPREFIX)/swat; \
		$(MAKE) clean || true; \
		$(MAKE) bin/make_smbcodepage bin/make_unicodemap CC=$(CC); \
		install -d $(PKGPREFIX)$(SMB_PREFIX)/lib/codepages; \
		./bin/make_smbcodepage c 850 codepages/codepage_def.850 \
			$(PKGPREFIX)$(SMB_PREFIX)/lib/codepages/codepage.850; \
		./bin/make_unicodemap 850 codepages/CP850.TXT \
			$(PKGPREFIX)$(SMB_PREFIX)/lib/codepages/unicode_map.850; \
		./bin/make_unicodemap ISO8859-1 codepages/CPISO8859-1.TXT \
			$(PKGPREFIX)$(SMB_PREFIX)/lib/codepages/unicode_map.ISO8859-1
	$(MAKE) -C $(BUILD_TMP)/samba-$(SAMBA2_VER)/source distclean
	set -e; cd $(BUILD_TMP)/samba-$(SAMBA2_VER)/source; \
		$(BUILDENV) \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=$(SMB_PREFIX) \
			samba_cv_struct_timespec=yes \
			samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
			samba_cv_HAVE_IFACE_IFCONF=yes \
			samba_cv_HAVE_EXPLICIT_LARGEFILE_SUPPORT=yes \
			samba_cv_HAVE_OFF64_T=yes \
			samba_cv_have_longlong=yes \
			--with-configdir=$(SMB_PREFIX)/etc \
			--with-privatedir=$(SMB_PREFIX)/etc/samba/private \
			--with-lockdir=/var/lock \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log/ \
			--disable-cups \
			--with-swatdir=$(PKGPREFIX)/swat \
			; \
		$(MAKE) bin/smbd bin/nmbd bin/smbclient bin/smbmount bin/smbmnt bin/smbpasswd
	install -d $(PKGPREFIX)$(SMB_PREFIX)/bin
	for i in smbd nmbd; do \
		install $(BUILD_TMP)/samba-$(SAMBA2_VER)/source/bin/$$i $(PKGPREFIX)$(SMB_PREFIX)/bin; \
	done
	install -d $(PKGPREFIX)$(SMB_PREFIX)/etc/samba/private
	install -d $(PKGPREFIX)$(SMB_PREFIX)/etc/init.d
	install $(SCRIPTS)/smb.conf $(PKGPREFIX)$(SMB_PREFIX)/etc
	install -m 755 $(SCRIPTS)/samba2.init $(PKGPREFIX)$(SMB_PREFIX)/etc/init.d/samba
	ln -s samba $(PKGPREFIX)$(SMB_PREFIX)/etc/init.d/S99samba
	ln -s samba $(PKGPREFIX)$(SMB_PREFIX)/etc/init.d/K01samba
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(TARGET)-strip $(PKGPREFIX)$(SMB_PREFIX)/bin/*
	DONT_STRIP=1 $(OPKG_SH) $(CONTROL_DIR)/samba2/server
	rm -rf $(PKGPREFIX)/*
	install -d $(PKGPREFIX)$(SMB_PREFIX)/bin
	for i in smbclient smbmount smbmnt smbpasswd; do \
		install $(BUILD_TMP)/samba-$(SAMBA2_VER)/source/bin/$$i $(PKGPREFIX)$(SMB_PREFIX)/bin; \
	done
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(OPKG_SH) $(CONTROL_DIR)/samba2/client
	$(REMOVE)/samba-$(SAMBA2_VER) $(PKGPREFIX)
	touch $@

$(D)/portmap: $(ARCHIVE)/portmap-$(PORTMAP-VER).tgz
	$(UNTAR)/portmap-$(PORTMAP-VER).tgz
	set -e; cd $(BUILD_TMP)/portmap_$(PORTMAP-VER); \
		$(PATCH)/portmap_6.0-nocheckport.diff; \
		$(BUILDENV) $(MAKE) NO_TCP_WRAPPER=1 DAEMON_UID=65534 DAEMON_GID=65535 CC="$(TARGET)-gcc"; \
		install -m 0755 portmap $(TARGETPREFIX)/sbin; \
		install -m 0755 pmap_dump $(TARGETPREFIX)/sbin; \
		install -m 0755 pmap_set $(TARGETPREFIX)/sbin
	$(REMOVE)/portmap_$(PORTMAP-VER)
	touch $@

$(D)/unfsd: $(D)/libflex $(D)/portmap $(ARCHIVE)/unfs3-$(UNFS3-VER).tar.gz
	$(UNTAR)/unfs3-$(UNFS3-VER).tar.gz
	set -e; cd $(BUILD_TMP)/unfs3-$(UNFS3-VER); \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix= --mandir=/.remove; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -f -r $(TARGETPREFIX)/.remove
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/sbin
	install -m 755 -D $(SCRIPTS)/nfsd.init $(TARGETPREFIX)/etc/init.d/nfsd
	install -m 755 -D $(SCRIPTS)/nfsd.init $(PKGPREFIX)/etc/init.d/nfsd
	ln -s nfsd $(PKGPREFIX)/etc/init.d/S99nfsd # needs to start after modules are loaded
	ln -s nfsd $(PKGPREFIX)/etc/init.d/K01nfsd
	cp -a $(TARGETPREFIX)/sbin/{unfsd,portmap} $(PKGPREFIX)/sbin
	$(OPKG_SH) $(CONTROL_DIR)/unfsd
	$(REMOVE)/unfs3-$(UNFS3-VER) $(PKGPREFIX)
	touch $@

$(D)/fbshot: $(TARGETPREFIX)/bin/fbshot
	touch $@

$(TARGETPREFIX)/bin/fbshot: $(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz $(PATCHES)/fbshot-0.3-32bit_cs_fb.diff $(D)/libpng | $(TARGETPREFIX)
	$(UNTAR)/fbshot-$(FBSHOT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/fbshot-$(FBSHOT_VER); \
		$(PATCH)/fbshot-0.3-32bit_cs_fb.diff; \
		if [ $(PNG_VER_X) -gt 12 ]; then \
			$(PATCH)/fbshot-zlib.diff; \
		fi; \
		$(TARGET)-gcc -DHW_$(PLATFORM) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) fbshot.c -lpng -lz -o $@
	$(REMOVE)/fbshot-$(FBSHOT_VER)

# old valgrind for TD with old toolchain (linuxthreads glibc)
$(D)/valgrind-old: $(ARCHIVE)/valgrind-3.3.1.tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/valgrind-3.3.1.tar.bz2
	set -e; cd $(BUILD_TMP)/valgrind-3.3.1; \
		export ac_cv_path_GDB=/opt/pkg/bin/gdb; \
		export AR=$(TARGET)-ar; \
		$(CONFIGURE) --prefix=/ --enable-only32bit --enable-tls; \
		make all; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/valgrind-3.3.1
	touch $@

ifeq ($(BOXARCH), arm)
VALGRIND_EXTRA_EXPORT = export ac_cv_host=armv7-unknown-linux-gnueabi
else
VALGRIND_EXTRA_EXPORT = :
endif
# newer valgrind is probably only usable with external toolchain and newer glibc (posix threads)
$(DEPDIR)/valgrind: $(ARCHIVE)/valgrind-$(VALGRIND_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/valgrind-$(VALGRIND_VER).tar.bz2
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/valgrind-$(VALGRIND_VER); \
		export ac_cv_path_GDB=/opt/pkg/bin/gdb; \
		$(VALGRIND_EXTRA_EXPORT); \
		export AR=$(TARGET)-ar; \
		$(CONFIGURE) --prefix=/opt/pkg --enable-only32bit --mandir=/.remove --datadir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	mv $(PKGPREFIX)/opt/pkg/lib/pkgconfig/* $(PKG_CONFIG_PATH)
	$(REWRITE_PKGCONF_OPT) $(PKG_CONFIG_PATH)/valgrind.pc
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)/opt/pkg/include $(PKGPREFIX)/opt/pkg/lib/pkconfig
	rm -rf $(PKGPREFIX)/opt/pkg/lib/valgrind/*.a
	rm -rf $(PKGPREFIX)/opt/pkg/bin/{cg_*,callgrind_*,ms_print} # perl scripts - we don't have perl
	PKG_VER=$(VALGRIND_VER) $(OPKG_SH) $(CONTROL_DIR)/valgrind
	$(REMOVE)/valgrind-$(VALGRIND_VER) $(PKGPREFIX)
	touch $@

$(D)/iperf: $(ARCHIVE)/iperf-$(IPERF-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/iperf-$(IPERF-VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/iperf-$(IPERF-VER); \
		ac_cv_func_malloc_0_nonnull=yes \
		$(BUILDENV) ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=/opt/pkg \
			--mandir=/.remove \
			; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove
	install -D -m 0755 $(PKGPREFIX)/opt/pkg/bin/iperf $(TARGETPREFIX)/opt/pkg/bin/iperf
	PKG_VER=$(IPERF-VER) $(OPKG_SH) $(CONTROL_DIR)/iperf
	$(REMOVE)/iperf-$(IPERF-VER) $(PKGPREFIX)
	touch $@

$(D)/tcpdump: $(D)/libpcap $(ARCHIVE)/tcpdump-$(TCPDUMP-VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/tcpdump-$(TCPDUMP-VER).tar.gz
	set -e; cd $(BUILD_TMP)/tcpdump-$(TCPDUMP-VER); \
		cp -a $(PATCHES)/ppi.h .; \
		echo "ac_cv_linux_vers=2" >> config.cache ; \
		$(CONFIGURE) --prefix= --disable-smb --without-crypto -C --mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove $(PKGPREFIX)/sbin/tcpdump.*
	PKG_VER=$(TCPDUMP-VER) $(OPKG_SH) $(CONTROL_DIR)/tcpdump
	$(REMOVE)/tcpdump-$(TCPDUMP-VER) $(PKGPREFIX)
	touch $@

$(D)/ntp: $(ARCHIVE)/ntp-$(NTP_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/ntp-$(NTP_VER).tar.gz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/ntp-$(NTP_VER); \
		$(PATCH)/ntp-remove-buildtime.patch; \
		$(BUILDENV) ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix= \
			--disable-tick \
			--disable-tickadj \
			; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
	cp -a $(PKGPREFIX)/bin/ntpdate $(TARGETPREFIX)/sbin/
	mv -v $(PKGPREFIX)/bin/ntpdate $(PKGPREFIX)/sbin/
	rm $(PKGPREFIX)/bin/*
	rm -rf $(PKGPREFIX)/share
	PKG_VER=$(NTP_VER) $(OPKG_SH) $(CONTROL_DIR)/ntp
	$(REMOVE)/ntp-$(NTP_VER) $(PKGPREFIX)
	touch $@

$(D)/wget: $(D)/e2fsprogs $(ARCHIVE)/wget-$(WGET_VER).tar.xz | $(TARGETPREFIX)
	$(UNTAR)/wget-$(WGET_VER).tar.xz
	rm -rf $(PKGPREFIX)
	set -e; cd $(BUILD_TMP)/wget-$(WGET_VER); \
		ac_cv_path_POD2MAN=no \
		$(BUILDENV) ./configure \
			--disable-nls \
			--disable-opie \
			--disable-digest \
			--without-ssl \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE) install DESTDIR=$(PKGPREFIX)
		rm -f $(TARGETPREFIX)/bin/wget; \
		cp -a $(PKGPREFIX)/bin/wget $(TARGETPREFIX)/bin && \
		$(TARGET)-strip $(TARGETPREFIX)/bin/wget
	rm -rf $(PKGPREFIX)/share $(PKGPREFIX)/etc
	PKG_VER=$(WGET_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/wget
	$(REMOVE)/wget-$(WGET_VER) $(PKGPREFIX)
	touch $@

system-tools: $(D)/rsync $(D)/procps $(D)/busybox $(D)/e2fsprogs $(D)/vsftpd $(D)/wget $(D)/ntfs-3g
system-tools-opt: $(D)/samba2 $(D)/ntp
system-tools-all: system-tools system-tools-opt

PHONY += system-tools system-tools-opt system-tools-all
