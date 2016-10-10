
TIME = $(shell date +%Y-%m-%d_%H-%M)
IMGs = $(IMAGE_IMAGES)/img_$(TIME)

ifeq ($(PLATFORM), kronos)
ERASEBLOCK = 0x20000
FLASHIMG   = $(IMGs)/tmp.img
SUMIMG     = $(IMGs)/rootfs.arm.jffs2.nand

opkg-flash-build: find-mkfs.jffs2 find-sumtool opkg-make-pkg-index
	mkdir -p $(IMGs)
	echo "/dev/console c 0600 0 0 5 1 0 0 0" > $(BUILD_TMP)/devtable
	@echo ""
	@du -shk $$(realpath $(IMAGE_ROOT))
	@echo ""
	mkfs.jffs2 -C -n -e $(ERASEBLOCK) -l -U -D $(BUILD_TMP)/devtable -r $(IMAGE_ROOT) -o $(FLASHIMG) && \
	sumtool -n -e $(ERASEBLOCK) -l -i $(FLASHIMG) -o $(SUMIMG)
	rm -f $(FLASHIMG)
	rm -f $(BUILD_TMP)/devtable

endif # ($(PLATFORM), kronos)

ifeq ($(PLATFORM), apollo)
endif # ($(PLATFORM), apollo)

ifeq ($(PLATFORM), nevis)
endif # ($(PLATFORM), nevis)


## uldr.bin
## u-boot.bin
## env.bin
## vmlinux.ub.gz
## rootfs.arm.jffs2.nand
## rootfs1.arm.jffs2.nand
## var.arm.jffs2.nand
