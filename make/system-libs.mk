
$(D)/zlib: $(ARCHIVE)/zlib-$(ZLIB_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/zlib-$(ZLIB_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/zlib-$(ZLIB_VER); \
		CC=$(TARGET)-gcc mandir=$(BUILD_TMP)/.remove ./configure --prefix= --shared; \
		$(MAKE); \
		ln -sf /bin/true ldconfig; \
		rm -f $(TARGETPREFIX)/lib/libz.so*; \
		PATH=$(BUILD_TMP)/zlib-$(ZLIB_VER):$(PATH) make install prefix=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/zlib.pc
	$(REMOVE)/zlib-$(ZLIB_VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libz.so.* $(PKGPREFIX)/lib
	PKG_VER=$(ZLIB_VER) $(OPKG_SH) $(CONTROL_DIR)/libz
	$(REMOVE)/.remove $(PKGPREFIX)
	touch $@

$(D)/libmad: $(ARCHIVE)/libmad-$(MAD_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libmad-$(MAD_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libmad-$(MAD_VER); \
		patch -p1 < $(PATCHES)/libmad.diff; \
		patch -p1 < $(PATCHES)/libmad-$(MAD_VER)-arm-buildfix.diff; \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi; \
		$(CONFIGURE) --prefix= --enable-shared=yes --enable-speed --enable-fpm=arm --enable-sso; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX); \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" mad.pc > $(PKG_CONFIG_PATH)/libmad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-$(MAD_VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libmad.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libmad
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libid3tag: $(D)/zlib $(ARCHIVE)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER).tar.gz
	set -e; cd $(BUILD_TMP)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER); \
		patch -p1 < $(PATCHES)/libid3tag.diff; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared=yes; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX); \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" id3tag.pc > $(PKG_CONFIG_PATH)/libid3tag.pc
	$(REWRITE_LIBTOOL)/libid3tag.la
	$(REMOVE)/libid3tag-$(ID3TAG_VER)$(ID3TAG_SUBVER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libid3tag.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libid3tag
	rm -rf $(PKGPREFIX)
	touch $@

# obsoleted by giflib, but might still be needed by some 3rd party binaries
# to make sure it is not used to build stuff, it is not installed in TARGETPREFIX
$(D)/libungif: $(ARCHIVE)/libungif-$(UNGIF_VER).tar.bz2
	rm -rf $(PKGPREFIX)
	$(UNTAR)/libungif-$(UNGIF_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libungif-$(UNGIF_VER); \
		rm -f config.guess; \
		rm -f config.sub; \
		./autogen.sh; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --without-x --bindir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/.remove $(PKGPREFIX)/include $(PKGPREFIX)/lib/libungif.?? $(PKGPREFIX)/lib/libungif.a
	$(OPKG_SH) $(CONTROL_DIR)/libungif
	$(REMOVE)/libungif-$(UNGIF_VER) $(PKGPREFIX)
	touch $@

$(D)/giflib: $(D)/giflib-$(GIFLIB_VER)
	touch $@
$(D)/giflib-$(GIFLIB_VER): $(ARCHIVE)/giflib-$(GIFLIB_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/giflib-$(GIFLIB_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/giflib-$(GIFLIB_VER); \
		export ac_cv_prog_have_xmlto=no; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --bindir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX); \
	$(REWRITE_LIBTOOL)/libgif.la
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/giflib-$(GIFLIB_VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libgif.so.* $(PKGPREFIX)/lib
	PKG_VER=$(GIFLIB_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/giflib
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libcurl: $(D)/libcurl-$(CURL_VER)
	touch $@
$(D)/libcurl-$(CURL_VER): $(ARCHIVE)/curl-$(CURL_VER).tar.bz2 $(D)/zlib | $(TARGETPREFIX)
	$(UNTAR)/curl-$(CURL_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/curl-$(CURL_VER); \
		$(CONFIGURE) --prefix=${PREFIX} --build=$(BUILD) --host=$(TARGET) \
			--disable-manual \
			--disable-file \
			--disable-rtsp \
			--disable-dict \
			--disable-imap \
			--disable-pop3 \
			--disable-smtp \
			--enable-shared \
			--with-random \
			--without-ssl \
			--mandir=/.remove; \
		$(MAKE) all; \
		mkdir -p $(HOSTPREFIX)/bin; \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < curl-config > $(HOSTPREFIX)/bin/curl-config; \
		chmod 755 $(HOSTPREFIX)/bin/curl-config; \
		make install DESTDIR=$(PKGPREFIX)
	rm $(PKGPREFIX)/bin/curl-config
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REMOVE)/pkg-lib; mkdir $(BUILD_TMP)/pkg-lib
	cd $(PKGPREFIX) && rm -r include lib/pkgconfig lib/*.so lib/*a .remove/ && mv lib $(BUILD_TMP)/pkg-lib
	PKG_VER=$(CURL_VER) $(OPKG_SH) $(CONTROL_DIR)/curl/curl
	rm -rf $(PKGPREFIX)/*
	mv $(BUILD_TMP)/pkg-lib/* $(PKGPREFIX)/
	PKG_VER=$(CURL_VER) $(OPKG_SH) $(CONTROL_DIR)/curl/libcurl
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/curl-$(CURL_VER) $(PKGPREFIX) $(BUILD_TMP)/pkg-lib
	touch $@

# no Package, since it's only linked statically for now also only install static lib
$(D)/libFLAC: $(ARCHIVE)/flac-$(FLAC_VER).tar.xz | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/flac-$(FLAC_VER)
	$(UNTAR)/flac-$(FLAC_VER).tar.xz
	set -e; cd $(BUILD_TMP)/flac-$(FLAC_VER); \
		$(PATCH)/flac-1.3.0-noencoder.diff; \
		./autogen.sh; \
		$(CONFIGURE) \
			--prefix= \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--disable-ogg \
			--enable-static=yes \
			--enable-shared=no \
			--disable-altivec; \
		$(MAKE) -C src/libFLAC; \
		: make -C src/libFLAC  install DESTDIR=$(TARGETPREFIX); \
		cp -a src/libFLAC/.libs/libFLAC.a $(TARGETPREFIX)/lib/; \
		make -C include/FLAC install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/flac-$(FLAC_VER)
	touch $@

# no Package, since it's only linked statically for now also only install static lib
$(D)/libFLAC-old: $(ARCHIVE)/flac-$(FLAC_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/flac-$(FLAC_VER).tar.gz
	set -e; cd $(BUILD_TMP)/flac-$(FLAC_VER); \
		$(PATCH)/flac-1.2.1-noencoder.diff; \
		rm -f config.guess; \
		rm -f config.sub; \
		./autogen.sh; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) \
			--disable-ogg --disable-altivec; \
		$(MAKE) -C src/libFLAC; \
		: make -C src/libFLAC  install DESTDIR=$(TARGETPREFIX); \
		cp -a src/libFLAC/.libs/libFLAC.a $(TARGETPREFIX)/lib/; \
		make -C include/FLAC install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/flac-$(FLAC_VER)
	touch $@

$(D)/libpng: $(D)/libpng-$(PNG_VER)
	touch $@
$(D)/libpng-$(PNG_VER): $(ARCHIVE)/libpng-$(PNG_VER).tar.xz $(D)/zlib | $(TARGETPREFIX)
	$(UNTAR)/libpng-$(PNG_VER).tar.xz
	set -e; cd $(BUILD_TMP)/libpng-$(PNG_VER); \
		$(CONFIGURE) --prefix=$(TARGETPREFIX) --build=$(BUILD) --host=$(TARGET) --bindir=$(HOSTPREFIX)/bin --mandir=$(BUILD_TMP)/tmpman; \
		ECHO=echo $(MAKE) all; \
		rm -f $(TARGETPREFIX)/lib/libpng.so* $(TARGETPREFIX)/lib/libpng$(PNG_VER_X).so*; \
		make install
	$(REMOVE)/libpng-$(PNG_VER)
	rm -fr $(BUILD_TMP)/tmpman $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libpng$(PNG_VER_X).so.* $(PKGPREFIX)/lib
	PKG_VER=$(PNG_VER) $(OPKG_SH) $(CONTROL_DIR)/libpng$(PNG_VER_X)
	rm -rf $(PKGPREFIX)
	touch $@


FT_RENDER = subpix_render
#FT_RENDER = subpix_hint
#FT_RENDER = render_old

ifeq ($(FT_RENDER), subpix_render)
FT_RENDER_PATCH = freetype_2.5_subpix_render.diff
endif
ifeq ($(FT_RENDER), subpix_hint)
FT_RENDER_PATCH = freetype_2.5_subpix_hint.diff
endif
ifeq ($(FT_RENDER), render_old)
FT_RENDER_PATCH = freetype_2.5_render_old.diff
endif

$(D)/freetype: $(D)/freetype-$(FREETYPE_VER)
	touch $@
$(D)/freetype-$(FREETYPE_VER): $(D)/libpng $(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/freetype-$(FREETYPE_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/freetype-$(FREETYPE_VER); \
		if ! echo $(FREETYPE_VER) | grep "2.3"; then \
			$(PATCH)/$(FT_RENDER_PATCH); \
		fi; \
		sed -i '/#define FT_CONFIG_OPTION_OLD_INTERNALS/d' include/freetype/config/ftoption.h; \
		sed -i '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\)/d' modules.cfg; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET); \
		$(MAKE) all; \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < builds/unix/freetype-config > $(HOSTPREFIX)/bin/freetype-config; \
		chmod 755 $(HOSTPREFIX)/bin/freetype-config; \
		rm -f $(TARGETPREFIX)/lib/libfreetype.so*; \
		make install libdir=$(TARGETPREFIX)/lib includedir=$(TARGETPREFIX)/include bindir=$(TARGETPREFIX)/bin prefix=$(TARGETPREFIX)
		if [ -d $(TARGETPREFIX)/include/freetype2/freetype ] ; then \
			ln -sf ./freetype2/freetype $(TARGETPREFIX)/include/freetype; \
		fi; \
	rm $(TARGETPREFIX)/bin/freetype-config
	$(REWRITE_LIBTOOL)/libfreetype.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/freetype2.pc
	$(REMOVE)/freetype-$(FREETYPE_VER) $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libfreetype.so.* $(PKGPREFIX)/lib
	PKG_VER=$(FREETYPE_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/libfreetype
	rm -rf $(PKGPREFIX)
	touch $@

## build both libjpeg.so.62 and libjpeg.so.8
## use only libjpeg.so.62 for our own build, but keep libjpeg8 for
## compatibility to third party binaries
$(D)/libjpeg: $(D)/libjpeg-turbo-$(JPEG_TURBO_VER)
	touch $@
$(D)/libjpeg-turbo-$(JPEG_TURBO_VER): $(ARCHIVE)/libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libjpeg-turbo-$(JPEG_TURBO_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libjpeg-turbo-$(JPEG_TURBO_VER); \
		export CC=$(TARGET)-gcc; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared \
			--mandir=/.remove --bindir=/.remove \
			--with-jpeg8 --disable-static --includedir=/.remove ; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX); \
		make clean; \
		$(CONFIGURE) --prefix= --build=$(BUILD) --host=$(TARGET) --enable-shared \
			--mandir=/.remove --bindir=/.remove ; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libjpeg.la
	rm -f $(TARGETPREFIX)/lib/libturbojpeg* $(TARGETPREFIX)/include/turbojpeg.h
	$(REMOVE)/libjpeg-turbo-$(JPEG_TURBO_VER) $(TARGETPREFIX)/.remove $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libjpeg.so.* $(PKGPREFIX)/lib
	PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		PKG_VER=$(JPEG_TURBO_VER) $(OPKG_SH) $(CONTROL_DIR)/libjpeg
	rm -rf $(PKGPREFIX)
	touch $@

# openssl seems to have problem with parallel builds, so use "make" instead of "$(MAKE)"
$(D)/openssl: $(ARCHIVE)/openssl-$(OPENSSL_VER)$(OPENSSL_SUBVER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/openssl-$(OPENSSL_VER)$(OPENSSL_SUBVER).tar.gz
	set -e; cd $(BUILD_TMP)/openssl-$(OPENSSL_VER)$(OPENSSL_SUBVER); \
#		patch -p1 < $(PATCHES)/openssl_bss_dgram.c.diff; \
		sed -i -e "/AF_INET6/,/break/d" crypto/bio/bss_dgram.c; \
		sed -i 's/#define DATE.*/#define DATE \\"($(PLATFORM))\\""; \\/' crypto/Makefile; \
		CC=$(TARGET)-gcc \
		./Configure shared no-hw no-engine linux-generic32 --prefix=/ --openssldir=/.remove; \
		make depend; \
		make all; \
		make install_sw INSTALL_PREFIX=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcrypto.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libssl.pc
	rm -r $(TARGETPREFIX)/.remove $(TARGETPREFIX)/bin/openssl $(TARGETPREFIX)/bin/c_rehash
	$(REMOVE)/openssl-$(OPENSSL_VER)$(OPENSSL_SUBVER)
	chmod 0755 $(TARGETPREFIX)/lib/libcrypto.so.* $(TARGETPREFIX)/lib/libssl.so.*
	rm -rf $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/lib{crypto,ssl}.so.$(OPENSSL_VER) $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/openssl-libs
	rm -rf $(PKGPREFIX)
	touch $@

ifeq ($(BOXARCH), arm)
FFMPEG_CONFIGURE = \
--disable-parsers \
--enable-parser=aac \
--enable-parser=aac_latm \
--enable-parser=ac3 \
--enable-parser=dca \
--enable-parser=mpeg4video \
--enable-parser=mpegvideo \
--enable-parser=mpegaudio \
--enable-parser=h264 \
--enable-parser=vc1 \
--enable-parser=dvdsub \
--enable-parser=dvbsub \
--disable-decoders \
--enable-decoder=dca \
--enable-decoder=dvdsub \
--enable-decoder=dvbsub \
--enable-decoder=text \
--enable-decoder=srt \
--enable-decoder=subrip \
--enable-decoder=subviewer \
--enable-decoder=subviewer1 \
--enable-decoder=xsub \
--enable-decoder=pgssub \
--disable-demuxers \
--enable-demuxer=aac \
--enable-demuxer=ac3 \
--enable-demuxer=avi \
--enable-demuxer=mov \
--enable-demuxer=vc1 \
--enable-demuxer=mpegts \
--enable-demuxer=mpegtsraw \
--enable-demuxer=mpegps \
--enable-demuxer=mpegvideo \
--enable-demuxer=wav \
--enable-demuxer=pcm_s16be \
--enable-demuxer=mp3 \
--enable-demuxer=pcm_s16le \
--enable-demuxer=matroska \
--enable-demuxer=flv \
--enable-demuxer=rm \
--enable-demuxer=rtsp \
--disable-encoders \
--disable-muxers \
--disable-ffplay \
--disable-ffmpeg \
--disable-ffserver \
--disable-filters \
--disable-protocols \
--enable-protocol=file \
--enable-protocol=http \
--enable-protocol=rtp \
--enable-protocol=rtmp \
--enable-protocol=rtmpe \
--enable-protocol=rtmps \
--enable-protocol=rtmpte \
--enable-bsfs \
--enable-swresample \
--disable-postproc \
--disable-swscale \
--enable-network \
--target-os=linux \
--arch=arm \
--disable-neon \
--disable-devices \
--disable-mmx \
--disable-altivec \
--disable-zlib \
--enable-bzlib \
--disable-static \
--enable-shared \
--enable-cross-compile \
--enable-gpl
endif # ifeq ($(BOXARCH), arm)

ifeq ($(PLATFORM), apollo)
FFMPEG_CONFIGURE += --cpu=cortex-a9 --extra-cflags="-mfpu=vfpv3-d16 -mfloat-abi=hard"
endif

ifeq ($(PLATFORM), nevis)
FFMPEG_CONFIGURE += --cpu=armv6
endif

$(D)/ffmpeg: $(D)/ffmpeg-$(FFMPEG_VER)
	touch $@
$(D)/ffmpeg-$(FFMPEG_VER): $(ARCHIVE)/ffmpeg-$(FFMPEG_VER).tar.bz2 | $(TARGETPREFIX)
	if ! test -d $(CST_GIT)/cst-public-libraries-ffmpeg; then \
		make $(CST_GIT)/cst-public-libraries-ffmpeg; \
		cd $(CST_GIT)/cst-public-libraries-ffmpeg; \
		git checkout --track -b coolstream origin/coolstream; \
	else \
		cd $(CST_GIT)/cst-public-libraries-ffmpeg; \
		git checkout coolstream; \
		git pull; \
	fi;
	rm -rf $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER)
	cp -aL $(CST_GIT)/cst-public-libraries-ffmpeg $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER)
	set -e; cd $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER); \
		sed -i '/\(__DATE__\|__TIME__\)/d' ffprobe.c; # remove build time \
		sed -i -e 's/__DATE__/""/' -e 's/__TIME__/""/' cmdutils.c; \
		./configure \
			$(FFMPEG_CONFIGURE) \
			--logfile=Config.log \
			--cross-prefix=$(TARGET)- \
			--enable-debug --enable-stripping \
			--mandir=/.remove \
			--prefix=/; \
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	rm -rf $(PKGPREFIX)/share
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	cp $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER)/version.h $(TARGETPREFIX)/lib/ffmpeg-version.h
	cp $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER)/version.h $(PKGPREFIX)/lib/ffmpeg-version.h
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavfilter.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswresample.pc
	test -e $(PKG_CONFIG_PATH)/libswscale.pc && $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswscale.pc || true
	rm -rf $(PKGPREFIX)/include $(PKGPREFIX)/lib/pkgconfig $(PKGPREFIX)/lib/*.so $(PKGPREFIX)/.remove
	PKG_VER=$(FFMPEG_VER) PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		$(OPKG_SH) $(CONTROL_DIR)/ffmpeg
	$(REMOVE)/ffmpeg-$(FFMPEG_VER) $(PKGPREFIX)
	touch $@

ncurses-prereq:
	@if $(MAKE) find-tic find-infocmp ; then \
		true; \
	else \
		echo "**********************************************************"; \
		echo "* tic or infocmp missing, but needed to build libncurses *"; \
		echo "* install the ncurses development package on your system *"; \
		echo "**********************************************************"; \
		false; \
	fi

$(D)/libncurses: $(ARCHIVE)/ncurses-$(NCURSES_VER).tar.gz | ncurses-prereq $(TARGETPREFIX)
	$(UNTAR)/ncurses-$(NCURSES_VER).tar.gz
	set -e; cd $(BUILD_TMP)/ncurses-$(NCURSES_VER); \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) \
			--prefix= --with-terminfo-dirs=/usr/share/terminfo \
			--disable-big-core --without-debug --without-progs --without-ada --with-shared \
			--without-profile --disable-rpath --without-cxx-binding \
			--with-fallbacks='linux vt100 xterm'; \
		$(MAKE) libs HOSTCC=gcc HOSTLDFLAGS="$(TARGET_LDFLAGS)" \
			HOSTCCFLAGS="$(TARGET_CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include"; \
		make install.libs DESTDIR=$(TARGETPREFIX); \
		install -D -m 0755 misc/ncurses-config $(HOSTPREFIX)/bin/ncurses5-config
	$(REMOVE)/ncurses-$(NCURSES_VER) $(PKGPREFIX)
	$(REWRITE_PKGCONF) $(HOSTPREFIX)/bin/ncurses5-config
	mkdir -p $(PKGPREFIX)/lib
	# deliberately ignore libforms and libpanel - not yet needed
	cp -a $(TARGETPREFIX)/lib/libncurses.so.* $(PKGPREFIX)/lib
	$(OPKG_SH) $(CONTROL_DIR)/libncurses
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libdvbsi++: $(ARCHIVE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2 \
$(PATCHES)/libdvbsi++-src-time_date_section.cpp-fix-sectionLength-check.patch \
$(PATCHES)/libdvbsi++-fix-unaligned-access-on-SuperH.patch
	$(REMOVE)/libdvbsi++-$(LIBDVBSI_VER)
	$(UNTAR)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libdvbsi++-$(LIBDVBSI_VER); \
			$(PATCH)/libdvbsi++-src-time_date_section.cpp-fix-sectionLength-check.patch; \
			$(PATCH)/libdvbsi++-fix-unaligned-access-on-SuperH.patch; \
			$(CONFIGURE) \
				--prefix=$(TARGETPREFIX) \
				--build=$(BUILD) \
				--host=$(TARGET); \
			$(MAKE); \
			$(MAKE) install
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(BUILD_TMP)/libdvbsi++-$(LIBDVBSI_VER)/src/.libs/libdvbsi++.so.* $(PKGPREFIX)/lib
	PKG_DEP=" " PKG_VER=$(LIBDVBSI_VER) PKG_VER=$(LIBDVBSI_VER) \
	PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
	$(OPKG_SH) $(CONTROL_DIR)/libdvbsi++
	$(REMOVE)/libdvbsi++-$(LIBDVBSI_VER) $(PKGPREFIX)
	touch $@

# the strange find | sed hack is needed for old cmake versions which
# don't obey CMAKE_INSTALL_PREFIX (e.g. debian lenny 5.0.7's cmake 2.6)
$(D)/openthreads: | $(TARGETPREFIX) find-lzma
	lzma -dc $(PATCHES)/sources/OpenThreads-svn-13083.tar.lzma | tar -C $(BUILD_TMP) -x
	set -e; cd $(BUILD_TMP)/OpenThreads-svn-13083; \
		rm CMakeFiles/* -rf CMakeCache.txt cmake_install.cmake; \
		cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX="" \
			-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
			-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE=1; \
		find . -name cmake_install.cmake -print0 | xargs -0 \
			sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@'; \
		$(MAKE); \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	$(REMOVE)/OpenThreads-svn-13083 $(PKGPREFIX)
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libOpenThreads.so.* $(PKGPREFIX)/lib
	PKG_VER=13083 $(OPKG_SH) $(CONTROL_DIR)/libOpenThreads
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/libogg: $(ARCHIVE)/libogg-$(OGG_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libogg-$(OGG_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libogg-$(OGG_VER); \
		$(CONFIGURE) --prefix= --enable-shared; \
		$(MAKE); \
		make install DESTDIR=$(PKGPREFIX)
	rm -r $(PKGPREFIX)/share/doc
	cp -frd $(PKGPREFIX)/share/* $(TARGETPREFIX)/share
	rm -fr $(PKGPREFIX)/share
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	set -e; cd $(PKGPREFIX); rm -rf share include lib/pkgconfig; rm lib/*a lib/*.so
	PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		PKG_VER=$(OGG_VER) $(OPKG_SH) $(CONTROL_DIR)/libogg
	$(REMOVE)/libogg-$(OGG_VER) $(PKGPREFIX)
	touch $@

$(D)/libvorbisidec: $(D)/libvorbisidec-$(VORBISIDEC_VER)
	touch $@
$(D)/libvorbisidec-$(VORBISIDEC_VER): $(ARCHIVE)/libvorbisidec_$(VORBISIDEC_VER)$(VORBISIDEC_VER_APPEND).tar.gz $(D)/libogg
	rm -fr $(BUILD_TMP)/libvorbisidec-$(VORBISIDEC_VER); \
	$(UNTAR)/libvorbisidec_$(VORBISIDEC_VER)$(VORBISIDEC_VER_APPEND).tar.gz
	set -e; cd $(BUILD_TMP)/libvorbisidec-$(VORBISIDEC_VER); \
		patch -p1 < $(PATCHES)/tremor.diff; \
		ACLOCAL_FLAGS="-I . -I $(TARGETPREFIX)/share/aclocal" \
		$(BUILDENV) ./autogen.sh $(CONFIGURE_OPTS) --prefix= ; \
		make all; \
		perl -pi -e "s,^prefix=.*$$,prefix=$(TARGETPREFIX)," vorbisidec.pc; \
		make install DESTDIR=$(TARGETPREFIX); \
		make install DESTDIR=$(PKGPREFIX); \
		install -m644 vorbisidec.pc $(TARGETPREFIX)/lib/pkgconfig
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	rm -r $(PKGPREFIX)/lib/pkgconfig $(PKGPREFIX)/include
	rm $(PKGPREFIX)/lib/*a
	PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
		PKG_VER=$(VORBISIDEC_SVN) $(OPKG_SH) $(CONTROL_DIR)/libvorbisidec
	ln -sf ../ogg/ogg.h $(TARGETPREFIX)/include/tremor/ogg.h
	$(REMOVE)/libvorbisidec-$(VORBISIDEC_VER) $(PKGPREFIX)
	touch $@

# timezone definitions. Package only those referenced by timezone.xml
# zic is usually in a package called "timezone" or similar.
$(D)/timezone: find-zic $(ARCHIVE)/tzdata$(TZ_VER).tar.gz
	$(REMOVE)/timezone $(PKGPREFIX)
	mkdir $(BUILD_TMP)/timezone $(BUILD_TMP)/timezone/zoneinfo
	tar -C $(BUILD_TMP)/timezone -xf $(ARCHIVE)/tzdata$(TZ_VER).tar.gz
	set -e; cd $(BUILD_TMP)/timezone; \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		zic -d zoneinfo.tmp \
			africa antarctica asia australasia \
			europe northamerica southamerica pacificnew \
			etcetera backward; \
		sed -n '/zone=/{s/.*zone="\(.*\)".*$$/\1/; p}' $(PATCHES)/timezone.xml | sort -u | \
		while read x; do \
			find zoneinfo.tmp -type f -name $$x | sort | \
			while read y; do \
				cp -a $$y zoneinfo/$$x; \
			done; \
			test -e zoneinfo/$$x || echo "WARNING: timezone $$x not found."; \
		done; \
		install -d -m 0755 $(TARGETPREFIX)/usr/share $(TARGETPREFIX)/etc; \
		cp -a zoneinfo $(TARGETPREFIX)/usr/share/; \
		install -d -m 0755 $(PKGPREFIX)/usr/share $(PKGPREFIX)/etc; \
		mv zoneinfo $(PKGPREFIX)/usr/share/
	install -m 0644 $(PATCHES)/timezone.xml $(TARGETPREFIX)/etc/
	install -m 0644 $(PATCHES)/timezone.xml $(PKGPREFIX)/etc/
	PKG_VER=$(TZ_VER) $(OPKG_SH) $(CONTROL_DIR)/timezone
	$(REMOVE)/timezone $(PKGPREFIX)
	touch $@

$(D)/tzcode: $(ARCHIVE)/tzcode$(TZ_VER).tar.gz
	mkdir -p $(BUILD_TMP)/tzcode
	tar -C $(BUILD_TMP)/tzcode -xf $(ARCHIVE)/tzcode$(TZ_VER).tar.gz
	set -e; cd $(BUILD_TMP)/tzcode; \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc; \
		$(MAKE) install TOPDIR=$(TARGETPREFIX)/TZ; \
	


# no package, since the library is only built statically
$(D)/lua: libncurses $(ARCHIVE)/lua-$(LUA_VER).tar.gz \
	$(ARCHIVE)/luaposix-$(LUAPOSIX_VER).tar.bz2 $(PATCHES)/lua-5.2.1-luaposix.patch
	$(REMOVE)/lua-$(LUA_VER)
	$(UNTAR)/lua-$(LUA_VER).tar.gz
	set -e; cd $(BUILD_TMP)/lua-$(LUA_VER); \
		$(PATCH)/lua-5.2.1-luaposix.patch; \
		tar xf $(ARCHIVE)/luaposix-$(LUAPOSIX_VER).tar.bz2; \
		cd luaposix-$(LUAPOSIX_VER); cp lposix.c lua52compat.h ../src/; cd ..; \
		sed -i 's/<config.h>/"config.h"/' src/lposix.c; \
		sed -i '/^#define/d' src/lua52compat.h; \
		sed -i 's@^#define LUA_ROOT.*@#define LUA_ROOT "/"@' src/luaconf.h; \
		sed -i '/^#define LUA_USE_READLINE/d' src/luaconf.h; \
		sed -i 's/ -lreadline//' src/Makefile; \
		sed -i 's|man/man1|.remove|' Makefile; \
		$(MAKE) linux CC=$(TARGET)-gcc LDFLAGS="-L$(TARGETPREFIX)/lib" ; \
		$(MAKE) install INSTALL_TOP=$(TARGETPREFIX)
	rm -rf $(TARGETPREFIX)/.remove
	$(REMOVE)/lua-$(LUA_VER)
	touch $@

$(D)/libiconv: $(ARCHIVE)/libiconv-$(ICONV_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libiconv-$(ICONV_VER).tar.gz
	pushd $(BUILD_TMP)/libiconv-$(ICONV_VER) && \
		$(PATCH)/libiconv-1-fixes.patch; \
		$(CONFIGURE) --build=$(BUILD) --host=$(TARGET) --target=$(TARGET) --prefix= --datarootdir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libiconv.la
	rm -fr $(TARGETPREFIX)/.remove
	$(REMOVE)/libiconv-$(ICONV_VER)
	touch $@

$(D)/fuse: $(ARCHIVE)/fuse-$(FUSE_VER).tar.gz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/fuse-$(FUSE_VER).tar.gz
	set -e; cd $(BUILD_TMP)/fuse-$(FUSE_VER); \
		$(CONFIGURE) --prefix= --mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX) ;\
		make install DESTDIR=$(PKGPREFIX)
	$(REWRITE_LIBTOOL)/libfuse.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fuse.pc
	set -e; cd $(PKGPREFIX); \
		rm -rf dev etc lib/pkgconfig include .remove; \
		rm lib/*.so lib/*.la lib/*.a
ifeq ($(PLATFORM), apollo)
	PKG_DEP=" " PKG_VER=$(FUSE_VER) $(OPKG_SH) $(CONTROL_DIR)/fuse
else
	install -m 755 -D $(SCRIPTS)/load-fuse.init \
		$(PKGPREFIX)/etc/init.d/load-fuse
	ln -s load-fuse $(PKGPREFIX)/etc/init.d/S56load-fuse
	PKG_DEP="fuse.ko" PKG_VER=$(FUSE_VER) $(OPKG_SH) $(CONTROL_DIR)/fuse
endif
	$(REMOVE)/fuse-$(FUSE_VER) $(PKGPREFIX)
	touch $@

$(D)/readline: $(ARCHIVE)/readline-$(READLINE_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/readline-$(READLINE_VER).tar.gz
	set -e; cd $(BUILD_TMP)/readline-$(READLINE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--infodir=/.remove \
			--mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/readline-$(READLINE_VER) $(TARGETPREFIX)/.remove
	touch $@

$(D)/parted: $(ARCHIVE)/parted-$(PARTED_VER).tar.xz $(D)/readline | $(TARGETPREFIX)
	$(UNTAR)/parted-$(PARTED_VER).tar.xz
	set -e; cd $(BUILD_TMP)/parted-$(PARTED_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-device-mapper \
			--infodir=/.remove \
			--mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libparted.la
	$(REWRITE_LIBTOOL)/libparted-fs-resize.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libparted.pc
	rm -fr $(BUILD_TMP)/parted-$(PARTED_VER) $(TARGETPREFIX)/.remove
	touch $@

$(D)/libnl: $(ARCHIVE)/libnl-$(LIBNL_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libnl-$(LIBNL_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libnl-$(LIBNL_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGETPREFIX)/Libnl3


#CFLAGS="-I/usr/include/libnl3"
# make BINDIR=/sbin LIBDIR=/lib

#$(D)/libnl
$(D)/wpa_supplicant: $(ARCHIVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz $(D)/openssl | $(TARGETPREFIX)
	$(REMOVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER)
	$(UNTAR)/wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPPLICANT_VER)/wpa_supplicant; \
	cp -f defconfig .config && \
	sed -i 's/#CONFIG_DRIVER_IPW=y/CONFIG_DRIVER_IPW=y/' .config && \
	sed -i 's/#CONFIG_TLS=openssl/CONFIG_TLS=openssl/' .config && \
		export CC=$(CROSS_DIR)/bin/$(TARGET)-gcc && \
		export CFLAGS=-I$(TARGETPREFIX)/include && \
		export CPPFLAGS=-I$(TARGETPREFIX)/include && \
		export LIBS="-L$(TARGETPREFIX)/lib -Wl,-rpath-link,$(TARGETPREFIX)/lib" && \
		export LDFLAGS="-L$(TARGETPREFIX)/lib" && \
		export DESTDIR=$(TARGETPREFIX) && \
		export PATH=/bin:$(PATH) && \
		$(MAKE) && \
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPPLICANT_VER)/wpa_supplicant/wpa_cli $(TARGETPREFIX)/sbin
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPPLICANT_VER)/wpa_supplicant/wpa_passphrase $(TARGETPREFIX)/sbin
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPPLICANT_VER)/wpa_supplicant/wpa_supplicant $(TARGETPREFIX)/sbin
	$(CROSS_DIR)/bin/$(TARGET)-strip $(TARGETPREFIX)/sbin/wpa_cli
	$(CROSS_DIR)/bin/$(TARGET)-strip $(TARGETPREFIX)/sbin/wpa_passphrase
	$(CROSS_DIR)/bin/$(TARGET)-strip $(TARGETPREFIX)/sbin/wpa_supplicant
	$(REMOVE)/wpa_supplicant-$(WPA_SUPPLICANT_VER)
	touch $@

#libsigc++: typesafe Callback Framework for C++
$(D)/libsigc++: $(ARCHIVE)/libsigc++-$(LIBSIGCPP_VER).tar.xz | $(TARGETPREFIX)
	rm -rf $(PKGPREFIX)
	$(UNTAR)/libsigc++-$(LIBSIGCPP_VER).tar.xz
	set -e; cd $(BUILD_TMP)/libsigc++-$(LIBSIGCPP_VER); \
		$(CONFIGURE) -prefix= \
				--disable-documentation \
				--enable-silent-rules; \
		$(MAKE); \
		make install DESTDIR=$(TARGETPREFIX); \
	mkdir -p $(PKGPREFIX)/lib
	cp -a $(TARGETPREFIX)/lib/libsigc-2.0.so* $(PKGPREFIX)/lib
	ln -sf ./sigc++-2.0/sigc++ $(TARGETPREFIX)/include/sigc++
	cp $(BUILD_TMP)/libsigc++-$(LIBSIGCPP_VER)/sigc++config.h $(TARGETPREFIX)/include
	$(REWRITE_LIBTOOL)/libsigc-2.0.la
	PKG_VER=$(LIBSIGCPP_VER) \
		PKG_DEP=`opkg-find-requires.sh $(PKGPREFIX)` \
		PKG_PROV=`opkg-find-provides.sh $(PKGPREFIX)` \
			$(OPKG_SH) $(CONTROL_DIR)/libsigc++
	$(REMOVE)/libsigc++-$(LIBSIGCPP_VER)
	rm -rf $(PKGPREFIX)
	touch $@

$(D)/SDL: $(ARCHIVE)/SDL-$(LIBSDL_VER).tar.gz $(D)/libiconv | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/SDL-$(LIBSDL_VER)
	$(UNTAR)/SDL-$(LIBSDL_VER).tar.gz
	set -e; cd $(BUILD_TMP)/SDL-$(LIBSDL_VER); \
		$(CONFIGURE) \
			--disable-assembly \
			--disable-video \
			--disable-joystick \
			--disable-cdrom \
			--disable-arts \
			--disable-arts-shared \
			--disable-nas \
			--disable-nas-shared \
			--disable-diskaudio \
			--disable-dummyaudio \
			--disable-mintaudio \
			--disable-video-x11 \
			--disable-x11-shared \
			--disable-dga \
			--disable-video-dga \
			--disable-video-x11-dgamouse \
			--disable-video-x11-vm \
			--disable-video-x11-xv \
			--disable-video-x11-xinerama \
			--disable-video-x11-xme \
			--disable-video-x11-xrandr \
			--disable-video-photon \
			--disable-video-cocoa \
			--disable-video-fbcon \
			--disable-video-directfb \
			--disable-video-ps2gs \
			--disable-video-ps3 \
			--disable-video-svga \
			--disable-video-vgl \
			--disable-video-wscons \
			--disable-video-xbios \
			--disable-video-gem \
			--disable-video-dummy \
			--disable-video-opengl \
			--disable-osmesa-shared \
			--disable-input-events \
			--disable-input-tslib \
			--disable-static \
			\
			--prefix= \
			--mandir=/.remove; \
		$(MAKE) all; \
		mkdir -p $(HOSTPREFIX)/bin; \
		sed -e "s,^prefix=,prefix=$(TARGETPREFIX)," < sdl-config > $(HOSTPREFIX)/bin/sdl-config; \
		chmod 755 $(HOSTPREFIX)/bin/sdl-config; \
		make install DESTDIR=$(PKGPREFIX)
	rm -fr $(PKGPREFIX)/.remove $(PKGPREFIX)/share
	rm -f $(PKGPREFIX)/bin/sdl-config
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sdl.pc
	$(REWRITE_LIBTOOL)/libSDL.la
	rm -fr $(PKGPREFIX)/include $(PKGPREFIX)/lib/pkgconfig
	rm -f $(PKGPREFIX)/lib/*.a $(PKGPREFIX)/lib/*.la
	## pkg bauen...
	rm -fr $(BUILD_TMP)/SDL-$(LIBSDL_VER) $(PKGPREFIX)
	touch $@

$(D)/SDL-ttf: $(ARCHIVE)/SDL_ttf-$(SDL_TTF_VER).tar.gz $(D)/SDL | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/SDL_ttf-$(SDL_TTF_VER) $(PKGPREFIX)
	$(UNTAR)/SDL_ttf-$(SDL_TTF_VER).tar.gz
	set -e; cd $(BUILD_TMP)/SDL_ttf-$(SDL_TTF_VER); \
		$(CONFIGURE) \
			--disable-sdltest \
			--disable-static \
			--prefix= \
			--mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/SDL_ttf.pc
	$(REWRITE_LIBTOOL)/libSDL_ttf.la
	rm -fr $(PKGPREFIX)/include $(PKGPREFIX)/lib/pkgconfig
	rm -f $(PKGPREFIX)/lib/*.la
	## pkg bauen...
	rm -fr $(BUILD_TMP)/SDL_ttf-$(SDL_TTF_VER) $(PKGPREFIX)
	touch $@

$(D)/SDL-mixer: $(ARCHIVE)/SDL_mixer-$(SDL_MIXER_VER).tar.gz $(D)/SDL | $(TARGETPREFIX)
	rm -fr $(BUILD_TMP)/SDL_mixer-$(SDL_MIXER_VER) $(PKGPREFIX)
	$(UNTAR)/SDL_mixer-$(SDL_MIXER_VER).tar.gz
	set -e; cd $(BUILD_TMP)/SDL_mixer-$(SDL_MIXER_VER); \
		$(CONFIGURE) \
			--enable-music-ogg-tremor \
			--disable-music-mod \
			--disable-music-midi \
			--disable-music-timidity-midi \
			--disable-music-native-midi \
			--disable-music-fluidsynth-midi \
			--disable-music-mp3-shared \
			--disable-smpegtest \
			--disable-sdltest \
			--disable-static \
			--prefix= \
			--mandir=/.remove; \
		$(MAKE) all; \
		make install DESTDIR=$(PKGPREFIX)
	cp -a $(PKGPREFIX)/* $(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/SDL_mixer.pc
	$(REWRITE_LIBTOOL)/libSDL_mixer.la
	rm -fr $(PKGPREFIX)/include $(PKGPREFIX)/lib/pkgconfig
	rm -f $(PKGPREFIX)/lib/*.la
	## pkg bauen...
	rm -fr $(BUILD_TMP)/SDL_mixer-$(SDL_MIXER_VER) $(PKGPREFIX)
	touch $@
