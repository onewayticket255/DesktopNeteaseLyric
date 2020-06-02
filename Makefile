ARCHS = arm64e
TARGET = iphone:latest:13

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = music

music_FILES = Tweak.x
music_PRIVATE_FRAMEWORKS = MediaRemote
music_CFLAGS = -fobjc-arc


include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += musicpreference
include $(THEOS_MAKE_PATH)/aggregate.mk
