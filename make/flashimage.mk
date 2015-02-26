# build a flash image.
# the contents need to be in $(BUILD_TMP)/install
# e.g. installed with "make minimal-system-pkgs"
#
# This is totally untested :-)
#
# the needed mkfs.jffs2 and sumtool are built with the mtd-utils target
#

IMGs = $(BUILD_TMP)/Images
TIME := $(shell date +%Y-%m-%d_%H-%M)

local-install:
	# copy local/flash/* into the image...
	# you can e.g. create local/flash/boot/audio.elf ...
	@if test -d $(BASE_DIR)/local/flash/; then \
		cp -a -v $(BASE_DIR)/local/flash/. $(BUILD_TMP)/install/.; \
	fi

ifeq ($(PLATFORM), apollo)
ERASEBLOCK    = 
FLASHIMG_BODY = $(IMGs)/rootfs.arm.jffs2.nand
SUMIMG_BODY   = $(IMGs)/rootfs.arm.jffs2.nand

ifeq ($(BOXMODEL), tank)
ERASEBLOCK  = 0x40000
FLASHIMG   = $(FLASHIMG_BODY).256k.$(TIME).tmp.img
SUMIMG     = $(SUMIMG_BODY).256k.$(TIME).img
endif

ifeq ($(BOXMODEL), trinity)
ERASEBLOCK = 0x20000
FLASHIMG   = $(FLASHIMG_BODY).$(TIME).tmp.img
SUMIMG     = $(SUMIMG_BODY).$(TIME).img
endif

flash-build: 
	mkdir -p $(IMGs)
	echo "/dev/console c 0600 0 0 5 1 0 0 0" > $(BUILD_TMP)/devtable
#	ln -sf /share/zoneinfo/CET $(BUILD_TMP)/install/etc/localtime # CET is the default in a fresh neutrino install
	@echo ""
	@du -shk $(INSTALL)
	@echo ""
	mkfs.jffs2 -C -n -e $(ERASEBLOCK) -l -U -D $(BUILD_TMP)/devtable -r $(BUILD_TMP)/install -o $(FLASHIMG) && \
	sumtool -n -e $(ERASEBLOCK) -l -i $(FLASHIMG) -o $(SUMIMG)
	rm -f $(FLASHIMG)
	rm -f $(BUILD_TMP)/devtable

endif # ($(PLATFORM), apollo)

ifeq ($(PLATFORM), nevis)

FLASHIMG = $(BUILD_TMP)/flashroot-$(PLATFORM)-$(TIME).img
SUMIMG   = $(BUILD_TMP)/flashroot-$(PLATFORM)-$(TIME).sum.img

flash-prepare: local-install find-mkfs.jffs2 find-sumtool

flash-build: 
	echo "/dev/console c 0600 0 0 5 1 0 0 0" > $(BUILD_TMP)/devtable
	ln -sf /share/zoneinfo/CET $(BUILD_TMP)/install/etc/localtime # CET is the default in a fresh neutrino install
	mkfs.jffs2 -e 0x20000 -p -U -D $(BUILD_TMP)/devtable -d $(BUILD_TMP)/install -o $(FLASHIMG)
	sumtool    -e 0x20000 -p -i $(FLASHIMG) -o $(SUMIMG)

# the devtable is used for having a console device on first boot.
flashimage: flash-prepare cskernel flash-build
	$(REMOVE)/coolstream
	mkdir $(BUILD_TMP)/coolstream
	set -e;\
		cd $(BUILD_TMP); \
		cp zImage.img mtd1-hd1.img; $(BASE_DIR)/scripts/mkmultiboot-hd1.sh . mkimage; rm mtd1-hd1.img; \
		mv kernel-autoscr-mtd1.img coolstream/kernel.img; \
		cp $(SUMIMG) coolstream/system.img
	@echo; echo
	ls -l $(BUILD_TMP)/coolstream

endif # ($(PLATFORM), nevis)

ifeq ($(PLATFORM), kronos)
ERASEBLOCK    = 
FLASHIMG_BODY = $(IMGs)/rootfs.arm.jffs2.nand
SUMIMG_BODY   = $(IMGs)/rootfs.arm.jffs2.nand

ERASEBLOCK = 0x20000
FLASHIMG   = $(FLASHIMG_BODY).$(TIME).tmp.img
SUMIMG     = $(SUMIMG_BODY).$(TIME).img

flash-prepare: local-install find-mkfs.jffs2 find-sumtool

flash-build: 
	mkdir -p $(IMGs)
	echo "/dev/console c 0600 0 0 5 1 0 0 0" > $(BUILD_TMP)/devtable
	@echo ""
	@du -shk $$(realpath $(INSTALL))
	@echo ""
	mkfs.jffs2 -C -n -e $(ERASEBLOCK) -l -U -D $(BUILD_TMP)/devtable -r $(BUILD_TMP)/install -o $(FLASHIMG) && \
	sumtool -n -e $(ERASEBLOCK) -l -i $(FLASHIMG) -o $(SUMIMG)
	rm -f $(FLASHIMG)
	rm -f $(BUILD_TMP)/devtable

endif # ($(PLATFORM), kronos)

PHONY += flashimage
