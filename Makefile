ARCHS = arm64e
TARGET = iphone:latest:13
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk


TWEAK_NAME = NeteaseSpringBoardLyric

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += NeteaseMusicLyric
SUBPROJECTS += NeteaseLyricSetting
SUBPROJECTS += CleanNeteaseMusic
SUBPROJECTS += SpringBoardExtra
SUBPROJECTS += SpringBoardLyric
include $(THEOS_MAKE_PATH)/aggregate.mk
