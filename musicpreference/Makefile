include $(THEOS)/makefiles/common.mk
ARCHS = arm64e
TARGET = iphone:latest:13

BUNDLE_NAME = musicpreference

musicpreference_FILES = XXXRootListController.m
musicpreference_INSTALL_PATH = /Library/PreferenceBundles
musicpreference_FRAMEWORKS = UIKit
musicpreference_PRIVATE_FRAMEWORKS = Preferences
musicpreference_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/musicpreference.plist$(ECHO_END)
