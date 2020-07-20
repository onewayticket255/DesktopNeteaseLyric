ARCHS = arm64e
TARGET = iphone:latest:13
include $(THEOS)/makefiles/common.mk


TWEAK_NAME = SpringBoardLyric

SpringBoardLyric_FILES = Tweak.xm
SpringBoardLyric_CFLAGS = -fobjc-arc
SpringBoardLyric_LIBRARIES= rocketbootstrap
SpringBoardLyric_PRIVATE_FRAMEWORKS = AppSupport MediaRemote


include $(THEOS_MAKE_PATH)/tweak.mk

