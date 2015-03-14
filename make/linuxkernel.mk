
ifeq ($(PLATFORM), nevis)
KERNEL_CONFIG = $(PATCHES)/kernel/$(PLATFORM)-$(KVERSION)-01.config
else
KERNEL_CONFIG = $(PATCHES)/kernel/$(PLATFORM)-$(KVERSION)-02.config
endif

SKIP_KRNL_COPY  ?= 0
KERNEL_BUILD    ?= vers:##
K_OBJ            = $(BUILD_TMP)/kobj
K_SRCDIR         = $(BUILD_TMP)/linux
INSTALL_MOD_PATH = $(TARGETPREFIX_BASE)/mymodules

#######################################################################

$(K_OBJ)/.config: $(ARCHIVE)/cst-kernel_$(KERNEL_FILE_VER).tar.xz
	mkdir -p $(K_OBJ)
	if [ ! "$SKIP_KRNL_COPY" = "1" -o ! -d cst-kernel_$(KERNEL_FILE_VER) ]; then \
		rm -fr cst-kernel_$(KERNEL_FILE_VER); \
		rm -fr $(K_SRCDIR); \
		$(UNTAR)/cst-kernel_$(KERNEL_FILE_VER).tar.xz; \
	fi;
	ln -sf cst-kernel_$(KERNEL_FILE_VER) $(K_SRCDIR); \
	cp -a $(KERNEL_CONFIG) $@

kernel-menuconfig: $(K_OBJ)/.config
	cd $(K_SRCDIR) && \
		make ARCH=arm CROSS_COMPILE=$(TARGET)- menuconfig O=$(K_OBJ)/

kernel-clean:
	rm -fr $(K_OBJ)
	rm -fr $(INSTALL_MOD_PATH)
	rm -fr $(BUILD_TMP)/kernel-img


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
			-n "$(KRNL_NAME) $(KERNEL_BUILD)" -d zImage_DTB vmlinux.ub.gz

else ## ifneq ($(PLATFORM), nevis)

KRNL_NAME = CST Nevis Kernel
TEXT_ADDR=0x48000
LOAD_ADDR=0x48000
cskernel-image: $(D)/cskernel | $(HOSTPREFIX)/bin/mkimage
	mkdir -p $(BUILD_TMP)/kernel-img
	cd $(BUILD_TMP)/kernel-img && \
		rm -f kernel.img; \
		mkimage -A ARM -O linux -T kernel -C none -a $(LOAD_ADDR) -e $(TEXT_ADDR) \
			-n "$(KRNL_NAME) $(KERNEL_BUILD)" -d $(K_OBJ)/arch/arm/boot/zImage kernel.img

endif ## ifneq ($(PLATFORM), nevis)


## insmod: can't insert '/lib/modules/2.6.34.13-nevis/cnxt_kal.ko': unknown symbol in module, or unknown parameter
