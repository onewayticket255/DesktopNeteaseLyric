ARCHS = arm64e
TARGET = iphone:latest:13
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk


TWEAK_NAME = SpringboardLyric

SpringboardLyric_FILES = Tweak.xm
SpringboardLyric_CFLAGS = -fobjc-arc
SpringboardLyric_LIBRARIES= rocketbootstrap
SpringboardLyric_PRIVATE_FRAMEWORKS = AppSupport MediaRemote


include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += NeteaseMusicLyric
SUBPROJECTS += NeteaseLyricSetting
include $(THEOS_MAKE_PATH)/aggregate.mk
