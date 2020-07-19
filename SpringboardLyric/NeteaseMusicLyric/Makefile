ARCHS = arm64e
TARGET = iphone:latest:13
INSTALL_TARGET_PROCESSES = com.netease.cloudmusic


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NeteaseMusicLyric

NeteaseMusicLyric_FILES = Tweak.xm
NeteaseMusicLyric_CFLAGS = -fobjc-arc
NeteaseMusicLyric_LIBRARIES= rocketbootstrap
NeteaseMusicLyric_PRIVATE_FRAMEWORKS = AppSupport 

include $(THEOS_MAKE_PATH)/tweak.mk
