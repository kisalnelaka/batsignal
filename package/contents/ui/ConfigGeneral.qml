import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: configGeneral
    
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_showOnlyBatteryDevices: showOnlyBatteryCheckBox.checked
    property alias cfg_lowBatteryThreshold: lowBatterySpinBox.value
    property alias cfg_enableNotifications: notificationsCheckBox.checked
    
    // Experimental Features Section
    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("BlueZ Setup")
    }
    
    ColumnLayout {
        Kirigami.FormData.label: i18n("Experimental Features:")
        spacing: Kirigami.Units.smallSpacing
        
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            type: Kirigami.MessageType.Information
            text: i18n("BatSignal requires BlueZ experimental features to access battery information from Bluetooth devices.")
            visible: true
        }
        
        RowLayout {
            spacing: Kirigami.Units.smallSpacing
            
            QQC2.TextField {
                id: enableCommand
                Layout.fillWidth: true
                readOnly: true
                text: "sudo ./enable-bluez-experimental.sh enable"
                selectByMouse: true
            }
            
            QQC2.Button {
                icon.name: "edit-copy"
                text: i18n("Copy")
                onClicked: {
                    enableCommand.selectAll()
                    enableCommand.copy()
                    copiedLabel.visible = true
                    copiedTimer.restart()
                }
            }
        }
        
        QQC2.Label {
            id: copiedLabel
            text: i18n("✓ Copied to clipboard")
            color: Kirigami.Theme.positiveTextColor
            visible: false
            
            Timer {
                id: copiedTimer
                interval: 2000
                onTriggered: copiedLabel.visible = false
            }
        }
        
        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Run this command in a terminal to enable experimental features, then restart this widget.")
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.7
        }
    }
    
    // General Settings Section
    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("General Settings")
    }
    
    QQC2.SpinBox {
        id: updateIntervalSpinBox
        Kirigami.FormData.label: i18n("Update interval:")
        from: 5
        to: 300
        stepSize: 5
        textFromValue: function(value) {
            return i18n("%1 seconds", value)
        }
    }
    
    QQC2.CheckBox {
        id: showOnlyBatteryCheckBox
        Kirigami.FormData.label: i18n("Filter devices:")
        text: i18n("Show only devices with battery support")
    }
    
    // Battery Notifications Section
    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Notifications")
    }
    
    QQC2.CheckBox {
        id: notificationsCheckBox
        Kirigami.FormData.label: i18n("Low battery alerts:")
        text: i18n("Enable notifications")
    }
    
    QQC2.SpinBox {
        id: lowBatterySpinBox
        Kirigami.FormData.label: i18n("Warning threshold:")
        enabled: notificationsCheckBox.checked
        from: 5
        to: 50
        stepSize: 5
        textFromValue: function(value) {
            return i18n("%1%", value)
        }
    }
}
