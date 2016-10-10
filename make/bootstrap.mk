# makefile to build crosstool

BOOTSTRAP  = targetprefix $(BUILD_TMP) $(CROSS_DIR) $(HOSTPREFIX)/bin
BOOTSTRAP += $(TARGETPREFIX_BASE)/lib/libc.so.6
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg.sh $(HOSTPREFIX)/bin/opkg-chksvn.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-gitdescribe.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-find-requires.sh $(HOSTPREFIX)/bin/opkg-find-provides.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-make-index.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-module-deps.sh
BOOTSTRAP += $(HOSTPREFIX)/bin/get-git-archive.sh
BOOTSTRAP += pkg-config includes-and-libs
BOOTSTRAP += $(HOSTPREFIX)/bin/opkg-controlver-from-svn.sh
BOOTSTRAP += $(TARGETPREFIX_BASE)/sbin/ldconfig

PLAT_LIBS  = cst-modules-$(PLATFORM) cst-libs
PLAT_INCS  = cst-firmware

bootstrap: $(BOOTSTRAP)

CST_LIBS = libs

targetprefix:
	@PATH=$(PATH):$(CROSS_DIR)/bin && \
	if ! type -p $(TARGET)-gcc >/dev/null 2>&1; then \
		echo;echo "$(TARGET)-gcc not found in PATH or \$$CROSS_DIR/bin"; \
		echo "=> please check your setup. Maybe you need to 'make crosstool'."; echo; \
		false; \
	fi
	mkdir -p $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/bin
	mkdir -p $(TARGETPREFIX)/include
	mkdir -p $(PKG_CONFIG_PATH)
	make skeleton

$(TARGETPREFIX):
	@echo "**********************************************************************"
	@echo "TARGETPREFIX does not exist. You probably need to run 'make bootstrap'"
	@echo "**********************************************************************"
	@echo ""
	@false

$(HOSTPREFIX):
	mkdir $@

$(HOSTPREFIX)/bin: $(HOSTPREFIX)
	mkdir -p $@

$(HOSTPREFIX)/bin/unpack%.sh \
$(HOSTPREFIX)/bin/get%.sh \
$(HOSTPREFIX)/bin/opkg%sh: | $(HOSTPREFIX)/bin
	ln -sf ../../scripts/$(shell basename $@) $(HOSTPREFIX)/bin

$(BUILD_TMP):
	mkdir -p $(BUILD_TMP)

$(CROSS_DIR):
	mkdir -p $(CROSS_DIR)

cst-libs: | $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX_BASE)/lib
	cp -a --remove-destination $(SOURCE_DIR)/$(SOURCE_DRIVERS)/$(PLATFORM)$(DRIVERS_3x)/$(CST_LIBS)/*.so $(TARGETPREFIX_BASE)/lib
	$(RM_PKGPREFIX)
	mkdir -p $(PKGPREFIX_BASE)/lib
	cp -a $(SOURCE_DIR)/$(SOURCE_DRIVERS)/$(PLATFORM)$(DRIVERS_3x)/$(CST_LIBS)/*.so $(PKGPREFIX_BASE)/lib
	if [ "$(PLATFORM)" = "nevis" ]; then \
		CONTROL_DIR_LIBS=HD1; \
	else \
		CONTROL_DIR_LIBS=HD2; \
	fi; \
	PKG_VER=$(PLATFORM)-1.0 \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX_BASE)` \
			$(OPKG_SH) $(CONTROL_DIR)/cs-libs/$$CONTROL_DIR_LIBS
	$(RM_PKGPREFIX)

cst-firmware: | $(TARGETPREFIX)
	cp -fa $(SOURCE_DIR)/$(SOURCE_DRIVERS)/$(PLATFORM)$(DRIVERS_3x)/firmware $(TARGETPREFIX_BASE)/lib

cst-modules-apollo: | $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX_BASE)/lib/modules; \
	cp -fa $(SOURCE_DIR)/$(SOURCE_DRIVERS)/$(PLATFORM)$(DRIVERS_3x)/drivers/$(KVERSION) $(TARGETPREFIX_BASE)/lib/modules; \

cst-modules-kronos: | $(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX_BASE)/lib/modules; \
	cp -fa $(SOURCE_DIR)/$(SOURCE_DRIVERS)/$(PLATFORM)$(DRIVERS_3x)/drivers/$(KVERSION) $(TARGETPREFIX_BASE)/lib/modules; \

NEVIS_MODULES = \
	8192cu.ko \
	8712u.ko \
	avl2108.ko \
	cnxt_alsa.ko \
	cnxt_base.ko \
	cnxt_fb.ko \
	cnxt_i2c.ko \
	cnxt_kal.ko \
	cnxt_lnx.ko \
	cnxt_sata_drv.ko \
	cnxtmcstats.ko \
	cs_control.ko \
	cs_frontend.ko \
	cs_frontend_prop.ko \
	cs_frontpanel.ko \
	cx24116.ko \
	dvb-core.ko \
	max2112.ko \
	stv090x.ko \
	stv6110.ko \
	tda10023.ko

cst-modules-nevis: | $(TARGETPREFIX)
	rm -fr $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION)-nevis/extra
	mkdir -p $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION)-nevis/extra
	for m in $(NEVIS_MODULES); do \
		cp $(SOURCE_DIR)/$(SOURCE_DRIVERS)/nevis/drivers/$(KVERSION)-nevis/$$m $(TARGETPREFIX_BASE)/lib/modules/$(KVERSION)-nevis/extra; \
	done

$(TARGETPREFIX_BASE)/lib/libc.so.6: $(TARGETPREFIX)
	# stlinux RPM puts libstdc++ into /usr/lib...
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/usr/lib/libstdc++.so; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/usr/lib/libstdc++.s*[!y] $(TARGETPREFIX_BASE)/lib; \
	fi
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGETPREFIX_BASE)/lib; \
		if test ! -h $(CROSS_DIR)/$(TARGET)/lib -a -d $(CROSS_DIR)/$(TARGET)/lib; then \
			cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGETPREFIX_BASE)/lib; \
		fi; \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGETPREFIX_BASE)/lib; \
	fi

includes-and-libs: $(PLAT_LIBS) $(PLAT_INCS)

# helper target to create ccache links (make sure to have ccache installed in /usr/bin ;)

ccache: $(HOSTPREFIX)/bin
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/cc
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/gcc
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/g++
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/$(TARGET)-gcc
	@ln -sf $(CCACHE) $(HOSTPREFIX)/bin/$(TARGET)-g++

ccache-rm: $(HOSTPREFIX)/bin
	@rm -rf $(HOSTPREFIX)/bin/cc
	@rm -rf $(HOSTPREFIX)/bin/gcc
	@rm -rf $(HOSTPREFIX)/bin/g++
	@rm -rf $(HOSTPREFIX)/bin/$(TARGET)-gcc
	@rm -rf $(HOSTPREFIX)/bin/$(TARGET)-g++

ldconfig: $(TARGETPREFIX_BASE)/sbin/ldconfig
$(TARGETPREFIX_BASE)/sbin/ldconfig: | $(TARGETPREFIX_BASE)
	@if test -e $(CROSS_DIR)/$(TARGET)/sys-root/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/sbin/ldconfig $@; \
		mkdir -p $(TARGETPREFIX_BASE)/etc; \
		touch $(TARGETPREFIX_BASE)/etc/ld.so.conf; \
	elif test -e $(CROSS_DIR)/$(TARGET)/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sbin/ldconfig $@; \
		mkdir -p $(TARGETPREFIX_BASE)/etc; \
		touch $(TARGETPREFIX_BASE)/etc/ld.so.conf; \
	else \
		# triggers on crosstool-0.43 built Tripledragon toolchain ; \
		echo "====================================================="; \
		echo "Your toolchain did not build ldconfig for the target."; \
		echo "This is not an error, just a hint."; \
		echo "====================================================="; \
	fi

pkg-config-preqs:
	@PATH=$(subst $(HOSTPREFIX)/bin:,,$(PATH)); \
		if ! pkg-config --exists glib-2.0; then \
			echo "pkg-config and glib2-devel packages are needed for building cross-pkg-config."; false; \
		fi

pkg-config: $(HOSTPREFIX)/bin/pkg-config
$(HOSTPREFIX)/bin/pkg-config: $(ARCHIVE)/pkg-config-$(PKGCONFIG_VER).tar.gz | $(HOSTPREFIX)/bin pkg-config-preqs
	$(UNTAR)/pkg-config-$(PKGCONFIG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pkg-config-$(PKGCONFIG_VER); \
		./configure --with-pc_path=$(PKG_CONFIG_PATH); \
		$(MAKE); \
		cp -a pkg-config $(HOSTPREFIX)/bin; \
		cp -a pkg.m4 $(BUILD_TOOLS)/share/aclocal
	ln -sf pkg-config $(HOSTPREFIX)/bin/$(TARGET)-pkg-config
	$(REMOVE)/pkg-config-$(PKGCONFIG_VER)

$(D)/skeleton: | $(TARGETPREFIX)
	cp --remove-destination -a skel-root/common/* $(TARGETPREFIX_BASE)/
	cp --remove-destination -a skel-root/$(PLATFORM)/* $(TARGETPREFIX_BASE)/

# hack to make sure they are always copied
PHONY += ccache crosstool includes-and-libs cst-modules targetprefix bootstrap
