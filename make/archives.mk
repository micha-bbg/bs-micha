
$(ARCHIVE)/opkg-$(OPKG_VER).tar.gz:
	$(WGET) http://git.yoctoproject.org/cgit/cgit.cgi/opkg/snapshot/opkg-$(OPKG_VER).tar.gz

$(ARCHIVE)/opkg-$(OPKG_SVN_VER).tar.gz:
	set -e; cd $(BUILD_TMP); \
		rm -rf opkg-$(OPKG_SVN_VER); \
		svn export -r $(OPKG_SVN) http://opkg.googlecode.com/svn/trunk/ opkg-$(OPKG_SVN_VER); \
		tar cvpzf $@ opkg-$(OPKG_SVN_VER); \
		rm -rf opkg-$(OPKG_SVN_VER)

$(ARCHIVE)/zlib-$(ZLIB_VER).tar.xz:
	$(WGET) http://downloads.sourceforge.net/project/libpng/zlib/$(ZLIB_VER)/zlib-$(ZLIB_VER).tar.xz

$(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz:
	$(WGET) http://artfiles.org/openbsd/OpenSSH/portable/openssh-$(OPENSSH_VER).tar.gz

$(ARCHIVE)/lzo-$(LZO_VER).tar.gz:
	$(WGET) http://www.oberhumer.com/opensource/lzo/download/lzo-$(LZO_VER).tar.gz

$(ARCHIVE)/mtd-utils-$(MTD_UTILS_VER).tar.bz2:
	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-$(MTD_UTILS_VER).tar.bz2

$(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz:
	$(WGET) https://bs-micha.tuxcode.de/download/crosstool-ng/crosstool-ng-$(CROSSTOOL_NG_VER).tar.xz

$(ARCHIVE)/unrarsrc-$(UNRAR_VER).tar.gz:
	$(WGET) http://www.rarlab.com/rar/unrarsrc-$(UNRAR_VER).tar.gz

$(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2:
	$(WGET) http://busybox.net/downloads/busybox-$(BUSYBOX_VER).tar.bz2

# standalone wget for retrieving files using HTTP, HTTPS and FTP
$(ARCHIVE)/wget-$(WGET_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/wget/$(notdir $@)

$(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VER)/e2fsprogs-$(E2FSPROGS_VER).tar.gz

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

$(ARCHIVE)/libpng-$(PNG_VER).tar.xz:
	$(WGET) http://download.sourceforge.net/libpng/$(notdir $@)

$(ARCHIVE)/curl-$(CURL_VER).tar.bz2:
	$(WGET) http://curl.haxx.se/download/$(lastword $(subst /, ,$@))

$(ARCHIVE)/curl-ca-bundle.crt:
	cd $(ARCHIVE); \
		wget http://curl.haxx.se/ca/cacert.pem.bz2; \
		bunzip2 cacert.pem.bz2; \
		mv cacert.pem curl-ca-bundle.crt

$(ARCHIVE)/libmad-$(MAD_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/$(MAD_VER)/libmad-$(MAD_VER).tar.gz

$(ARCHIVE)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/$(ID3TAG_VER)$(ID3TAG_SUBVER)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER).tar.gz

$(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER_PATH)/freetype-$(FREETYPE_VER).tar.bz2

$(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/libjpeg-turbo/files/$(JPEG_TURBO_VER)/libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz

$(ARCHIVE)/giflib-$(GIFLIB_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/giflib/files/$(notdir $@)

$(ARCHIVE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2:
	$(WGET) http://www.saftware.de/libdvbsi++/libdvbsi++-$(LIBDVBSI_VER).tar.bz2

$(ARCHIVE)/lua-$(LUA_VER).tar.gz:
	$(WGET) http://www.lua.org/ftp/$(notdir $@)

$(ARCHIVE)/luaposix-$(LUAPOSIX_VER).tar.bz2: | $(HOSTPREFIX)/bin/get-git-archive.sh
	get-git-archive.sh git://github.com/luaposix/luaposix.git release-v$(LUAPOSIX_VER) $(notdir $@) $(ARCHIVE)

$(ARCHIVE)/Lua-cURL$(LUACURL_VER).tar.xz:
	$(WGET) https://bs-micha.tuxcode.de/download/Lua-cURL$(LUACURL_VER).tar.xz

$(ARCHIVE)/lua-llthreads2-$(LUA_LLTHREADS2_VER).zip:
	$(WGET) -O $@ https://github.com/moteus/lua-llthreads2/archive/v$(LUA_LLTHREADS2_VER).zip

$(ARCHIVE)/lzmq-$(LUA_LZMQ_VER).zip:
	$(WGET) -O $@ https://github.com/zeromq/lzmq/archive/v$(LUA_LZMQ_VER).zip

$(ARCHIVE)/zeromq-$(ZEROMQ_VER).tar.gz:
	$(WGET) http://download.zeromq.org/zeromq-$(ZEROMQ_VER).tar.gz

$(ARCHIVE)/zeromq-$(ZEROMQ3_VER).tar.gz:
	$(WGET) http://download.zeromq.org/zeromq-$(ZEROMQ3_VER).tar.gz

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
	$(WGET) https://bs-micha.tuxcode.de/download/fuse-$(FUSE_VER).tar.gz
#	$(WGET) https://sourceforge.net/projects/fusefilesysteminuserspace/files/fuse-$(FUSE_VER)/fuse-$(FUSE_VER).tar.bz2

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

$(ARCHIVE)/gettext-$(GETTEXT_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/pub/gnu/gettext/gettext-$(GETTEXT_VER).tar.xz

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

$(ARCHIVE)/u-boot-$(UBOOT_VER).tar.bz2:
	$(WGET) https://bs-micha.tuxcode.de/download/u-boot/u-boot-$(UBOOT_VER).tar.bz2

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

$(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz:
	$(WGET) http://swupdate.openvpn.org/community/releases/openvpn-$(OPENVPN_VER).tar.xz

$(ARCHIVE)/killproc-$(KILLPROC_VER).tar.gz:
	$(WGET) ftp://ftp.suse.de/pub/projects/init/killproc-$(KILLPROC_VER).tar.gz

$(ARCHIVE)/ncftp-$(NCFTP_VER)-src.tar.bz2:
	$(WGET) ftp://ftp.ncftp.com/ncftp/ncftp-$(NCFTP_VER)-src.tar.bz2

$(ARCHIVE)/expat-$(EXPAT_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)/expat-$(EXPAT_VER).tar.gz/download
	mv -f $(ARCHIVE)/download $(ARCHIVE)/expat-$(EXPAT_VER).tar.gz

$(ARCHIVE)/luaexpat-$(LUA_EXPAT_VER).tar.gz:
	$(WGET) http://matthewwild.co.uk/projects/luaexpat/luaexpat-$(LUA_EXPAT_VER).tar.gz

$(ARCHIVE)/luasocket-master.zip:
	$(WGET) https://github.com/diegonehab/luasocket/archive/master.zip
	mv $(ARCHIVE)/master.zip $(ARCHIVE)/luasocket-master.zip

$(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz:
	$(WGET) ftp://xmlsoft.org/libxml2/libxml2-$(LIBXML2_VER).tar.gz

$(ARCHIVE)/libxslt-git-snapshot.tar.gz:
	$(WGET) ftp://xmlsoft.org/libxml2/libxslt-git-snapshot.tar.gz

$(ARCHIVE)/libbluray-$(LIBBLURAY_VER).tar.bz2:
	$(WGET) http://ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VER)/libbluray-$(LIBBLURAY_VER).tar.bz2

$(ARCHIVE)/exfat-utils-$(EXFAT_UTILS_VER).tar.gz:
	$(WGET) https://github.com/relan/exfat/releases/download/v1.2.1/exfat-utils-$(EXFAT_UTILS_VER).tar.gz

$(ARCHIVE)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz:
	$(WGET) https://github.com/relan/exfat/releases/download/v1.2.1/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz

$(ARCHIVE)/iptables-$(IPTABLES_VER).tar.bz2:
	$(WGET) http://www.netfilter.org/projects/iptables/files/iptables-$(IPTABLES_VER).tar.bz2

$(ARCHIVE)/$(CUSTOM_KERNEL_VER).tar.xz:
	$(WGET) https://bs-micha.tuxcode.de/download/cst-kernel/$(CUSTOM_KERNEL_VER).tar.xz

$(ARCHIVE)/cst-kernel_$(KERNEL_FILE_VER).tar.xz:
	$(WGET) https://bs-micha.tuxcode.de/download/cst-kernel/cst-kernel_$(KERNEL_FILE_VER).tar.xz

$(ARCHIVE)/linux-$(CUSTOM_KERNEL_VER).tar.xz:
	$(WGET) https://bs-micha.tuxcode.de/download/cst-kernel/linux-$(CUSTOM_KERNEL_VER).tar.xz

$(ARCHIVE)/kernelcheck-$(KERNELCHECK_VER).tar.xz:
	$(WGET) https://bs-micha.tuxcode.de/download/kernelcheck-$(KERNELCHECK_VER).tar.xz

$(ARCHIVE)/gcc-$(CUSTOM_GCC_VER).tar.xz:
	$(WGET) https://bs-micha.tuxcode.de/download/gcc/gcc-$(CUSTOM_GCC_VER).tar.xz

$(ARCHIVE)/libtirpc-$(LIBTIRPC_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/libtirpc/files/libtirpc/$(LIBTIRPC_VER)/libtirpc-$(LIBTIRPC_VER).tar.bz2

$(ARCHIVE)/rpcbind-$(RPCBIND_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/rpcbind/files/rpcbind/$(RPCBIND_VER)/rpcbind-$(RPCBIND_VER).tar.bz2

$(ARCHIVE)/nfs-utils-$(NFS_UTILS_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/nfs/files/nfs-utils/$(NFS_UTILS_VER)/nfs-utils-$(NFS_UTILS_VER).tar.bz2

$(ARCHIVE)/pugixml-$(PUGIXML_VER).tar.gz:
	$(WGET) http://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VER)/pugixml-$(PUGIXML_VER).tar.gz

$(ARCHIVE)/rtmpdump-$(LIBRTMP_VER).tgz:
	$(WGET) http://rtmpdump.mplayerhq.hu/download/rtmpdump-$(LIBRTMP_VER).tgz

$(ARCHIVE)/util-linux-$(UTIL_LINUX_VER).tar.xz:
	$(WGET) https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_MAJOR)/util-linux-$(UTIL_LINUX_VER).tar.xz

$(ARCHIVE)/libarchive-$(LIBARCHIVE_VER).tar.gz:
	$(WGET) http://www.libarchive.org/downloads/libarchive-$(LIBARCHIVE_VER).tar.gz
