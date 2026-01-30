import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    // Tooltip configuration
    toolTipMainText: i18n("Bluetooth Battery Monitor")
    toolTipSubText: getToolTipText()
    
    // Preferred sizes
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredHeight: Kirigami.Units.gridUnit * 15
    Layout.minimumWidth: Kirigami.Units.gridUnit * 15
    Layout.minimumHeight: Kirigami.Units.gridUnit * 10
    
    // Configuration properties
    property int updateInterval: plasmoid.configuration.updateInterval
    property bool showOnlyBatteryDevices: plasmoid.configuration.showOnlyBatteryDevices
    property int lowBatteryThreshold: plasmoid.configuration.lowBatteryThreshold
    property bool enableNotifications: plasmoid.configuration.enableNotifications
    
    // Bluetooth battery service
    BluetoothBattery {
        id: btBattery
    }
    
    // Handle device updates
    Connections {
        target: btBattery
        
        function onDevicesChanged() {
            updateToolTip()
            checkLowBattery()
        }
    }
    
    // Update timer
    Timer {
        id: updateTimer
        interval: updateInterval * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            btBattery.updateDevices()
        }
    }
    
    // Notification tracking
    property var notifiedDevices: ({})
    
    function checkLowBattery() {
        if (!enableNotifications) return
        
        btBattery.devices.forEach(function(device) {
            if (device.hasBattery && device.connected && 
                device.batteryPercentage <= lowBatteryThreshold &&
                device.batteryPercentage > 0) {
                
                // Only notify once per device until battery goes above threshold
                if (!notifiedDevices[device.address]) {
                    showNotification(device)
                    notifiedDevices[device.address] = true
                }
            } else if (device.batteryPercentage > lowBatteryThreshold) {
                // Reset notification flag when battery is charged
                notifiedDevices[device.address] = false
            }
        })
    }
    
    function showNotification(device) {
        var notification = notificationComponent.createObject(root, {
            "deviceName": device.name,
            "batteryLevel": device.batteryPercentage
        })
        notification.show()
    }
    
    Component {
        id: notificationComponent
        
        QtObject {
            property string deviceName
            property int batteryLevel
            
            function show() {
                plasmoid.nativeInterface.showNotification(
                    "battery-low",
                    i18n("Low Battery Warning"),
                    i18n("%1 battery is at %2%", deviceName, batteryLevel)
                )
            }
        }
    }
    
    function getToolTipText() {
        var connectedDevices = btBattery.devices.filter(function(d) { return d.connected })
        
        if (connectedDevices.length === 0) {
            return i18n("No Bluetooth devices connected")
        }
        
        var withBattery = connectedDevices.filter(function(d) { return d.hasBattery })
        
        if (withBattery.length === 0) {
            if (!btBattery.experimentalEnabled) {
                return i18n("%1 device(s) connected\nEnable BlueZ experimental features to see battery levels", connectedDevices.length)
            }
            return i18n("%1 device(s) connected\nNo battery information available", connectedDevices.length)
        }
        
        var text = i18n("%1 device(s) with battery info:", withBattery.length)
        withBattery.forEach(function(device) {
            text += "\n" + device.name + ": " + device.batteryPercentage + "%"
        })
        
        return text
    }
    
    function updateToolTip() {
        root.toolTipSubText = getToolTipText()
    }
    
    // Compact representation (panel icon)
    compactRepresentation: Item {
        implicitWidth: Kirigami.Units.iconSizes.smallMedium
        implicitHeight: Kirigami.Units.iconSizes.smallMedium
        
        Kirigami.Icon {
            id: compactIcon
            anchors.fill: parent
            source: getBatteryIcon()
            
            // Badge showing number of devices
            PlasmaComponents3.Label {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 2
                
                text: getConnectedBatteryCount()
                visible: getConnectedBatteryCount() > 0
                
                font.pixelSize: parent.height * 0.4
                font.bold: true
                
                color: "white"
                
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    color: getLowestBattery() <= lowBatteryThreshold ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.highlightColor
                    radius: height / 2
                    z: -1
                }
            }
            
            MouseArea {
                id: compactMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: plasmoid.expanded = !plasmoid.expanded
            }
        }
    }
    
    function getBatteryIcon() {
        var lowestBattery = getLowestBattery()
        
        if (lowestBattery < 0) return "battery-missing"
        if (lowestBattery <= 10) return "battery-010"
        if (lowestBattery <= 20) return "battery-020"
        if (lowestBattery <= 30) return "battery-030"
        if (lowestBattery <= 40) return "battery-040"
        if (lowestBattery <= 60) return "battery-060"
        if (lowestBattery <= 80) return "battery-080"
        return "battery-100"
    }
    
    function getLowestBattery() {
        var lowest = -1
        btBattery.devices.forEach(function(device) {
            if (device.hasBattery && device.connected) {
                if (lowest < 0 || device.batteryPercentage < lowest) {
                    lowest = device.batteryPercentage
                }
            }
        })
        return lowest
    }
    
    function getConnectedBatteryCount() {
        return btBattery.devices.filter(function(d) { 
            return d.connected && d.hasBattery 
        }).length
    }
    
    // Full representation (expanded view)
    fullRepresentation: ColumnLayout {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: Kirigami.Units.gridUnit * 15
        
        // Header
        PlasmaExtras.PlasmoidHeading {
            Layout.fillWidth: true
            
            RowLayout {
                anchors.fill: parent
                
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: i18n("Bluetooth Devices")
                    font.weight: Font.Bold
                }
                
                PlasmaComponents3.ToolButton {
                    icon.name: "view-refresh"
                    onClicked: btBattery.updateDevices()
                    PlasmaComponents3.ToolTip {
                        text: i18n("Refresh device list")
                    }
                }
                
                PlasmaComponents3.ToolButton {
                    icon.name: "configure"
                    onClicked: plasmoid.action("configure").trigger()
                    PlasmaComponents3.ToolTip {
                        text: i18n("Configure")
                    }
                }
            }
        }
        
        // Device list
        PlasmaComponents3.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ListView {
                id: deviceListView
                
                model: getFilteredDevices()
                
                delegate: PlasmaComponents3.ItemDelegate {
                    width: deviceListView.width
                    
                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        
                        // Device icon
                        Kirigami.Icon {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                            source: modelData.icon
                            opacity: modelData.connected ? 1.0 : 0.5
                        }
                        
                        // Device info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                opacity: modelData.connected ? 1.0 : 0.7
                            }
                            
                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: modelData.connected ? i18n("Connected") : i18n("Disconnected")
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                opacity: 0.7
                            }
                        }
                        
                        // Battery indicator
                        RowLayout {
                            spacing: Kirigami.Units.smallSpacing
                            visible: modelData.hasBattery
                            
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                source: getBatteryIconForLevel(modelData.batteryPercentage)
                            }
                            
                            PlasmaComponents3.Label {
                                text: modelData.batteryPercentage + "%"
                                font.weight: Font.Bold
                                color: modelData.batteryPercentage <= lowBatteryThreshold ? 
                                       Kirigami.Theme.negativeTextColor : 
                                       Kirigami.Theme.textColor
                            }
                        }
                        
                        // No battery info label
                        PlasmaComponents3.Label {
                            visible: !modelData.hasBattery && modelData.connected
                            text: i18n("No battery info")
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            opacity: 0.5
                        }
                    }
                }
                
                // Empty state
                PlasmaExtras.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.gridUnit * 4)
                    
                    visible: deviceListView.count === 0
                    
                    iconName: btBattery.devices.length === 0 ? "bluetooth" : "battery-missing"
                    text: getEmptyStateText()
                }
            }
        }
        
        // Footer with experimental features warning
        PlasmaExtras.PlasmoidHeading {
            Layout.fillWidth: true
            visible: !btBattery.experimentalEnabled && btBattery.devices.length > 0
            
            Kirigami.InlineMessage {
                anchors.fill: parent
                type: Kirigami.MessageType.Warning
                text: i18n("Enable BlueZ experimental features to see battery levels")
                visible: true
                
                actions: [
                    Kirigami.Action {
                        text: i18n("Configure")
                        icon.name: "configure"
                        onTriggered: plasmoid.action("configure").trigger()
                    }
                ]
            }
        }
    }
    
    function getFilteredDevices() {
        if (showOnlyBatteryDevices) {
            return btBattery.devices.filter(function(d) { return d.hasBattery })
        }
        return btBattery.devices
    }
    
    function getBatteryIconForLevel(level) {
        if (level <= 10) return "battery-010"
        if (level <= 20) return "battery-020"
        if (level <= 30) return "battery-030"
        if (level <= 40) return "battery-040"
        if (level <= 60) return "battery-060"
        if (level <= 80) return "battery-080"
        return "battery-100"
    }
    
    function getEmptyStateText() {
        if (btBattery.devices.length === 0) {
            return i18n("No Bluetooth devices found\n\nMake sure Bluetooth is enabled and devices are paired")
        }
        
        if (showOnlyBatteryDevices) {
            return i18n("No devices with battery information\n\nEnable BlueZ experimental features or disable the filter in settings")
        }
        
        return i18n("No devices")
    }
}
