
ifeq ($(PLATFORM), nevis)
## nevis kernel
KERNEL_CONFIG = $(PATCHES)/kernel/$(PLATFORM)-$(KVERSION)-01.config
else
## apollo/kronos kernel
KERNEL_CONFIG = $(PATCHES)/kernel/$(PLATFORM)-$(KVERSION)-01.config
endif

USE_KRNL_LOGO   ?= 0
KERNEL_BUILD    ?= 0
KERNEL_BUILD_INT = vers:$(KERNEL_BUILD)
K_OBJ            = $(BUILD_TMP)/kobj
K_SRCDIR         = $(BUILD_TMP)/linux
INSTALL_MOD_PATH = $(TARGETPREFIX_BASE)/mymodules
KRNL_LOGO_FILE   = $(PATCHES)/kernel/$(KRNL_LOGO)

#######################################################################

$(K_OBJ)/.config: $(ARCHIVE)/cst-kernel_$(KERNEL_FILE_VER).tar.xz
	mkdir -p $(K_OBJ)
	rm -fr $(K_SRCDIR); \
	rm -fr $(BUILD_TMP)/cst-kernel_$(KERNEL_FILE_VER); \
	$(UNTAR)/cst-kernel_$(KERNEL_FILE_VER).tar.xz; \
	ln -sf cst-kernel_$(KERNEL_FILE_VER) $(K_SRCDIR); \
	if [ -e $(KRNL_LOGO_FILE) -a ! "$(PLATFORM)" = "nevis" ]; then \
		cp -f $(KRNL_LOGO_FILE) $(K_SRCDIR)/arch/arm/plat-stb/include/plat/splash_img.h; \
	fi; \
	cp -a $(KERNEL_CONFIG) $@

kernel-menuconfig: $(K_OBJ)/.config
	cd $(K_SRCDIR) && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- menuconfig O=$(K_OBJ)/

kernel-clean:
	rm -fr $(K_OBJ)
	rm -fr $(INSTALL_MOD_PATH)
	rm -f $(BUILD_TMP)/kernel-img/vmlinux.ub.gz
	rm -f $(BUILD_TMP)/kernel-img/zImage_DTB
	rm -f $(D)/cskernel


$(D)/cskernel: $(K_OBJ)/.config
	rm -f $(K_SRCDIR)/.config
	set -e; cd $(K_SRCDIR); \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- silentoldconfig O=$(K_OBJ)/; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- O=$(K_OBJ)/; \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(INSTALL_MOD_PATH) modules_install O=$(K_OBJ)/
	touch $@

ifneq ($(PLATFORM), nevis)
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
cskernel-image: $(D)/cskernel | $(HOSTPREFIX)/bin/mkimage
	mkdir -p $(BUILD_TMP)/kernel-img
	cat $(K_OBJ)/arch/arm/boot/zImage \
		$(SOURCE_DIR)/cst-public-drivers/$(PLATFORM)-3.x/device-tree-overlay/$(DTB) \
		> $(BUILD_TMP)/kernel-img/zImage_DTB;
	cd $(BUILD_TMP)/kernel-img && \
		rm -f vmlinux.ub.gz; \
		mkimage -A ARM -O linux -T kernel -C none -a $(LOAD_ADDR) -e $(TEXT_ADDR) \
			-n "$(KRNL_NAME) $(KERNEL_BUILD_INT)" -d zImage_DTB vmlinux.ub.gz

else ## ifneq ($(PLATFORM), nevis)

KRNL_NAME = CST Nevis Kernel
TEXT_ADDR=0x48000
LOAD_ADDR=0x48000
cskernel-image: $(D)/cskernel | $(HOSTPREFIX)/bin/mkimage
	mkdir -p $(BUILD_TMP)/kernel-img
	cd $(BUILD_TMP)/kernel-img && \
		rm -f kernel.img; \
		mkimage -A ARM -O linux -T kernel -C none -a $(LOAD_ADDR) -e $(TEXT_ADDR) \
			-n "$(KRNL_NAME) $(KERNEL_BUILD_INT)" -d $(K_OBJ)/arch/arm/boot/zImage kernel.img

endif ## ifneq ($(PLATFORM), nevis)


## insmod: can't insert '/lib/modules/2.6.34.13-nevis/cnxt_kal.ko': unknown symbol in module, or unknown parameter
