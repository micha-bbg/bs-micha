# makefile to build crosstool

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL-NG_VER).tar.bz2
	make $(BUILD_TMP)
	mkdir -p $(CROSS_DIR)
	$(REMOVE)/crosstool-ng-$(CROSSTOOL-NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL-NG_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL-NG_VER); \
		if [ "$(PLATFORM)" = "nevis" ]; then \
			cp -a $(PATCHES)/nevis/crosstool-ng-nevis-$(CROSSTOOL-NG_VER)-1.config .config; \
		fi; \
		if [ "$(PLATFORM)" = "apollo" ]; then \
			cp -a $(PATCHES)/$(PLATFORM)/config-1.16-apollo-uclibc .config; \
			patch -p1 -i $(PATCHES)/$(PLATFORM)/config-1.19-apollo-uclibc.patch; \
		fi; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS -lt 1 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config
	$(MAKE) crosstool-$(PLATFORM)

crosstool-nevis: $(ARCHIVE)/linux-2.6.26.8.tar.bz2
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL-NG_VER); \
		cp $(PATCHES)/999-ppl-0_11_2-fix-configure-for-64bit-host.patch patches/ppl/0.11.2; \
		test "$(GIT_PROTOCOL)" = http && \
			sed -i 's#svn://svn.eglibc.org#http://www.eglibc.org/svn#' \
				scripts/build/libc/eglibc.sh || \
			true; \
		mkdir -p targets/src/; \
		tar -C targets/src/ -xf $(ARCHIVE)/linux-2.6.26.8.tar.bz2; \
		(cd targets/src/linux-2.6.26.8 && \
			patch -p1 -i $(PATCHES)/linux-2.6.26.8-new-make.patch && \
			patch -p1 -i $(PATCHES)/linux-2.6.26.8-rename-getline.patch); \
		ln -sf linux-2.6.26.8 targets/src/linux-custom; \
		touch targets/src/.linux-custom.extracted; \
		export CST_BASE_DIR=$(BASE_DIR); \
		export CST_BUILD_TMP=$(BUILD_TMP); \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/

#	$(REMOVE)/crosstool-ng-$(CROSSTOOL-NG_VER)

crosstool-apollo: $(ARCHIVE)/linux-2.6.34.tar.bz2
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL-NG_VER); \
		cp $(PATCHES)/999-ppl-0_11_2-fix-configure-for-64bit-host.patch patches/ppl/0.11.2; \
		cp $(PATCHES)/$(PLATFORM)/900-pull-socket_type-h-from-eglibc.patch patches/uClibc/0.9.33.2; \
		cp $(PATCHES)/$(PLATFORM)/901-gettimeofday.c-use-the-same-type-as-in-header.patch patches/uClibc/0.9.33.2; \
		if [ "$(KVERSION)" = "2.6.34.1300" ]; then \
			mkdir -p targets/src/; \
			tar -C targets/src/ -xf $(ARCHIVE)/linux-2.6.26.8.tar.bz2; \
			(cd targets/src/linux-2.6.26.8 && \
				patch -p1 -i $(PATCHES)/linux-2.6.26.8-new-make.patch && \
				patch -p1 -i $(PATCHES)/linux-2.6.26.8-rename-getline.patch); \
			ln -sf linux-2.6.26.8 targets/src/linux-custom; \
			touch targets/src/.linux-custom.extracted; \
		fi; \
		export CST_BASE_DIR=$(BASE_DIR); \
		export CST_BUILD_TMP=$(BUILD_TMP); \
		export CST_KERNEL_LINUX_CUSTOM=2.6.34; \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/

#	$(REMOVE)/crosstool-ng-$(CROSSTOOL-NG_VER)
