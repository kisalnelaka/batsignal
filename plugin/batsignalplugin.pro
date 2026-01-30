TEMPLATE = lib
TARGET = batsignalplugin
QT += core qml dbus
CONFIG += qt plugin c++17

DESTDIR = ../imports/org/kde/plasma/batsignal
TARGET = $$qtLibraryTarget($$TARGET)

HEADERS += \
    src/bluetoothmanager.h

SOURCES += \
    src/bluetoothmanager.cpp \
    src/plugin.cpp

# Install paths
target.path = $$[QT_INSTALL_QML]/org/kde/plasma/batsignal
INSTALLS += target

# qmldir file
qmldir.files = qmldir
qmldir.path = $$[QT_INSTALL_QML]/org/kde/plasma/batsignal
INSTALLS += qmldir
