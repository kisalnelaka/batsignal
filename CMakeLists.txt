cmake_minimum_required(VERSION 3.16)

project(batsignal VERSION 1.0.0 LANGUAGES CXX)

set(QT_MIN_VERSION "6.0.0")
set(KF_MIN_VERSION "6.0.0")

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core Qml DBus)

add_subdirectory(plugin)

# Install the plasma package
# The package directory content is installed to the plasmoids folder
install(DIRECTORY package/ DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/org.kde.plasma.batsignal)

# Install metadata.json explicitly if needed, but the directory copy covers it.
# Note: kpackagetool6 does this, but cmake install is the standard distro way.
