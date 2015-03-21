# makefile to build crosstool

## nevis crosstool ###############################################
ifeq ($(PLATFORM), nevis)

CT_NG_CONFIG  = $(PATCHES)/ct-ng-1.20/ct-ng-nevis-1.20.0-2.config
CUSTOM_KERNEL = $(ARCHIVE)/cst-kernel_2.6.34.13-cnxt_2012-12-09_1613_6ff43b3.tar.xz

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz $(CUSTOM_KERNEL)
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_DIR) ]; then \
		mkdir -p $(CROSS_DIR); \
	fi;
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		cp -a $(CT_NG_CONFIG) .config; \
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
		export CST_BASE_DIR=$(BASE_DIR); \
		export CST_CUSTOM_KERNEL=$(CUSTOM_KERNEL); \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/

else ## ifeq ($(PLATFORM), nevis)
## apollo / kronos crosstool ###############################################

ifeq ($(UCLIBC_BUILD), 1)
ifeq ($(USE_UCLIBC_NG), 1)
## build apollo/kronos uClibc-ng
CT_NG_CONFIG = $(PATCHES)/ct-ng-1.20/ct-ng-1.20.0-3.config
else
## build apollo/kronos uClibc
CT_NG_CONFIG = $(PATCHES)/ct-ng-1.20/ct-ng-1.20.0-2.config
endif ## ($(USE_UCLIBC_NG), 1)
else
## build apollo/kronos eglibc
CT_NG_CONFIG = $(PATCHES)/ct-ng-1.20/ct-ng-1.20.0-1-glibc.config
endif ## ifeq ($(UCLIBC_BUILD), 1)

CUSTOM_KERNEL = $(ARCHIVE)/cst-kernel_cst_3.10_2015-03-13_1913_a32e261.tar.xz

crosstool: $(CROSS_DIR)/bin/$(TARGET)-gcc

$(CROSS_DIR)/bin/$(TARGET)-gcc: $(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz $(CUSTOM_KERNEL)
	make $(BUILD_TMP)
	if [ ! -e $(CROSS_DIR) ]; then \
		mkdir -p $(CROSS_DIR); \
	fi;
	$(REMOVE)/crosstool-ng-$(CROSSTOOL_NG_VER)
	$(UNTAR)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz
	set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng-$(CROSSTOOL_NG_VER); \
		cp -a $(CT_NG_CONFIG) .config; \
		\
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS -lt 1 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		\
		if [ "$(UCLIBC_BUILD)" = "1" ]; then \
			cp $(PATCHES)/ct-ng-1.20/999-ppl-0_11_2-fix-configure-for-64bit-host.patch patches/ppl/0.11.2; \
			cp $(PATCHES)/ct-ng-1.20/900-pull-socket_type-h-from-eglibc.patch patches/uClibc/0.9.33.2; \
			cp $(PATCHES)/ct-ng-1.20/901-gettimeofday.c-use-the-same-type-as-in-header.patch patches/uClibc/0.9.33.2; \
			if [ "$(USE_UCLIBC_NG)" = "1" ]; then \
				export CST_UCLIBC_CONFIG="$(PATCHES)/ct-ng-1.20/ct-ng-uClibc-ng-1.0.1.config"; \
			else \
				export CST_UCLIBC_CONFIG="$(PATCHES)/ct-ng-1.20/ct-ng-uClibc-0.9.33.2.config"; \
			fi;\
		fi; \
		\
		export CST_BASE_DIR=$(BASE_DIR); \
		export CST_CUSTOM_KERNEL=$(CUSTOM_KERNEL); \
		if [ "$(USE_UCLIBC_NG)" = "1" ]; then \
			export CST_CUSTOM_UCLIBC=$(ARCHIVE)/uClibc-ng-1.0.1.tar.xz; \
		fi; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	ln -sf sys-root/lib $(CROSS_BASE)/$(TARGET)/

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
