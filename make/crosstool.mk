# makefile to build crosstool

ifeq ($(PLATFORM), nevis)
CROSSTOOL_NG_VER = $(CT_VER_NEVIS)
endif

ifeq ($(PLATFORM), apollo)
CROSSTOOL_NG_VER = $(CT_VER_APOLLO)
endif

ifeq ($(PLATFORM), kronos)
CROSSTOOL_NG_VER = $(CT_VER_KRONOS)
endif

## nevis crosstool ###############################################
ifeq ($(PLATFORM), nevis)

CT_NG_CONFIG  = $(PATCHES)/ct-ng-1.20/ct-ng-nevis-1.20.0-2.config
#CUSTOM_KERNEL = $(ARCHIVE)/cst-kernel_2.6.34.13-cnxt_2012-12-09_1613_6ff43b3.tar.xz
CUSTOM_KERNEL = $(ARCHIVE)/linux-2.6.26.8.tar.bz2
CUSTOM_GCC_VER = linaro-4.9-2015.06
CUSTOM_GCC     = $(ARCHIVE)/gcc-$(CUSTOM_GCC_VER).tar.xz

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz $(CUSTOM_KERNEL)
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_DIR) ]; then \
		mkdir -p $(CROSS_DIR); \
	fi;
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		\
		tar -xf $(PATCHES)/ct-ng-1.20/libstdc++_configure_patch.tar.xz; \
		mkdir -p patches/gcc/custom; \
		cp -a patches/gcc/$(CUSTOM_GCC_VER)/* patches/gcc/custom; \
		cp -a $(CT_NG_CONFIG) .config; \
		\
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS -lt 1 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		mkdir -p targets/src/; \
		tar -C targets/src/ -xf $(CUSTOM_KERNEL); \
		(cd targets/src/linux-2.6.26.8 && \
			patch -p1 -i $(PATCHES)/kernel/linux-2.6.26.8-new-make.patch && \
			patch -p1 -i $(PATCHES)/kernel/linux-2.6.26.8-rename-getline.patch); \
		ln -sf linux-2.6.26.8 targets/src/linux-custom; \
		touch targets/src/.linux-custom.extracted; \
		\
		export CST_BASE_DIR=$(BASE_DIR); \
		export CST_CUSTOM_KERNEL=$(CUSTOM_KERNEL); \
		export CST_CUSTOM_GCC=$(CUSTOM_GCC); \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/

else ## ifeq ($(PLATFORM), nevis)
## apollo / kronos crosstool ###############################################

CT_NG_CONFIG      = $(PATCHES)/ct-ng-1.20/ct-ng-1.22.0-1.config
CUSTOM_KERNEL_VER = cst-kernel_cst_3.10_2015-10-17_0818_6b9df41
CUSTOM_KERNEL     = $(ARCHIVE)/linux-$(CUSTOM_KERNEL_VER).tar.xz
CUSTOM_GCC_VER    = linaro-5.2-2015.11-2
CUSTOM_GCC        = $(ARCHIVE)/gcc-$(CUSTOM_GCC_VER).tar.xz

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz $(ARCHIVE)/$(CUSTOM_KERNEL_VER).tar.xz $(ARCHIVE)/gcc-$(CUSTOM_GCC_VER).tar.xz
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_DIR) ]; then \
		mkdir -p $(CROSS_DIR); \
	fi;
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	mkdir -p $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER)/targets/src
	# Don't patch a custom source from ct-ng, it's custom!
	cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER)/targets; \
		tar -xf $(PATCHES)/ct-ng-1.20/libstdc++_configure_patch.tar.xz && \
		cd src && \
		touch .gcc-$(CUSTOM_GCC_VER).extracting && \
		tar -xf $(CUSTOM_GCC) && \
		rm -f .gcc-$(CUSTOM_GCC_VER).extracting && \
		touch .gcc-$(CUSTOM_GCC_VER).extracted && \
		cd gcc-$(CUSTOM_GCC_VER) && \
		patch -p1 < $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER)/targets/patches/gcc/$(CUSTOM_GCC_VER)/900-libstdc++_configure.patch && \
		cd .. && \
		touch .gcc-$(CUSTOM_GCC_VER).patched
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		\
		ln -sf $(CUSTOM_KERNEL_VER).tar.xz $(CUSTOM_KERNEL); \
		cp -a $(CT_NG_CONFIG) .config; \
		\
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS -lt 1 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		cp $(PATCHES)/ct-ng-1.20/900-pull-socket_type-h-from-eglibc.patch patches/uClibc/0.9.33.2; \
		cp $(PATCHES)/ct-ng-1.20/901-gettimeofday.c-use-the-same-type-as-in-header.patch patches/uClibc/0.9.33.2; \
		export CST_UCLIBC_CONFIG="$(PATCHES)/ct-ng-1.20/ct-ng-uClibc-0.9.33.2.config"; \
		\
		export CST_BASE_DIR=$(BASE_DIR); \
		export CST_CUSTOM_KERNEL=$(CUSTOM_KERNEL); \
		export CST_CUSTOM_GCC=$(CUSTOM_GCC); \
		export CST_CUSTOM_GCC_VER=$(CUSTOM_GCC_VER); \
		export LD_LIBRARY_PATH=; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/

############################################

endif ## ifeq ($(PLATFORM), nevis)

############################################

crossmenuconfig: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		cp -a $(CT_NG_CONFIG) .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng menuconfig

############################################
