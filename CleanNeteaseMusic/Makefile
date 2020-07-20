ARCHS = arm64e
TARGET = iphone:latest:13
INSTALL_TARGET_PROCESSES = com.netease.cloudmusic

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CleanNeteaseMusic

CleanNeteaseMusic_FILES = Tweak.xm
CleanNeteaseMusic_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
