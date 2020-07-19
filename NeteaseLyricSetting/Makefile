ARCHS = arm64e
TARGET = iphone:latest:13

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NeteaseLyricSetting

NeteaseLyricSetting_FILES = NLSRootListController.m
NeteaseLyricSetting_FRAMEWORKS = UIKit
NeteaseLyricSetting_PRIVATE_FRAMEWORKS = Preferences
NeteaseLyricSetting_INSTALL_PATH = /Library/PreferenceBundles
NeteaseLyricSetting_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
