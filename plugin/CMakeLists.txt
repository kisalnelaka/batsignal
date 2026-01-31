add_library(batsignalplugin SHARED)

target_sources(batsignalplugin PRIVATE
    src/bluetoothmanager.cpp
    src/plugin.cpp
    src/bluetoothmanager.h
)

target_link_libraries(batsignalplugin PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::DBus
)

# Install the plugin binary
install(TARGETS batsignalplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/batsignal)

# Install the qmldir definition
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/batsignal)
