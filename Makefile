export ARCHS = arm64 arm64e
export TARGET = iphone:latest:13

FINALPACKAGE = 1

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
SUBPROJECTS += NeteaseMusicLyric
SUBPROJECTS += QQMusicLyric
SUBPROJECTS += CleanNeteaseMusic
SUBPROJECTS += CleanQQMusic
SUBPROJECTS += NeteaseLyricSetting
SUBPROJECTS += SpringBoardExtra
SUBPROJECTS += SpringBoardLyric
include $(THEOS_MAKE_PATH)/aggregate.mk
