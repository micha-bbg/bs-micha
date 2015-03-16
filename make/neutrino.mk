#Makefile to build NEUTRINO

AUDIODEC = ffmpeg
NEUTRINO_DEPS  = $(SYSTEM_TOOLS)
NEUTRINO_DEPS += libcurl libjpeg freetype libbluray ffmpeg libdvbsi++ giflib libsigc++
NEUTRINO_DEPS += openthreads luaposix luacurl openssl
NEUTRINO_DEPS += wpa_supplicant parted
NEUTRINO_PKG_DEPS =

ifeq ($(UCLIBC_BUILD), 1)
NEUTRINO_DEPS += libiconv
endif

N_CFLAGS  = -Wall -Werror -Wextra -Wshadow -Wsign-compare
#N_CFLAGS += -Wconversion
N_CFLAGS += -fmax-errors=10
N_CFLAGS += -O -g -ggdb3 -D__KERNEL_STRICT_NAMES
N_CFLAGS += -DNEW_LIBCURL $(LOCAL_NEUTRINO_CFLAGS)
N_CFLAGS += -fno-strict-aliasing -rdynamic 
N_CFLAGS += -D__STDC_FORMAT_MACROS
#N_CFLAGS += -DDYNAMIC_LUAPOSIX
N_CFLAGS += -DASSUME_MDEV

ifeq ($(PLATFORM), apollo)
N_CFLAGS += -mcpu=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=hard -DFB_HW_ACCELERATION
HW_TYPE = --with-boxtype=coolstream --with-boxmodel=apollo
endif

ifeq ($(PLATFORM), kronos)
N_CFLAGS += -mcpu=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=hard -DFB_HW_ACCELERATION
HW_TYPE = --with-boxtype=coolstream --with-boxmodel=apollo
endif

ifeq ($(PLATFORM), nevis)
N_CFLAGS += -DUSE_NEVIS_GXA
HW_TYPE = --with-boxtype=coolstream
endif

N_CPPFLAGS = -I$(TARGETPREFIX)/include -I$(TARGETPREFIX_BASE)/include
N_CPPFLAGS += -Werror -Wsign-compare

N_CONFIG_OPTS =
#N_CONFIG_OPTS += --disable-upnp
N_CONFIG_OPTS += --enable-giflib
N_CONFIG_OPTS += --enable-pip
N_CONFIG_OPTS += --enable-lua
N_CONFIG_OPTS += --enable-testing

ifeq ($(AUDIODEC), ffmpeg)
# enable ffmpeg audio decoder in neutrino
N_CONFIG_OPTS += --enable-ffmpegdec
else
NEUTRINO_DEPS += libid3tag libmad

# choose between static and dynamic libtremor. As long as nothing else
# uses libtremor, static usage does not really hurt and is compatible
# with the "original" image
#N_CONFIG_OPTS += --with-tremor-static
N_CONFIG_OPTS += --with-tremor
NEUTRINO_DEPS += libvorbisidec

# enable FLAC decoder in neutrino
N_CONFIG_OPTS += --enable-flac
NEUTRINO_DEPS += libFLAC
endif

NEUTRINO_DEPS2 += $(TARGETPREFIX_BASE)/bin/fbshot

neutrino-deps: $(NEUTRINO_DEPS)

# the original build script links against openssl, but it is not needed at all.
# libcurl is picked up by configure anyway, so not needed here.
# N_LDFLAGS  = -L$(TARGETPREFIX_BASE)/lib -lcurl -lssl -lcrypto -ldl

N_LDFLAGS =
#N_LDFLAGS = -L$(TARGETPREFIX_BASE)/lib -lcurl -lssl -lcrypto -ldl
N_LDFLAGS += -L$(TARGETPREFIX)/lib -L$(TARGETPREFIX_BASE)/lib
ifeq ($(UCLIBC_BUILD), 1)
N_LDFLAGS += -liconv
endif
N_LDFLAGS += -Wl,-rpath-link,$(TARGETLIB)

# finally we can build outside of the source directory
N_OBJDIR = $(BUILD_TMP)/$(FLAVOUR)
# use this if you want to build inside the source dir - but you don't want that ;)
# N_OBJDIR = $(N_HD_SOURCE)

$(N_OBJDIR)/config.status: $(NEUTRINO_DEPS) $(MAKE_DIR)/neutrino.mk
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	$(N_HD_SOURCE)/autogen.sh
	cd $(N_HD_SOURCE); \
		git checkout $(NEUTRINO_WORK_BRANCH)
	set -e; cd $(N_OBJDIR); \
		CC=$(TARGET)-gcc CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)" \
		LDFLAGS="$(N_LDFLAGS)" PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
		$(N_HD_SOURCE)/configure --host=$(TARGET) --build=$(BUILD) --prefix=${PREFIX} \
				--enable-silent-rules --enable-mdev \
				--enable-maintainer-mode --with-target=cdk --with-targetprefix="" $(HW_TYPE) \
				$(N_CONFIG_OPTS) $(LOCAL_NEUTRINO_BUILD_OPTIONS) \
				INSTALL="`which install` -p"; \
		test -e src/gui/svn_version.h || echo '#define BUILT_DATE "error - not set"' > src/gui/svn_version.h; \
		test -e svn_version.h || echo '#define BUILT_DATE "error - not set"' > svn_version.h; \
		test -e git_version.h || echo '#define BUILT_DATE "error - not set"' > git_version.h; \
		test -e version.h || touch version.h


HOMEPAGE = "http://gitorious.org/neutrino-hd"
IMGNAME  = "HD-Neutrino"
$(PKGPREFIX_BASE)/.version \
$(TARGETPREFIX_BASE)/.version:
	echo "version=1200`date +%Y%m%d%H%M`"	 > $@
	echo "creator=$(MAINTAINER)"		>> $@
	echo "imagename=$(IMGNAME)"		>> $@
	A=$(FLAVOUR); F=$${A#neutrino-??}; \
		B=`cd $(N_HD_SOURCE); git describe --always --dirty`; \
		C=$${B%-dirty}; D=$${B#$$C}; \
		E=`cd $(N_HD_SOURCE); git tag --contains $$C`; \
		test -n "$$E" && C="$$E"; \
		echo "builddate=$$C$$D $${F:1}" >> $@
	echo "homepage=$(HOMEPAGE)"		>> $@

PHONY += $(PKGPREFIX_BASE)/.version $(TARGETPREFIX_BASE)/.version

$(D)/neutrino: $(N_OBJDIR)/config.status $(NEUTRINO_DEPS2)
	rm -f $(N_OBJDIR)/src/neutrino # trigger relinking, to pick up newly built libstb-hal
	cd $(N_HD_SOURCE); \
		git checkout $(NEUTRINO_WORK_BRANCH)
	cd $(BASE_DIR)
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all     DESTDIR=$(TARGETPREFIX_BASE)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGETPREFIX_BASE)
	+make $(TARGETPREFIX_BASE)/.version
	: touch $@

neutrino-pkg: $(N_OBJDIR)/config.status $(NEUTRINO_DEPS2) $(NEUTRINO_PKG_DEPS)
	rm -rf $(PKGPREFIX_BASE) $(BUILD_TMP)/neutrino-control
	cd $(N_HD_SOURCE); \
		git checkout $(NEUTRINO_WORK_BRANCH)
	cd $(BASE_DIR)
#	$(MAKE) -C $(N_OBJDIR) clean   DESTDIR=$(TARGETPREFIX_BASE)
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all     DESTDIR=$(TARGETPREFIX_BASE)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(PKGPREFIX_BASE)
ifeq ($(PLATFORM), nevis)
	install -D -m 0755 skel-root/nevis/etc/init.d/start_neutrino $(PKGPREFIX_BASE)/etc/init.d/start_neutrino;
endif
ifeq ($(PLATFORM), apollo)
	install -D -m 0755 skel-root/apollo/bin/autorun.sh $(PKGPREFIX_BASE)/bin/autorun.sh;
endif
ifeq ($(PLATFORM), kronos)
	install -D -m 0755 skel-root/kronos/bin/autorun.sh $(PKGPREFIX_BASE)/bin/autorun.sh;
endif
	make $(PKGPREFIX_BASE)/.version
	cp -a $(CONTROL_DIR)/$(NEUTRINO_PKG) $(BUILD_TMP)/neutrino-control
	DEP=`$(TARGET)-objdump -p $(PKGPREFIX_BASE)/bin/neutrino | awk '/NEEDED/{print $$2}' | sort` && \
		DEP=`echo $$DEP` && \
		DEP="$${DEP// /, }" && \
		sed -i "s/@DEP@/$$DEP/" $(BUILD_TMP)/neutrino-control/control
	sed -i 's/^\(Depends:.*\)$$/\1, cs-drivers/' $(BUILD_TMP)/neutrino-control/control
	install -p -m 0755 $(TARGETPREFIX_BASE)/bin/fbshot $(PKGPREFIX_BASE)/bin/
	ln -s usr/share $(PKGPREFIX_BASE)/share
	find $(PKGPREFIX_BASE)/share/tuxbox/neutrino/locale/ -type f \
		! -name deutsch.locale ! -name english.locale ! -name nederlands.locale ! -name slovak.locale | xargs --no-run-if-empty rm
	# ignore the .version file for package  comparison
	DONT_STRIP=$(NEUTRINO_NOSTRIP) CMP_IGNORE="/.version" $(OPKG_SH) $(BUILD_TMP)/neutrino-control
	$(RM_PKGPREFIX)

neutrino-clean:
	-make -C $(N_OBJDIR) uninstall
	-make -C $(N_OBJDIR) distclean
	-rm $(N_OBJDIR)/config.status
	-rm $(D)/neutrino

PHONY += neutrino-clean neutrino-system neutrino-system-seife
