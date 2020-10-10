export TARGET = iphone:latest:13

ifeq ($(debug),0)
	export ARCHS= arm64 arm64e
else
	export ARCHS= arm64 
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
SUBPROJECTS += SpotifyMusicLyric
SUBPROJECTS += NeteaseMusicLyric
SUBPROJECTS += QQMusicLyric
SUBPROJECTS += CleanNeteaseMusic
SUBPROJECTS += CleanQQMusic
SUBPROJECTS += SpringBoardExtra
SUBPROJECTS += SpringBoardLyric
SUBPROJECTS += NeteaseLyricSetting
include $(THEOS_MAKE_PATH)/aggregate.mk
