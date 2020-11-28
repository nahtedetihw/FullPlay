ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = fullplaypodcasts

fullplaypodcasts_FILES = fullplaypodcasts.xm
fullplaypodcasts_CFLAGS = -fobjc-arc
fullplaypodcasts_EXTRA_FRAMEWORKS = Cephei
fullplaypodcasts_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS\_Store" -delete
