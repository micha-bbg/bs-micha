# set up environment for other makefiles

CONFIG_SITE =
export CONFIG_SITE

BASE_DIR := $(shell pwd)
-include $(BASE_DIR)/config.mk

PLATFORM ?= kronos
ifeq ($(PLATFORM), apollo)
BOXMODEL ?= tank
else
BOXMODEL =
endif

KRNL_LOGO ?= none

ifeq ($(PLATFORM), nevis)
TARGET_NEVIS                ?= arm-cx2450x-linux-gnueabi
TARGET                       = $(TARGET_NEVIS)
N_HD_SOURCE                  = $(N_HD_SOURCE_NEVIS)
KVERSION_NEVIS              ?= 2.6.34.13
KVERSION                     = $(KVERSION_NEVIS)
NEUTRINO_BRANCH_NEVIS       ?= cst-next
NEUTRINO_BRANCH              = $(NEUTRINO_BRANCH_NEVIS)
NEUTRINO_WORK_BRANCH_NEVIS  ?= cst-next
NEUTRINO_WORK_BRANCH        ?= $(NEUTRINO_WORK_BRANCH_NEVIS)
NO_USR_BUILD		     = 1
DRIVERS_3x                   = $(DRIVERS_3x_NEVIS)
endif

ifeq ($(PLATFORM), apollo)
TARGET_APOLLO               ?= arm-cortex-linux-uclibcgnueabi
TARGET                       = $(TARGET_APOLLO)
N_HD_SOURCE                  = $(N_HD_SOURCE_APOLLO)
KVERSION_APOLLO             ?= 3.10.70
KVERSION                     = $(KVERSION_APOLLO)
NEUTRINO_BRANCH_APOLLO      ?= cst-next
NEUTRINO_BRANCH              = $(NEUTRINO_BRANCH_APOLLO)
NEUTRINO_WORK_BRANCH_APOLLO ?= cst-next
NEUTRINO_WORK_BRANCH        ?= $(NEUTRINO_WORK_BRANCH_APOLLO)
NO_USR_BUILD		     = 0
DRIVERS_3x                   = $(DRIVERS_3x_APOLLO)
endif

ifeq ($(PLATFORM), kronos)
TARGET_KRONOS               ?= arm-cortex-linux-uclibcgnueabi
TARGET                       = $(TARGET_KRONOS)
N_HD_SOURCE                  = $(N_HD_SOURCE_KRONOS)
KVERSION_KRONOS             ?= 3.10.70
KVERSION                     = $(KVERSION_KRONOS)
NEUTRINO_BRANCH_KRONOS      ?= cst-next
NEUTRINO_BRANCH              = $(NEUTRINO_BRANCH_KRONOS)
NEUTRINO_WORK_BRANCH_KRONOS ?= cst-next
NEUTRINO_WORK_BRANCH        ?= $(NEUTRINO_WORK_BRANCH_KRONOS)
NO_USR_BUILD		     = 0
DRIVERS_3x                   = $(DRIVERS_3x_KRONOS)
endif

ifeq ($(NO_USR_BUILD), 1)
DEFAULT_PREFIX               = /
else
DEFAULT_PREFIX               = /usr
endif

CROSS_PATH     ?= cross
CROSS_DIR       = $(BASE_DIR)/$(CROSS_PATH)
FLAVOUR        ?= neutrino-hd
BOXARCH        ?= arm

GIT_SOURCE     ?= cst
GIT_PROTO      ?= git
ifeq ($(GIT_SOURCE), cst)
ifeq ($(GIT_PROTO), git)
GITSOURCE       = git://coolstreamtech.de
else ifeq ($(GIT_PROTO), http)
GITSOURCE       = http://coolstreamtech.de
else
GITSOURCE       = ssh://git@coolstreamtech.de
endif # GIT_PROTO
else ifeq ($(GIT_SOURCE), sf)
ifeq ($(GIT_PROTO), git)
GITSOURCE       = git://git.code.sf.net/p/tuxcode
else ifeq ($(GIT_PROTO), http)
GITSOURCE       = http://git.code.sf.net/p/tuxcode
else
GITSOURCE       = ssh://michabbg@git.code.sf.net/p/tuxcode
endif # GIT_PROTO
else # GIT_SOURCE
ifeq ($(GIT_PROTO), https)
GITSOURCE       = https://git.slknet.de
else
GITSOURCE       = ssh://gitnorplex
endif # GIT_PROTO
endif # GIT_SOURCE

WHOAMI      := $(shell id -un)
MAINTAINER  ?= $(shell getent passwd $(WHOAMI)|awk -F: '{print $$5}')

ARCHIVE      = $(BASE_DIR)/download
PATCHES      = $(BASE_DIR)/archive-patches
BUILD_TMP    = $(BASE_DIR)/build_tmp
D            = $(BASE_DIR)/deps
# backwards compatibility
DEPDIR       = $(D)

PKGPREFIX_BASE = $(BUILD_TMP)/pkg
TARGETPREFIX_BASE = $(BASE_DIR)/root

CCACHE       = /usr/bin/ccache
HOSTPREFIX   = $(BASE_DIR)/host
ifeq ($(PLATFORM), nevis)
TARGETPREFIX = $(TARGETPREFIX_BASE)
PKGPREFIX    = $(PKGPREFIX_BASE)
else
TARGETPREFIX = $(TARGETPREFIX_BASE)/usr
PKGPREFIX    = $(PKGPREFIX_BASE)/usr
endif
RM_PKGPREFIX = rm -fr $(PKGPREFIX_BASE)
FROOTFS      = $(BASE_DIR)/root-flash
SOURCE_DIR   = $(BASE_DIR)/source
PLUGINS      = cst-public-plugins
PLUGIN_DIR   = $(SOURCE_DIR)/$(PLUGINS)
MAKE_DIR     = $(BASE_DIR)/make
CONTROL_DIR  = $(BASE_DIR)/pkgs/control
PACKAGE_DIR  = $(BASE_DIR)/pkgs/opkg
SCRIPTS      = $(BASE_DIR)/scripts/target

BUILD       ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess)
BUILD_TOOLS ?= $(HOSTPREFIX)/build-tools

ifeq ($(PLATFORM), nevis)
TARGETLIB       = $(TARGETPREFIX)/lib
else
TARGETLIB       = $(TARGETPREFIX)/lib -L$(TARGETPREFIX_BASE)/lib
endif

GCC_OPTIMIZE    ?= normal

TARGET_CFLAGS   = -pipe
ifeq ($(GCC_OPTIMIZE), debug)
TARGET_CFLAGS   += -O0 -g -ggdb3
endif
ifeq ($(GCC_OPTIMIZE), size)
TARGET_CFLAGS   += -Os
endif
ifeq ($(GCC_OPTIMIZE), normal)
TARGET_CFLAGS   += -O2
endif
TARGET_CFLAGS   += -I$(TARGETPREFIX)/include
ifneq ($(PLATFORM), nevis)
TARGET_CFLAGS   += -I$(TARGETPREFIX_BASE)/include
endif
TARGET_CFLAGS   += -D_GLIBCXX_USE_CXX11_ABI=0

TARGET_CPPFLAGS = $(TARGET_CFLAGS)
TARGET_CXXFLAGS = $(TARGET_CFLAGS)
TARGET_LDFLAGS  = -Wl,-O1 -L$(TARGETLIB)
LD_FLAGS        = $(TARGET_LDFLAGS)

VPATH = $(D)

NEUTRINO_PKG = $(FLAVOUR)

# append */sbin for those not having sbin in their path. We need it.
PATH := $(BUILD_TOOLS)/bin:$(HOSTPREFIX)/bin:$(CROSS_DIR)/bin:$(PATH):/sbin:/usr/sbin:/usr/local/sbin

PKG_CONFIG = $(HOSTPREFIX)/bin/$(TARGET)-pkg-config
PKG_CONFIG_PATH = $(TARGETPREFIX)/lib/pkgconfig
PKG_CONFIG_PATH_BASE = $(TARGETPREFIX_BASE)/lib/pkgconfig

# helper-"functions":
REWRITE_LIBTOOL = sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX)/lib'," $(TARGETPREFIX)/lib
REWRITE_PKGCONF = sed -i "s,^prefix=.*,prefix='$(TARGETPREFIX)',"
REWRITE_LIBTOOL_BASE = sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX_BASE)/lib'," $(TARGETPREFIX_BASE)/lib
REWRITE_PKGCONF_BASE = sed -i "s,^prefix=.*,prefix='$(TARGETPREFIX_BASE)',"
REWRITE_LIBTOOL_OPT = sed -i "s,^libdir=.*,libdir='$(TARGETPREFIX)/opt/pkg/lib'," $(TARGETPREFIX)/opt/pkg/lib
REWRITE_PKGCONF_OPT = sed -i "s,^prefix=.*,prefix='$(TARGETPREFIX)/opt/pkg',"

# unpack tarballs, clean up
UNTAR = tar -C $(BUILD_TMP) -xf $(ARCHIVE)
REMOVE = rm -rf $(BUILD_TMP)
PATCH = patch -p1 -i $(PATCHES)
# wget tarballs into archive directory
WGET = wget --no-check-certificate -t6 -T20 -c -P $(ARCHIVE)

CONFIGURE_OPTS = \
	--build=$(BUILD) --host=$(TARGET)

BUILDENV = \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)

SCONS = \
	CCFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS) $$LIBS_X" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	CC=$(TARGET)-gcc \
	scons

OPKG_SH_ENV  = PACKAGE_DIR=$(PACKAGE_DIR)
OPKG_SH_ENV += STRIP=$(TARGET)-strip
OPKG_SH_ENV += MAINTAINER="$(MAINTAINER)"
OPKG_SH_ENV += ARCH=$(BOXARCH)
OPKG_SH_ENV += SOURCE=$(PKGPREFIX_BASE)
OPKG_SH_ENV += BUILD_TMP=$(BUILD_TMP)
OPKG_SH = $(OPKG_SH_ENV) opkg.sh

CST_GIT    = $(SOURCE_DIR)


#CST_LIBCS  = $(CST_GIT)/cst-public-drivers/libs/libcoolstream-mt.so
#CST_LIBNXP = $(CST_GIT)/cst-public-drivers/libs/libnxp.so
#CST_LIBCA  = $(CST_GIT)/cst-public-drivers/libs/libca-sc.so
#CST_DRIVER = $(CST_GIT)/cst-public-drivers/drivers/$(CST_KVER)-nevis
#CST_LIBS   = $(CST_LIBCS) $(CST_LIBNXP) $(CST_LIBCA)
