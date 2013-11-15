# $(SOURCE) = Path to your tuxwetter sources
# e.g. SOURCE = $(BASE_DIR)/archive-sources

# Some useful variables
LIBPLUG = $(TARGETPREFIX)/lib/tuxbox/plugins
VARCONF = $(TARGETPREFIX)/var/tuxbox/config
BIN 	= $(TARGETPREFIX)/bin

twclean:
	rm -f $(LIBPLUG)/tuxwetter*
	rm -f $(BIN)/tuxwetter
	rm -rf $(VARCONF)/tuxwetter

TW_SOURCE = gifdecomp.c tuxwetter.c gfx.c io.c text.c parser.c php.c http.c jpeg.c fb_display.c resize.c pngw.c gif.c
TW_FLAGS = -Wall $(TARGET_CFLAGS) -L$(TARGETPREFIX)/lib -I$(TARGETPREFIX)/include/freetype2 -lssl -lcrypto -lfreetype -lz -DWWEATHER -lcurl -ljpeg -lpng -lgif

tuxwetter: $(LIBPLUG)/tuxwetter.so $(BIN)/tuxwetter $(D)/giflib
$(BIN)/tuxwetter:
	mkdir -p $(BIN) && \
	mkdir -p $(LIBPLUG)/ && \
	mkdir -p $(VARCONF)/tuxwetter/ && \
	pushd $(SOURCE_DIR)/tuxwetter && \
	$(TARGET)-gcc $(TW_FLAGS) -o $@ $(TW_SOURCE) && \
	cp -f tuxwetter.cfg $(LIBPLUG)/tuxwetter.cfg && \
	cp -f tuxwetter.conf $(VARCONF)/tuxwetter/ && \
	cp -f tuxwetter.mcfg $(VARCONF)/tuxwetter/ && \
	cp -f startbild.jpg $(VARCONF)/tuxwetter/ && \
	cp -f convert.list $(VARCONF)/tuxwetter/

$(LIBPLUG)/tuxwetter.so:
	mkdir -p $(LIBPLUG) && \
	pushd $(SOURCE_DIR)/tuxwetter && \
	$(TARGET)-gcc $(TARGET_CFLAGS) -L$(TARGETPREFIX)/lib -I$(SOURCE_DIR)/neutrino-hd/src -g -o $@ starter.c
