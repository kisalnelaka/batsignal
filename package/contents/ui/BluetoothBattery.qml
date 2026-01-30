import QtQuick
import org.kde.plasma.batsignal 1.0

BluetoothManager {
    id: bluetoothBattery
    
    // The C++ BluetoothManager provides:
    // - property var devices (list of device objects)
    // - property bool experimentalEnabled
    // - function updateDevices()
    // - signal devicesChanged()
    // - signal experimentalEnabledChanged()
    
    Component.onCompleted: {
        console.log("BatSignal: Using C++ BlueZ DBus integration")
        updateDevices()
    }
}
