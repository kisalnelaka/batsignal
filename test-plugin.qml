import QtQuick
import org.kde.plasma.batsignal 1.0

Item {
    BluetoothManager {
        id: btManager
        
        Component.onCompleted: {
            console.log("BluetoothManager loaded successfully!")
            console.log("Devices:", devices)
            console.log("Experimental enabled:", experimentalEnabled)
            updateDevices()
        }
        
        onDevicesChanged: {
            console.log("Devices updated:", devices.length, "devices found")
        }
    }
}
