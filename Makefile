include $(THEOS)/makefiles/common.mk

TOOL_NAME = DuplicateFinder
DuplicateFinder_FILES = DuplicateFinder.m main.mm
DuplicateFinder_FRAMEWORKS = UIKit Foundation
DuplicateFinder_CFLAGS = -fobjc-arc
DuplicateFinder_CODESIGN_FLAGS += -Sent.plist -Icom.i0stweak3r.duplicatefinder

include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
