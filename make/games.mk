
GAMES_GIT_REPO		= git://git.slknet.de/git/neutrino-hd-games.git
GAMES_SRC_DIR		= $(SOURCE_DIR)/neutrino-hd-games
GAMES_INSTALL_DIR	= $(TARGETPREFIX)/var/tuxbox/plugins
GAMES_CONFIGDIR_DIR	= /var/tuxbox/config
GAMES_DATA_DIR		= /var/tuxbox/games

## Nach dem Umstellen des Branch unbedingt
## 'make games-update'
## ausführen!

#WORK_BRANCH = next
WORK_BRANCH = master

ifeq ($(PLATFORM), $(filter $(PLATFORM), apollo kronos))
  _BOXMODEL = BOXMODEL_APOLLO
else ifeq ($(PLATFORM), nevis)
  _BOXMODEL = BOXMODEL_NEVIS
else
  _BOXMODEL = BOXMODEL_UNKNOWN
endif

GAMES_CFLAGS  = $(TARGET_CFLAGS) -I/Data/coolstream/build/bs-kronos/root/usr/include/freetype2 -I/Data/coolstream/build/bs-kronos/root/usr/include/libfx2
GAMES_LDFLAGS = -L/Data/coolstream/build/bs-kronos/root/usr/lib -lfreetype -lz
GAMES_GCC     = $(TARGET)-gcc
GAMES_G++     = $(TARGET)-g++
GAMES_STRIP   = $(TARGET)-strip

$(GAMES_SRC_DIR):
	@mkdir -p $(SOURCE_DIR)
	@pushd $(SOURCE_DIR) && \
		git clone $(GAMES_GIT_REPO)
	@pushd $(GAMES_SRC_DIR) && \
		if [ "$(WORK_BRANCH)" = "next" ]; then \
			git branch | grep next > /dev/null; TMPx=$$?; \
			if [ ! "$$TMPx" = "0" ]; then \
				git checkout master; \
				git checkout --track -b next origin next; \
			fi; \
		fi; \
		git checkout $(WORK_BRANCH); \
		echo "clone neutrino-hd-games done"

games-update: $(GAMES_SRC_DIR)
	@pushd $(GAMES_SRC_DIR) && \
		if [ "$(WORK_BRANCH)" = "next" ]; then \
			git branch | grep next > /dev/null; TMPx=$$?; \
			if [ ! "$$TMPx" = "0" ]; then \
				git checkout master; \
				git pull; \
				git checkout --track -b next origin next; \
			fi; \
		fi; \
		git checkout $(WORK_BRANCH); \
		git pull; \
		echo "update neutrino-hd-games done"

$(D)/libfx2: $(D)/freetype $(GAMES_SRC_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	mkdir -p $(TARGETPREFIX)/include/$(notdir $@) && \
	cp -a $(GAMES_SRC_DIR)/$(notdir $@)/*.h $(TARGETPREFIX)/include/$(notdir $@) && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -shared -fpic -o $(BUILD_TMP)/$(notdir $@)/libfx2.so draw.c math.c rcinput.c
	cp -f $(BUILD_TMP)/$(notdir $@)/libfx2.so $(TARGETPREFIX)/lib/
	$(GAMES_STRIP) $(TARGETPREFIX)/lib/libfx2.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/tetris: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/tetris.so board.c somain.c
	cp -f $(BUILD_TMP)/$(notdir $@)/tetris.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/tetris.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/tetris_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/tetris.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/sol: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/sol.so solboard.c somain.c
	cp -f $(BUILD_TMP)/$(notdir $@)/sol.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/sol.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/sol_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/sol.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/vierg: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/vierg.so board.c somain.c
	cp -f $(BUILD_TMP)/$(notdir $@)/vierg.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/vierg.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/vierg_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/vierg.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/master: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/master.so board.c somain.c
	cp -f $(BUILD_TMP)/$(notdir $@)/master.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/master.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/master_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/master.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/snake: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/snake.so snake.c somain.c
	cp -f $(BUILD_TMP)/$(notdir $@)/snake.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/snake.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/snake_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/snake.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/tank: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/tank.so board.c somain.c
	cp -f $(BUILD_TMP)/$(notdir $@)/tank.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/tank.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/tank_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/tank.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/lemm: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -lpthread -o $(BUILD_TMP)/$(notdir $@)/lemmings.so double.c lemm.c pic.c somain.c sound.c sprite.c
	cp -f $(BUILD_TMP)/$(notdir $@)/lemmings.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/lemmings.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/lemmings_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/lemmings.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/pac: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/pacman.so maze.c somain.c
	cp -f $(BUILD_TMP)/$(notdir $@)/pacman.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/pacman.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/pacman_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/pacman.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@

$(D)/sokoban: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		echo "#define CONFIGDIR \"$(GAMES_CONFIGDIR_DIR)\"" > tmp_defines.h && \
		echo "#define DATADIR \"$(GAMES_DATA_DIR)\"" >> tmp_defines.h && \
		$(GAMES_GCC) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -lpthread -o $(BUILD_TMP)/$(notdir $@)/sokoban.so board.c somain.c
	cp -f $(BUILD_TMP)/$(notdir $@)/sokoban.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/sokoban.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/sokoban_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/sokoban.so
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@


$(D)/solitair: $(D)/libfx2
	mkdir -p $(GAMES_INSTALL_DIR)
	cp -a $(GAMES_SRC_DIR)/$(notdir $@) $(BUILD_TMP)/ && \
	pushd $(BUILD_TMP)/$(notdir $@) && \
		echo "#define GAMESDIR \"$(GAMES_DATA_DIR)\"" > tmp_defines.h && \
		$(GAMES_G++) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/solitair.so backbuffer.cpp Block.cpp Buffer.cpp Card.cpp Foundation.cpp Hand.cpp pnm_file.cpp pnm_res.cpp Slot.cpp somain.cpp Table.cpp Tableau.cpp Wastepile.cpp && \
		$(GAMES_G++) $(GAMES_CFLAGS) $(GAMES_LDFLAGS) -lpng -lfx2 -o $(BUILD_TMP)/$(notdir $@)/rle rle.cpp
	cp -f $(BUILD_TMP)/$(notdir $@)/solitair.so $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/solitair.cfg $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/rle $(GAMES_INSTALL_DIR)
	cp -f $(BUILD_TMP)/$(notdir $@)/solitair_hint.png $(GAMES_INSTALL_DIR)
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/solitair.so
	$(GAMES_STRIP) $(GAMES_INSTALL_DIR)/rle
	rm -rf $(BUILD_TMP)/$(notdir $@)
	touch $@


games-all: games-update $(D)/libfx2 $(D)/tetris $(D)/sol $(D)/vierg $(D)/master $(D)/snake $(D)/tank $(D)/lemm $(D)/pac $(D)/sokoban
