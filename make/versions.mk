
# opkg; a lightweight package management system based on Ipkg
OPKG_VER=0.2.0

## for recent versions, the SVN trunk rev is used:
#OPKG_SVN=635
#OPKG_SVN_VER=$(OPKG-VER)+svnr$(OPKG_SVN)

# pkg-config; a helper tool used when compiling applications and libraries to insert the correct compiler options
PKGCONFIG_VER=0.26

# zlib; compression an decompressin library
ZLIB_VER=1.2.7

# openssh
OPENSSH_VER = 6.2p2

# lzo
LZO_VER = 2.06

# mtd-utils for the host...
MTD_UTILS_VER = 1.5.0

# unrar
UNRAR_VER = 5.0.10

# busybox; combines tiny versions of many common UNIX utilities into a single binary
#BUSYBOX_VER=1.19.4
BUSYBOX_VER=1.21.0

# wget for retrieving files using HTTP, HTTPS and FTP
WGET_VER=1.14

# e2fsprogs; filesystem utilities for use with the ext[x] filesystem
E2FSPROGS_VER=1.42.8

# vsftpd; a small, tiny and "v"ery "s"ecure "ftp" deamon
VSFTPD_VER=3.0.2

# rsync; fast and extraordinarily versatile file copying tool
RSYNC_VER=3.0.7

# procps; a bunch of small useful utilities that give information about processes using the /proc filesystem
PROCPS_VER=3.2.8

# ncurses; software for controlling writing to the console screen
NCURSES_VER=5.6

# ntp; synchronize system clock over a network
NTP_VER=4.2.6p5

# ntfs-3g; file system driver for the NTFS file system, enabling read/write support of NTFS file systems
NTFS_3G_VER=2013.1.13

# fbshot;  a small program that allowes you to take screenshots from the framebuffer
FBSHOT_VER=0.3

# libpng; reference library for reading and writing PNGs
#PNG_VER_X=12
#PNG_VER=1.2.50
PNG_VER_X=15
PNG_VER=1.5.17
#PNG_VER_X=16
#PNG_VER=1.6.1

# curl; command line tool for transferring data with URL syntax
CURL_VER=7.33.0

# libdid3tag; writing, reading and manipulating ID3 tags
ID3TAG_VER=0.15.1
ID3TAG_SUBVER=b

# libmad; MPEG audio decoder
MAD_VER=0.15.1b

# freetype; free, high-quality and portable Font engine
FREETYPE_MAJOR=2
FREETYPE_MINOR=5
FREETYPE_MICRO=0
FREETYPE_NANO=1
FREETYPE_VER_PATH=$(FREETYPE_MAJOR).$(FREETYPE_MINOR).$(FREETYPE_MICRO)
FREETYPE_VER=$(FREETYPE_VER_PATH).$(FREETYPE_NANO)
FREETYPE_VER_OLD=2.3.12

# libjpeg-turbo; a derivative of libjpeg for x86 and x86-64 processors which uses SIMD instructions (MMX, SSE2, etc.) to accelerate baseline JPEG compression and decompression
JPEG_TURBO_VER=1.2.1

# libungif; converting images
UNGIF_VER=4.1.4

# giflib: replaces libungif
GIFLIB_VER=5.0.5

# libdvbsi++; libdvbsi++ is a open source C++ library for parsing DVB Service Information and MPEG-2 Program Specific Information.
LIBDVBSI_VER=0.3.6

# lua: easily embeddable scripting language
LUA_VER=5.2.1

# luaposix: posix bindings for lua
LUAPOSIX_VER=5.1.28

# libvorbisidec;  libvorbisidec is an Ogg Vorbis audio decoder (also known as "tremor") with no floating point arithmatic
VORBISIDEC_SVN=18153
VORBISIDEC_VER=1.0.2+svn$(VORBISIDEC_SVN)
VORBISIDEC_VER_APPEND=.orig

# libFLAC
#FLAC_VER = 1.2.1
FLAC_VER = 1.3.0

# libffmpeg; complete, cross-platform solution to record, convert and stream audio and video
FFMPEG_VER=1.2

# openssl; toolkit for the SSL v2/v3 and TLS v1 protocol
OPENSSL_VER=0.9.8
#OPENSSL_SUBVER=q
OPENSSL_SUBVER=y

# libogg; encoding, decoding of the ogg file format
OGG_VER=1.3.0

# gdb; the GNU debugger
#GDB_VER=7.4.1
GDB_VER=7.5.1

STRACE_VER=4.7

# timezone files
#TZ_VER = 2012b
TZ_VER = 2013d

# libiconv; converting encodings
ICONV_VER=1.14

# FUSE; filesystems in userspace
FUSE_VER=2.9.2

READLINE_VER = 6.2

PARTED_VER = 3.1

# mc; the famous midnight commander
MC_VER=4.8.10

LIBFFI_VER = 3.0.13

# glib; the low-level core library that forms the basis for projects such as GTK+ and GNOME
#GLIB_MAJOR=2
#GLIB_MINOR=26
#GLIB_MICRO=1

#GLIB_MAJOR=2
#GLIB_MINOR=29
#GLIB_MICRO=92

GLIB_MAJOR=2
GLIB_MINOR=37
GLIB_MICRO=6
GLIB_VER=$(GLIB_MAJOR).$(GLIB_MINOR).$(GLIB_MICRO)

# gettext
GETTEXT_VER = 0.18.3

#WPA_SUPPLICANT_VER = 2.0
WPA_SUPPLICANT_VER = 0.7.3

LIBNL_VER = 3.2.22

SAMBA2_VER = 2.2.12
SAMBA3_VER = 3.3.9

GNUTLS_VER = 3.1.3

GMP_VER = 5.1.2

NETTLE_VER  = 2.7.1

## build tools for host ###############
## suse 12.3
#MAKE_VER = 3.82
#M4_VER = 1.4.16
#AUTOCONF_VER = 2.69
#AUTOMAKE_VER = 1.12.1
#AUTOMAKE_ARCH=xz
#LIBTOOL_VER = 2.4.2

## last version
#MAKE_VER = 4.0
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

LIBSDL_VER = 1.2.15
SDL_TTF_VER=2.0.11
SDL_MIXER_VER=1.2.12
