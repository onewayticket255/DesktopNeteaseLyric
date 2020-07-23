INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
SUBPROJECTS += NeteaseMusicLyric
SUBPROJECTS += NeteaseLyricSetting
SUBPROJECTS += CleanNeteaseMusic
SUBPROJECTS += SpringBoardExtra
SUBPROJECTS += SpringBoardLyric
include $(THEOS_MAKE_PATH)/aggregate.mk
