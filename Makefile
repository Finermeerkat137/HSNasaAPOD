rmpackage: clean
	rm -rf packages

INSTALL_TARGET_PROCESSES = SpringBoard
export TARGET = iphone:clang:latest
include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e
BUNDLE_NAME = HSNasaPictureOfTheDay
HSNasaPictureOfTheDay_FILES = HSNasaPictureOfTheDayViewController.m HSNasaPictureOfTheDayPreferencesViewController.m cutils.c Reachability.m

HSNasaPictureOfTheDay_FRAMEWORKS = UIKit SystemConfiguration
HSNasaPictureOfTheDay_PRIVATE_FRAMEWORKS = Preferences OnBoardingKit
HSNasaPictureOfTheDay_EXTRA_FRAMEWORKS = HSWidgets
HSNasaPictureOfTheDay_INSTALL_PATH = /Library/HSWidgets
HSNasaPictureOfTheDay_CFLAGS = -fobjc-arc -Wall -Werror -Wno-deprecated

include $(THEOS_MAKE_PATH)/bundle.mk

