# makefile to build crosstool

## nevis crosstool ###############################################
ifeq ($(PLATFORM), nevis)

CT_NG_NEVIS_BINUTILS_VER = 2.23.2-2013.06

$(ARCHIVE)/binutils-linaro-$(CT_NG_NEVIS_BINUTILS_VER).tar.bz2:
	$(WGET) http://releases.linaro.org/13.06/components/toolchain/binutils-linaro/binutils-linaro-$(CT_NG_NEVIS_BINUTILS_VER).tar.bz2

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.bz2 $(ARCHIVE)/linux-2.6.26.8.tar.bz2 $(ARCHIVE)/binutils-linaro-$(CT_NG_NEVIS_BINUTILS_VER).tar.bz2
	make $(BUILD_TMP)
	mkdir -p $(CROSS_DIR)
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.bz2
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/ct-ng-1.20/ct-ng-nevis-$(CROSSTOOL_NG_VER)-1.config .config; \
		\
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS -lt 1 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		cp $(PATCHES)/ct-ng-1.20/999-ppl-0_11_2-fix-configure-for-64bit-host.patch patches/ppl/0.11.2; \
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
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/

#	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)

## apollo / kronos crosstool ###############################################
else ## ifeq ($(PLATFORM), nevis)

CT_NG_NEW_KERNEL_VER   = 3.0.67
CT_NG_NEW_BINUTILS_VER = 2.25.0-2015.01-2

$(ARCHIVE)/linux-$(CT_NG_NEW_KERNEL_VER).tar.bz2:
	$(WGET) https://www.kernel.org/pub/linux/kernel/v3.0/linux-$(CT_NG_NEW_KERNEL_VER).tar.bz2

$(ARCHIVE)/binutils-linaro-$(CT_NG_NEW_BINUTILS_VER).tar.xz:
	$(WGET) http://releases.linaro.org/15.01/components/toolchain/binutils-linaro/binutils-linaro-$(CT_NG_NEW_BINUTILS_VER).tar.xz

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.bz2 $(ARCHIVE)/linux-$(CT_NG_NEW_KERNEL_VER).tar.bz2 $(ARCHIVE)/binutils-linaro-$(CT_NG_NEW_BINUTILS_VER).tar.xz
	make $(BUILD_TMP)
	mkdir -p $(CROSS_DIR)
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.bz2
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/ct-ng-1.20/ct-ng-$(CROSSTOOL_NG_VER)-1.config .config; \
		\
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS -lt 1 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		cp $(PATCHES)/ct-ng-1.20/999-ppl-0_11_2-fix-configure-for-64bit-host.patch patches/ppl/0.11.2; \
		cp $(PATCHES)/ct-ng-1.20/900-pull-socket_type-h-from-eglibc.patch patches/uClibc/0.9.33.2; \
		cp $(PATCHES)/ct-ng-1.20/901-gettimeofday.c-use-the-same-type-as-in-header.patch patches/uClibc/0.9.33.2; \
		\
		export CST_BASE_DIR=$(BASE_DIR); \
		export CST_KERNEL_LINUX_CUSTOM=$(CT_NG_NEW_KERNEL_VER); \
		export CST_UCLIBC_CONFIG="$(PATCHES)/ct-ng-1.20/ct-ng-uClibc-0.9.33.2-config"; \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng build
	ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/

#		./ct-ng oldconfig; \

############################################

UCLIBC_VER = 0.9.33.2

$(ARCHIVE)/uClibc-$(UCLIBC_VER).tar.xz:
	$(WGET) http://www.uclibc.org/downloads/uClibc-$(UCLIBC_VER).tar.xz

uclibcmenuconfig: $(ARCHIVE)/uClibc-$(UCLIBC_VER).tar.xz
	make $(BUILD_TMP)
	$(UNTAR)/uClibc-$(UCLIBC_VER).tar.xz
	set -e; cd $(BUILD_TMP)/uClibc-$(UCLIBC_VER); \
		cp -a $(PATCHES)/ct-ng-1.20/ct-ng-uClibc-0.9.33.2-config .config; \
		make menuconfig

############################################

endif ## ifeq ($(PLATFORM), nevis)

############################################

crossmenuconfig: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.bz2
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.bz2
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		if [ "$(PLATFORM)" = "nevis" ]; then \
			cp -a $(PATCHES)/ct-ng-1.20/ct-ng-nevis-$(CROSSTOOL_NG_VER)-1.config .config; \
		else \
			cp -a $(PATCHES)/ct-ng-1.20/ct-ng-$(CROSSTOOL_NG_VER)-1.config .config; \
		fi; \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng menuconfig

############################################
