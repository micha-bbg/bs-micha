
# opkg; a lightweight package management system based on Ipkg
#OPKG_VER=0.3.1
OPKG_VER=0.3.3

## for recent versions, the SVN trunk rev is used:
#OPKG_SVN=635
#OPKG_SVN_VER=$(OPKG-VER)+svnr$(OPKG_SVN)

# pkg-config; a helper tool used when compiling applications and libraries to insert the correct compiler options
PKGCONFIG_VER=0.28

# zlib; compression an decompressin library
ZLIB_VER=1.2.8

# openssh
OPENSSH_VER = 6.2p2

# lzo
LZO_VER = 2.06

# mtd-utils for the host...
MTD_UTILS_VER = 1.5.0

# unrar
UNRAR_VER = 5.2.7

# busybox; combines tiny versions of many common UNIX utilities into a single binary
ifneq ($(PLATFORM), nevis)
BUSYBOX_VER=1.23.2
else
BUSYBOX_VER=1.21.0
endif

# wget for retrieving files using HTTP, HTTPS and FTP
WGET_VER=1.18

# e2fsprogs; filesystem utilities for use with the ext[x] filesystem
E2FSPROGS_VER=1.42.12

# vsftpd; a small, tiny and "v"ery "s"ecure "ftp" deamon
VSFTPD_VER=3.0.2

# rsync; fast and extraordinarily versatile file copying tool
RSYNC_VER=3.1.1

# procps; a bunch of small useful utilities that give information about processes using the /proc filesystem
PROCPS_VER=3.2.8

# ncurses; software for controlling writing to the console screen
NCURSES_VER=6.0

# ntp; synchronize system clock over a network
NTP_VER=4.2.8p3

# ntfs-3g; file system driver for the NTFS file system, enabling read/write support of NTFS file systems
NTFS_3G_VER=2016.2.22

# fbshot;  a small program that allowes you to take screenshots from the framebuffer
FBSHOT_VER=0.3

# libpng; reference library for reading and writing PNGs
PNG_VER_X=15
PNG_VER=1.5.24

# libdid3tag; writing, reading and manipulating ID3 tags
ID3TAG_VER=0.15.1
ID3TAG_SUBVER=b

# libmad; MPEG audio decoder
MAD_VER=0.15.1b

# freetype; free, high-quality and portable Font engine
FREETYPE_MAJOR=2
FREETYPE_MINOR=6
FREETYPE_MICRO=1
FREETYPE_NANO=n/a
ifeq ($(FREETYPE_MICRO), n/a)
FREETYPE_VER_PATH=$(FREETYPE_MAJOR).$(FREETYPE_MINOR)
else
FREETYPE_VER_PATH=$(FREETYPE_MAJOR).$(FREETYPE_MINOR).$(FREETYPE_MICRO)
endif
ifeq ($(FREETYPE_NANO), n/a)
FREETYPE_VER=$(FREETYPE_VER_PATH)
else
FREETYPE_VER=$(FREETYPE_VER_PATH).$(FREETYPE_NANO)
endif

FREETYPE_VER_OLD=2.3.12

# libjpeg-turbo; a derivative of libjpeg for x86 and x86-64 processors which uses SIMD instructions (MMX, SSE2, etc.) to accelerate baseline JPEG compression and decompression
JPEG_TURBO_VER=1.4.0

# libungif; converting images
UNGIF_VER=4.1.4

# giflib: replaces libungif
GIFLIB_VER=5.1.1

# libdvbsi++; libdvbsi++ is a open source C++ library for parsing DVB Service Information and MPEG-2 Program Specific Information.
LIBDVBSI_VER=0.3.6

# lua: easily embeddable scripting language
LUA_ABIVER=5.2
LUA_VER=$(LUA_ABIVER).3

# luaposix: posix bindings for lua
#LUAPOSIX_VER=5.1.28
LUAPOSIX_VER=31

LUACURL_VER=v3

EXPAT_VER = 2.1.0
LUA_EXPAT_VER = 1.2.0

LUA_SOCKET_VER = 3.0-rc1

LUA_LLTHREADS2_VER = 0.1.3
LUA_LZMQ_VER = 0.4.3
ZEROMQ3_VER = 3.2.5
ZEROMQ_VER = 4.1.4

# libvorbisidec;  libvorbisidec is an Ogg Vorbis audio decoder (also known as "tremor") with no floating point arithmatic
VORBISIDEC_SVN=18153
VORBISIDEC_VER=1.0.2+svn$(VORBISIDEC_SVN)
VORBISIDEC_VER_APPEND=.orig

# libFLAC
FLAC_VER = 1.3.0

# libffmpeg; complete, cross-platform solution to record, convert and stream audio and video
FFMPEG_VER=head

# libogg; encoding, decoding of the ogg file format
OGG_VER=1.3.0

# gdb; the GNU debugger
GDB_VER=linaro-7.8-2014.09

STRACE_VER=4.7

# timezone files
TZ_VER = 2013d

# libiconv; converting encodings
ICONV_VER=1.14

# FUSE; filesystems in userspace
FUSE_VER=2.9.3

READLINE_VER = 6.2

PARTED_VER = 3.2

# mc; the famous midnight commander
MC_VER=4.8.14

LIBFFI_VER = 3.2.1

# glib; the low-level core library that forms the basis for projects such as GTK+ and GNOME
GLIB_MAJOR=2
GLIB_MINOR=44
GLIB_MICRO=0
GLIB_VER=$(GLIB_MAJOR).$(GLIB_MINOR).$(GLIB_MICRO)

# gettext
GETTEXT_VER = 0.19.4

#WPA_SUPPLICANT_VER = 2.0
WPA_SUPPLICANT_VER = 0.7.3

LIBNL_VER = 3.2.22

SAMBA2_VER = 2.2.12
SAMBA3_VER = 3.3.9

GNUTLS_VER = 3.1.3

GMP_VER = 5.1.2

NETTLE_VER  = 2.7.1

## build tools for host ###############
MAKE_VER = 3.82
M4_VER = 1.4.17
AUTOCONF_VER = 2.69
AUTOMAKE_VER = 1.14
AUTOMAKE_ARCH=xz
LIBTOOL_VER = 2.4.2
#######################################

#libsigc++: typesafe Callback Framework for C++
LIBSIGCPP_MAJOR=2
LIBSIGCPP_MINOR=3
LIBSIGCPP_MICRO=1
LIBSIGCPP_VER=$(LIBSIGCPP_MAJOR).$(LIBSIGCPP_MINOR).$(LIBSIGCPP_MICRO)

## libSDL V1
LIBSDL_VER = 1.2.15
SDL_TTF_VER=2.0.11
SDL_MIXER_VER=1.2.12

## libSDL V2
LIBSDL2_VER = 2.0.4
SDL2_TTF_VER=2.0.14
SDL2_MIXER_VER=2.0.1

OPENVPN_VER=2.3.9
KILLPROC_VER=2.13

NCFTP_VER=3.2.5

# curl; command line tool for transferring data with URL syntax
#CURL_VER=7.46.0
CURL_VER=7.50.3

# openssl; toolkit for the SSL v2/v3 and TLS v1 protocol
OPENSSL_VER=1.0.2
OPENSSL_SUBVER=j

ifeq ($(PLATFORM), nevis)
LIBXML2_VER = 2.8.0
else
LIBXML2_VER = 2.9.1
endif	# ifeq ($(PLATFORM), nevis)

LIBXSLT_VER = 1.1.28

LIBBLURAY_VER=0.5.0

EXFAT_UTILS_VER = 1.2.1
FUSE_EXFAT_VER = 1.2.1

IPTABLES_VER = 1.4.21
IPTABLES_RULES_VER = 0.1

SYSTEMLIBS_DUMMY_VER = 0.1

KERNELCHECK_VER = 0.4.0

UBOOT_VER = 2015.04

LIBTIRPC_VER  = 0.2.4
RPCBIND_VER   = 0.2.1
NFS_UTILS_VER = 1.2.6

# crosstool-ng versions
#CT_VER_NEVIS  = 1.20.0_20150218-2311_git-master_41722f5
CT_VER_NEVIS  = 1.22.0_20160922-1733_git-master_531eab4

CT_VER_APOLLO = 1.22.0_20160922-1733_git-master_531eab4
CT_VER_KRONOS = 1.22.0_20160922-1733_git-master_531eab4

PUGIXML_VER = 1.6

LIBRTMP_VER = 2.3

LIBARCHIVE_VER = 3.1.2

UTIL_LINUX_MAJOR = 2.26
UTIL_LINUX_MINOR = 2
UTIL_LINUX_VER = $(UTIL_LINUX_MAJOR).$(UTIL_LINUX_MINOR)

ifeq ($(PLATFORM), nevis)
## nevis platform
KERNEL_FILE_VER = 2.6.34.13-cnxt_2012-12-09_1613_6ff43b3
KERNEL_BUILD = 49
else
## apollo / kronos platform
KERNEL_FILE_VER = cst_3.10.93_2015-12-02_0824_c439541
KERNEL_BUILD = 16

## 'GIMP header image file' in $(PATCHES)/kernel,
## exported by GIMP from a picture
## default (if empty) is none
KRNL_LOGO       = splash_img_02.h
endif
