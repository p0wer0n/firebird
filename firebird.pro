lessThan(QT_MAJOR_VERSION, 5) : error("You need at least Qt 5 to build firebird!")

# JIT
TRANSLATION_ENABLED = false

# Localization
TRANSLATIONS += i18n/de_DE.ts i18n/fr_FR.ts

QT += core gui widgets quickwidgets
CONFIG += c++11

TEMPLATE = app
TARGET = firebird

# For make install support
target.path = /usr/bin
desktop.path = /usr/share/applications
desktop.files += resources/firebird.desktop
icon.path = /usr/share/icons
icon.files += resources/firebird.png
sendtool.path = /usr/bin
sendtool.files = core/firebird-send
INSTALLS += target desktop icon sendtool

QMAKE_CFLAGS = -g -std=gnu11 -Wall -Wextra
QMAKE_CXXFLAGS = -g -std=c++11 -Wall -Wextra

# Override bad default options to enable better optimizations
QMAKE_CFLAGS_RELEASE = -O3 -flto
QMAKE_CXXFLAGS_RELEASE = -O3 -flto
QMAKE_LFLAGS_RELEASE = -Wl,-O3 -flto

# ICE on mac with clang
macx-clang|ios {
    QMAKE_CFLAGS_RELEASE -= -flto
    QMAKE_CXXFLAGS_RELEASE -= -flto
    QMAKE_LFLAGS_RELEASE -= -Wl,-O3 -flto
}

macx {
    ICON = resources/logo.icns
}

# This does also apply to android
linux|macx|ios {
    SOURCES += core/os/os-linux.c
}

ios|android {
    DEFINES += MOBILE_UI
}

ios {
    DEFINES += IS_IOS_BUILD __arm__
    QMAKE_INFO_PLIST = Info.plist
    QMAKE_CFLAGS += -mno-thumb
    QMAKE_CXXFLAGS += -mno-thumb
    QMAKE_LFLAGS += -mno-thumb
    QMAKE_IOS_DEVICE_ARCHS = armv7
}

# QMAKE_HOST can be e.g. armv7hl, but QT_ARCH would be arm in such cases
QMAKE_TARGET.arch = $$QT_ARCH

win32 {
    SOURCES += core/os/os-win32.c
    LIBS += -lwinmm -lws2_32
    # Somehow it's set to x86_64...
    QMAKE_TARGET.arch = x86
}

linux-g++-32 {
    QMAKE_CFLAGS += -m32
    QMAKE_CXXFLAGS += -m32
    QMAKE_TARGET.arch = x86
}

# A platform-independant implementation of lowlevel access as default
ASMCODE_IMPL = core/asmcode.c

equals(TRANSLATION_ENABLED, true) {
    TRANSLATE = $$join(QMAKE_TARGET.arch, "", "core/translate_", ".c")
    exists($$TRANSLATE) {
        SOURCES += $$TRANSLATE
    }

    TRANSLATE2 = $$join(QMAKE_TARGET.arch, "", "core/translate_", ".cpp")
    exists($$TRANSLATE2) {
        SOURCES += $$TRANSLATE2
    }

    ASMCODE = $$join(QMAKE_TARGET.arch, "", "core/asmcode_", ".S")
    exists($$ASMCODE): ASMCODE_IMPL = $$ASMCODE
}
else: DEFINES += NO_TRANSLATION

# The x86_64 and ARM JIT use asmcode.c for mem access
contains(QMAKE_TARGET.arch, "x86_64") || contains(QMAKE_TARGET.arch, "arm") {
    !contains(ASMCODE_IMPL, "asmcode.c") {
        SOURCES += core/asmcode.c
    }
}

# Default to armv7 on ARM for movw/movt. If your CPU doesn't support it, comment this out.
contains(QMAKE_TARGET.arch, "arm") {
    QMAKE_CFLAGS += -march=armv7-a -marm
    QMAKE_CXXFLAGS += -march=armv7-a -marm
    QMAKE_LFLAGS += -march=armv7-a -marm # We're using LTO, so the linker has to get the same flags
}

SOURCES += $$ASMCODE_IMPL \
    lcdwidget.cpp \
    mainwindow.cpp \
    main.cpp \
    flashdialog.cpp \
    emuthread.cpp \
    qmlbridge.cpp \
    qtkeypadbridge.cpp \
    core/arm_interpreter.cpp \
    core/coproc.cpp \
    core/cpu.cpp \
    core/thumb_interpreter.cpp \
    core/usblink_queue.cpp \
    core/armsnippets_loader.c \
    core/casplus.c \
    core/des.c \
    core/disasm.c \
    core/emu.c \
    core/flash.c \
    core/gdbstub.c \
    core/interrupt.c \
    core/keypad.c \
    core/lcd.c \
    core/link.c \
    core/mem.c \
    core/misc.c \
    core/mmu.c \
    core/schedule.c \
    core/serial.c \
    core/sha256.c \
    core/usb.c \
    core/usblink.c \
    qtframebuffer.cpp \
    core/debug.cpp

FORMS += \
    mainwindow.ui \
    flashdialog.ui

HEADERS += \
    emuthread.h \
    lcdwidget.h \
    flashdialog.h \
    mainwindow.h \
    keymap.h \
    qmlbridge.h \
    qtkeypadbridge.h \
    core/os/os.h \
    core/armcode_bin.h \
    core/armsnippets.h \
    core/asmcode.h \
    core/bitfield.h \
    core/casplus.h \
    core/cpu.h \
    core/cpudefs.h \
    core/debug.h \
    core/des.h \
    core/disasm.h \
    core/emu.h \
    core/flash.h \
    core/gdbstub.h \
    core/interrupt.h \
    core/keypad.h \
    core/lcd.h \
    core/link.h \
    core/mem.h \
    core/misc.h \
    core/mmu.h \
    core/schedule.h \
    core/sha256.h \
    core/translate.h \
    core/usb.h \
    core/usblink.h \
    core/usblink_queue.h \
    qtframebuffer.h

# Generate the binary arm code into armcode_bin.h
armsnippets.commands = arm-none-eabi-gcc -fno-leading-underscore -c $$PWD/core/armsnippets.S -o armsnippets.o -mcpu=arm926ej-s \
						&& arm-none-eabi-objcopy -O binary armsnippets.o snippets.bin \
                        && xxd -i snippets.bin > $$PWD/core/armcode_bin.h \
						&& rm armsnippets.o

# In case you change armsnippets.S, run "make armsnippets" and update armcode_bin.h
QMAKE_EXTRA_TARGETS = armsnippets

OTHER_FILES += \
    TODO

RESOURCES += \
    resources.qrc

DISTFILES += \
    core/firebird-send
