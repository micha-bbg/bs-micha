
ifeq ($(PLATFORM), nevis)
## nevis kernel
KERNEL_CONFIG = $(PATCHES)/kernel/$(PLATFORM)-$(KVERSION)-01.config
else
## apollo/kronos kernel
#KERNEL_CONFIG = $(PATCHES)/kernel/$(PLATFORM)-$(KVERSION)-01.config
KERNEL_CONFIG = $(PATCHES)/kernel/cst-$(PLATFORM)-$(KVERSION)_3.01-01.config
endif

USE_KRNL_LOGO   ?= 0
KERNEL_BUILD    ?= 0
KERNEL_BUILD_INT = vers:$(KERNEL_BUILD)
K_OBJ            = $(BUILD_TMP)/kobj
K_SRCDIR         = $(BUILD_TMP)/linux
KRNL_LOGO_FILE   = $(PATCHES)/kernel/$(KRNL_LOGO)
INSTALL_MOD_PATH = $(TARGETPREFIX_BASE)

#######################################################################

$(K_OBJ)/.config: $(ARCHIVE)/$(CUSTOM_KERNEL_VER).tar.xz
	mkdir -p $(K_OBJ)
	rm -fr $(K_SRCDIR); \
	rm -fr $(BUILD_TMP)/$(CUSTOM_KERNEL_VER); \
	$(UNTAR)/$(CUSTOM_KERNEL_VER).tar.xz; \
	ln -sf $(CUSTOM_KERNEL_VER) $(K_SRCDIR); \
	if [ -e $(KRNL_LOGO_FILE) -a ! "$(PLATFORM)" = "nevis" ]; then \
		cp -f $(KRNL_LOGO_FILE) $(K_SRCDIR)/arch/arm/plat-stb/include/plat/splash_img.h; \
	fi; \
	cp -a $(KERNEL_CONFIG) $@; \
	if [ ! "$(PLATFORM)" = "nevis" ]; then \
		cd $(K_SRCDIR); \
			$(PATCH)/kernel/0001-arch-arm-vfp-Makefile-adjust-kbuild_aflags.patch; \
			$(PATCH)/kernel/0001-fix-build-with-gcc-5.1.patch; \
		cd $(K_OBJ); \
			$(PATCH)/kernel/config_comp-xz.diff; \
			$(PATCH)/kernel/config_ipv6.diff; \
			$(PATCH)/kernel/config_nfsd.diff; \
	fi;
	touch $@

kernel-menuconfig: $(K_OBJ)/.config
	cd $(K_SRCDIR) && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- menuconfig O=$(K_OBJ)/

ifneq ($(PLATFORM), nevis)
## apollo / kronos
DTB = xxx
ifeq ($(PLATFORM), apollo)
DTB = hd849x.dtb
KRNL_NAME = CST Apollo Kernel
endif
ifeq ($(PLATFORM), kronos)
DTB = en75x1.dtb
KRNL_NAME = CST Kronos Kernel
endif

TEXT_ADDR=0x8000
LOAD_ADDR=0x8000

kernel-clean:
	rm -fr $(K_OBJ)
	rm -fr $(INSTALL_MOD_PATH)/lib/modules/$(KVERSION)/kernel
	rm -f $(INSTALL_MOD_PATH)/lib/modules/$(KVERSION)/modules.*
	rm -f $(BUILD_TMP)/kernel-img/vmlinux.ub.gz
	rm -f $(BUILD_TMP)/kernel-img/zImage_DTB
	rm -f $(D)/cskernel

cskernel-image: $(HOSTPREFIX)/bin/mkimage
	mkdir -p $(BUILD_TMP)/kernel-img
	@if [ ! -e $(K_OBJ)/arch/arm/boot/zImage ]; then \
		echo "\"$(K_OBJ)/arch/arm/boot/zImage\" not found."; \
		false; \
	fi;
	cat $(K_OBJ)/arch/arm/boot/zImage \
		$(SOURCE_DIR)/cst-public-drivers/$(PLATFORM)-3.x/device-tree-overlay/$(DTB) \
		> $(BUILD_TMP)/kernel-img/zImage_DTB;
	cd $(BUILD_TMP)/kernel-img && \
		rm -f vmlinux.ub.gz; \
		mkimage -A ARM -O linux -T kernel -C none -a $(LOAD_ADDR) -e $(TEXT_ADDR) \
			-n "$(KRNL_NAME) $(KERNEL_BUILD_INT)" -d zImage_DTB vmlinux.ub.gz

$(D)/cskernel: $(K_OBJ)/.config
	rm -f $(K_SRCDIR)/.config
	rm -fr $(INSTALL_MOD_PATH)/lib/modules/$(KVERSION)/kernel
	rm -f $(INSTALL_MOD_PATH)/lib/modules/$(KVERSION)/modules.*
	set -e; cd $(K_SRCDIR); \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- silentoldconfig O=$(K_OBJ)/; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- O=$(K_OBJ)/; \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(INSTALL_MOD_PATH) modules_install O=$(K_OBJ)/
	rm -f $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION)/build
	rm -f $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION)/source
	$$(which depmod) -b $(TARGETPREFIX_BASE) $(KVERSION)
	touch $@

else ## ifneq ($(PLATFORM), nevis)
## nevis
KRNL_NAME = CST Nevis Kernel
KVERSION_FULL = $(KVERSION)-nevis

TEXT_ADDR=0x48000
LOAD_ADDR=0x48000

kernel-clean:
	rm -fr $(K_OBJ)
	rm -fr $(INSTALL_MOD_PATH)/lib/modules/$(KVERSION_FULL)/kernel
	rm -f $(INSTALL_MOD_PATH)/lib/modules/$(KVERSION_FULL)/modules.*
	rm -f $(BUILD_TMP)/kernel-img/kernel.img
	rm -f $(D)/cskernel

cskernel-image: $(D)/cskernel | $(HOSTPREFIX)/bin/mkimage
	mkdir -p $(BUILD_TMP)/kernel-img
	cd $(BUILD_TMP)/kernel-img && \
		rm -f kernel.img; \
		mkimage -A ARM -O linux -T kernel -C none -a $(LOAD_ADDR) -e $(TEXT_ADDR) \
			-n "$(KRNL_NAME) $(KERNEL_BUILD_INT)" -d $(K_OBJ)/arch/arm/boot/zImage kernel.img

$(D)/cskernel: $(K_OBJ)/.config
	rm -f $(K_SRCDIR)/.config
	set -e; cd $(K_SRCDIR); \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- silentoldconfig O=$(K_OBJ)/; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- O=$(K_OBJ)/; \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(INSTALL_MOD_PATH) modules_install O=$(K_OBJ)/
	rm -f $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION_FULL)/build
	rm -f $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION_FULL)/source
	rm -fr $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION_FULL)/kernel/crypto
	rm -fr $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION_FULL)/kernel/drivers/media
	rm -fr $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION_FULL)/kernel/drivers/misc
	rm -fr $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION_FULL)/kernel/drivers/scsi
	rm -fr $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION_FULL)/kernel/fs/nls
	rm -fr $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION_FULL)/kernel/lib
	$$(which depmod) -b $(TARGETPREFIX_BASE) $(KVERSION_FULL)
	touch $@

endif ## ifneq ($(PLATFORM), nevis)


## insmod: can't insert '/lib/modules/2.6.34.13-nevis/cnxt_kal.ko': unknown symbol in module, or unknown parameter
