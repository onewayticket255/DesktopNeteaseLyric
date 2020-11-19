export TARGET = iphone:latest:14
export ARCHS= arm64 
export SYSROOT=$(THEOS)/sdks/iPhoneOS14.1.sdk

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
