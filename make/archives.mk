
$(ARCHIVE)/opkg-$(OPKG_VER).tar.gz:
	$(WGET) http://opkg.googlecode.com/files/opkg-$(OPKG_VER).tar.gz

$(ARCHIVE)/opkg-$(OPKG_SVN_VER).tar.gz:
	set -e; cd $(BUILD_TMP); \
		rm -rf opkg-$(OPKG_SVN_VER); \
		svn export -r $(OPKG_SVN) http://opkg.googlecode.com/svn/trunk/ opkg-$(OPKG_SVN_VER); \
		tar cvpzf $@ opkg-$(OPKG_SVN_VER); \
		rm -rf opkg-$(OPKG_SVN_VER)

$(ARCHIVE)/zlib-$(ZLIB_VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libpng/zlib/$(ZLIB_VER)/zlib-$(ZLIB_VER).tar.bz2

$(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz:
	$(WGET) http://artfiles.org/openbsd/OpenSSH/portable/openssh-$(OPENSSH_VER).tar.gz

$(ARCHIVE)/lzo-$(LZO_VER).tar.gz:
	$(WGET) http://www.oberhumer.com/opensource/lzo/download/lzo-$(LZO_VER).tar.gz

$(ARCHIVE)/mtd-utils-$(MTD_UTILS_VER).tar.bz2:
	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-$(MTD_UTILS_VER).tar.bz2

$(ARCHIVE)/crosstool-ng-$(CROSSTOOL-NG_VER).tar.bz2:
	$(WGET) http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$(CROSSTOOL-NG_VER).tar.bz2

$(ARCHIVE)/unrarsrc-$(UNRAR_VER).tar.gz:
	$(WGET) http://www.rarlab.com/rar/unrarsrc-$(UNRAR_VER).tar.gz

$(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2:
	$(WGET) http://busybox.net/downloads/busybox-$(BUSYBOX_VER).tar.bz2

# standalone wget for retrieving files using HTTP, HTTPS and FTP
$(ARCHIVE)/wget-$(WGET_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/wget/$(notdir $@)

$(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz:
	$(WGET) http://prdownloads.sourceforge.net/e2fsprogs/e2fsprogs-$(E2FSPROGS_VER).tar.gz

$(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz:
	$(WGET) https://security.appspot.com/downloads/vsftpd-$(VSFTPD_VER).tar.gz

$(ARCHIVE)/rsync-$(RSYNC_VER).tar.gz:
	$(WGET) http://samba.anu.edu.au/ftp/rsync/src/rsync-$(RSYNC_VER).tar.gz

$(ARCHIVE)/procps-$(PROCPS_VER).tar.gz:
	$(WGET) http://procps.sourceforge.net/procps-$(PROCPS_VER).tar.gz

$(ARCHIVE)/ncurses-$(NCURSES_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(NCURSES_VER).tar.gz

$(ARCHIVE)/ntp-$(NTP_VER).tar.gz:
	$(WGET) http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-$(NTP_VER).tar.gz

$(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz:
	$(WGET) http://tuxera.com/opensource/ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz

$(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz:
	$(WGET) http://www.dbox2world.net/download/fbshot-$(FBSHOT_VER).tar.gz
#	$(WGET) http://www.sfires.net/stuff/fbshot/fbshot-$(FBSHOT_VER).tar.gz

$(ARCHIVE)/libpng-$(PNG_VER).tar.xz:
	$(WGET) http://download.sourceforge.net/libpng/$(notdir $@)

$(ARCHIVE)/curl-$(CURL_VER).tar.bz2:
	$(WGET) http://curl.haxx.se/download/$(lastword $(subst /, ,$@))

$(ARCHIVE)/libmad-$(MAD_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/$(MAD_VER)/libmad-$(MAD_VER).tar.gz

$(ARCHIVE)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/$(ID3TAG_VER)$(ID3TAG_SUBVER)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER).tar.gz

$(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER_PATH)/freetype-$(FREETYPE_VER).tar.bz2/download
	mv $(ARCHIVE)/download $(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2

$(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/libjpeg-turbo/files/$(JPEG_TURBO_VER)/libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz

$(ARCHIVE)/giflib-$(GIFLIB_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/giflib/files/giflib-5.x/$(notdir $@)

$(ARCHIVE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2:
	$(WGET) http://www.saftware.de/libdvbsi++/libdvbsi++-$(LIBDVBSI_VER).tar.bz2

$(ARCHIVE)/lua-$(LUA_VER).tar.gz:
	$(WGET) http://www.lua.org/ftp/$(notdir $@)

$(ARCHIVE)/luaposix-$(LUAPOSIX_VER).tar.bz2: | $(HOSTPREFIX)/bin/get-git-archive.sh
	get-git-archive.sh git://github.com/luaposix/luaposix.git release-v$(LUAPOSIX_VER) $(notdir $@) $(ARCHIVE)

$(ARCHIVE)/libvorbisidec_$(VORBISIDEC_VER)$(VORBISIDEC_VER_APPEND).tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_$(VORBISIDEC_VER)$(VORBISIDEC_VER_APPEND).tar.gz

$(ARCHIVE)/flac-$(FLAC_VER).tar.gz:
	$(WGET) http://downloads.xiph.org/releases/flac/flac-$(FLAC_VER).tar.gz

$(ARCHIVE)/flac-$(FLAC_VER).tar.xz:
	$(WGET) http://downloads.xiph.org/releases/flac/flac-$(FLAC_VER).tar.xz

$(ARCHIVE)/ffmpeg-$(FFMPEG_VER).tar.bz2:
	$(WGET) http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG_VER).tar.bz2

$(ARCHIVE)/openssl-$(OPENSSL_VER)$(OPENSSL_SUBVER).tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-$(OPENSSL_VER)$(OPENSSL_SUBVER).tar.gz

$(ARCHIVE)/libogg-$(OGG_VER).tar.gz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-$(OGG_VER).tar.gz

$(ARCHIVE)/gdb-$(GDB_VER).tar.bz2:
	$(WGET) ftp://sourceware.org/pub/gdb/releases/gdb-$(GDB_VER).tar.bz2

$(ARCHIVE)/strace-$(STRACE_VER).tar.xz:
	$(WGET) http://downloads.sourceforge.net/project/strace/strace/$(STRACE_VER)/$(notdir $@)

$(ARCHIVE)/tzdata$(TZ_VER).tar.gz:
	$(WGET) ftp://ftp.iana.org/tz/releases/tzdata$(TZ_VER).tar.gz

$(ARCHIVE)/tzcode$(TZ_VER).tar.gz:
	$(WGET) ftp://ftp.iana.org/tz/releases/tzcode$(TZ_VER).tar.gz

$(ARCHIVE)/libiconv-$(ICONV_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-$(ICONV_VER).tar.gz

$(ARCHIVE)/fuse-$(FUSE_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/fuse/fuse-2.X/$(FUSE_VER)/fuse-$(FUSE_VER).tar.gz

$(ARCHIVE)/readline-$(READLINE_VER).tar.gz:
	$(WGET) ftp://ftp.cwru.edu/pub/bash/readline-$(READLINE_VER).tar.gz

$(ARCHIVE)/parted-$(PARTED_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/parted/parted-$(PARTED_VER).tar.xz

$(ARCHIVE)/mc-$(MC_VER).tar.xz:
	$(WGET) http://ftp.midnight-commander.org/mc-$(MC_VER).tar.xz

$(ARCHIVE)/glib-$(GLIB_VER).tar.xz:
	$(WGET) http://ftp.gnome.org/pub/gnome/sources/glib/$(GLIB_MAJOR).$(GLIB_MINOR)/$(lastword $(subst /, ,$@))

$(ARCHIVE)/libffi-$(LIBFFI_VER).tar.gz:
	$(WGET) ftp://sourceware.org/pub/libffi/libffi-$(LIBFFI_VER).tar.gz

$(ARCHIVE)/gettext-$(GETTEXT_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/gettext/gettext-(GETTEXT_VER).tar.gz

$(ARCHIVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz:
	$(WGET) http://hostap.epitest.fi/releases/wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz

$(ARCHIVE)/libnl-$(LIBNL_VER).tar.gz:
	$(WGET) http://www.carisma.slowglass.com/~tgr/libnl/files/libnl-$(LIBNL_VER).tar.gz

$(ARCHIVE)/samba-$(SAMBA2_VER).tar.gz:
	$(WGET) http://samba.org/samba/ftp/old-versions/samba-$(SAMBA2_VER).tar.gz

$(ARCHIVE)/samba-$(SAMBA3_VER).tar.gz:
	$(WGET) http://ftp.samba.org/pub/samba/stable/samba-$(SAMBA3_VER).tar.gz

$(ARCHIVE)/gnutls-$(GNUTLS_VER).tar.xz:
	$(WGET) ftp://ftp.gnutls.org/gcrypt/gnutls/v3.1/gnutls-$(GNUTLS_VER).tar.xz

$(ARCHIVE)/gmp-$(GMP_VER).tar.xz:
	$(WGET) ftp://ftp.gmplib.org/pub/gmp-$(GMP_VER)/gmp-$(GMP_VER).tar.xz

$(ARCHIVE)/nettle-$(NETTLE_VER).tar.gz:
	$(WGET) http://www.lysator.liu.se/~nisse/archive/nettle-$(NETTLE_VER).tar.gz

$(ARCHIVE)/linux-2.6.34.13.tar.bz2:
	$(WGET) https://www.kernel.org/pub/linux/kernel/v2.6/longterm/v2.6.34/linux-2.6.34.13.tar.bz2

$(ARCHIVE)/linux-2.6.34.tar.bz2:
	$(WGET) https://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.34.tar.bz2

$(ARCHIVE)/linux-2.6.34.14.tar.bz2:
	$(WGET) https://www.kernel.org/pub/linux/kernel/v2.6/longterm/v2.6.34/linux-2.6.34.14.tar.bz2

$(ARCHIVE)/linux-2.6.26.8.tar.bz2:
	$(WGET) http://ftp.linux.org.uk/pub/linux/linux-2.6/linux-2.6.26.8.tar.bz2

$(ARCHIVE)/pkg-config-$(PKGCONFIG_VER).tar.gz:
	$(WGET) http://pkgconfig.freedesktop.org/releases/pkg-config-$(PKGCONFIG_VER).tar.gz

## build tools for host
$(ARCHIVE)/make-$(MAKE_VER).tar.bz2:
	$(WGET) http://ftp.gnu.org/gnu/make/$(notdir $@)

$(ARCHIVE)/m4-$(M4_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/m4/$(notdir $@)

$(ARCHIVE)/autoconf-$(AUTOCONF_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/autoconf/$(notdir $@)

$(ARCHIVE)/automake-$(AUTOMAKE_VER).tar.$(AUTOMAKE_ARCH):
	$(WGET) http://ftp.gnu.org/gnu/automake/$(notdir $@)

$(ARCHIVE)/libtool-$(LIBTOOL_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/libtool/$(notdir $@)

#libsigc++: typesafe Callback Framework for C++
$(ARCHIVE)/libsigc++-$(LIBSIGCPP_VER).tar.xz:
	$(WGET) http://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGCPP_MAJOR).$(LIBSIGCPP_MINOR)/libsigc++-$(LIBSIGCPP_VER).tar.xz

$(ARCHIVE)/u-boot-2009.03.tar.bz2:
	$(WGET) http://ftp.denx.de/pub/u-boot/u-boot-2009.03.tar.bz2

## libSDL V1
$(ARCHIVE)/SDL-$(LIBSDL_VER).tar.gz:
	$(WGET) http://www.libsdl.org/release/SDL-$(LIBSDL_VER).tar.gz

$(ARCHIVE)/SDL_ttf-$(SDL_TTF_VER).tar.gz:
	$(WGET) http://www.libsdl.org/projects/SDL_ttf/release/SDL_ttf-$(SDL_TTF_VER).tar.gz

$(ARCHIVE)/SDL_mixer-$(SDL_MIXER_VER).tar.gz:
	$(WGET) http://www.libsdl.org/projects/SDL_mixer/release/SDL_mixer-$(SDL_MIXER_VER).tar.gz

## libSDL V2
$(ARCHIVE)/SDL2-$(LIBSDL2_VER).tar.gz:
	$(WGET) http://www.libsdl.org/release/SDL2-$(LIBSDL2_VER).tar.gz

$(ARCHIVE)/SDL2_ttf-$(SDL2_TTF_VER).tar.gz:
	$(WGET) http://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(SDL2_TTF_VER).tar.gz

$(ARCHIVE)/SDL2_mixer-$(SDL2_MIXER_VER).tar.gz:
	$(WGET) http://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$(SDL2_MIXER_VER).tar.gz

$(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.gz:
	$(WGET) http://swupdate.openvpn.org/community/releases/openvpn-$(OPENVPN_VER).tar.gz

$(ARCHIVE)/killproc-$(KILLPROC_VER).tar.gz:
	$(WGET) ftp://ftp.suse.de/pub/projects/init/killproc-$(KILLPROC_VER).tar.gz
