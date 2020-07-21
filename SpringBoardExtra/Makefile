ARCHS = arm64e
TARGET = iphone:latest:13

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpringBoardExtra

SpringBoardExtra_FILES = CCArtwork.xm MusicBeQuiet.xm QuitAll.xm CleanSpringBoard.xm CompactMediaPlayer.xm DarkLaunchScreen.xm
SpringBoardExtra_PRIVATE_FRAMEWORKS = MediaRemote
SpringBoardExtra_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

