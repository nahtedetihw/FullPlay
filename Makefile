TARGET := iphone:clang:latest:7.0

DEBUG = 0
FINALPACKAGE = 1
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

before-stage::
	find . -name ".DS\_Store" -delete

TWEAK_NAME = FullPlay

FullPlay_FILES = Tweak.xm
FullPlay_CFLAGS = -fobjc-arc
FullPlay_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Music && killall -9 Preferences"
SUBPROJECTS += fullplayprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
