#include "bluetoothmanager.h"
#include <QDBusMessage>
#include <QDBusMetaType>
#include <QDBusArgument>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDebug>

// Define types for GetManagedObjects return value: a{oa{sa{sv}}}
typedef QMap<QString, QVariantMap> InterfacesMap;
typedef QMap<QDBusObjectPath, InterfacesMap> ManagedObjectsMap;

Q_DECLARE_METATYPE(InterfacesMap)
Q_DECLARE_METATYPE(ManagedObjectsMap)

BluetoothManager::BluetoothManager(QObject *parent)
    : QObject(parent)
    , m_experimentalEnabled(false)
    , m_systemBus(QDBusConnection::systemBus())
{
    qDebug() << "BluetoothManager: Initializing...";
    
    // Register types
    qDBusRegisterMetaType<InterfacesMap>();
    qDBusRegisterMetaType<ManagedObjectsMap>();
    
    if (!m_systemBus.isConnected()) {
        qWarning() << "BluetoothManager: Cannot connect to D-Bus system bus";
    }
}

BluetoothManager::~BluetoothManager()
{
}

void BluetoothManager::updateDevices()
{
    qDebug() << "BluetoothManager: Updating devices...";
    queryBlueZDevices();
}

void BluetoothManager::queryBlueZDevices()
{
    m_devices.clear();
    m_experimentalEnabled = false;

    // Use QDBusInterface for easier handling
    QDBusInterface objectManager(
        "org.bluez",
        "/",
        "org.freedesktop.DBus.ObjectManager",
        m_systemBus
    );

    if (!objectManager.isValid()) {
        qWarning() << "BluetoothManager: ObjectManager interface not valid:" << objectManager.lastError().message();
        emit devicesChanged();
        return;
    }

    QDBusReply<ManagedObjectsMap> reply = objectManager.call("GetManagedObjects");
    
    if (!reply.isValid()) {
        qWarning() << "BluetoothManager: D-Bus call failed:" << reply.error().message();
        emit devicesChanged();
        return;
    }

    ManagedObjectsMap managedObjects = reply.value();
    
    // Iterate through all objects
    for (auto it = managedObjects.constBegin(); it != managedObjects.constEnd(); ++it) {
        QString path = it.key().path();
        InterfacesMap interfaces = it.value();
        
        // Check if this is a Bluetooth device
        if (interfaces.contains("org.bluez.Device1")) {
            // Convert to QVariantMap for parsing
            QVariantMap objInterfaces;
            for (auto iIt = interfaces.constBegin(); iIt != interfaces.constEnd(); ++iIt) {
                objInterfaces[iIt.key()] = iIt.value();
            }
            
            QVariantMap deviceData = parseDevice(path, objInterfaces);
            if (!deviceData.isEmpty()) {
                m_devices.append(deviceData);
            }
        }
    }

    qDebug() << "BluetoothManager: Found" << m_devices.size() << "devices";
    emit devicesChanged();
    
    if (m_experimentalEnabled) {
        emit experimentalEnabledChanged();
    }
}

QVariantMap BluetoothManager::parseDevice(const QString &path, const QVariantMap &interfaces)
{
    QVariantMap deviceData;
    QVariantMap device1 = interfaces.value("org.bluez.Device1").toMap();
    
    if (device1.isEmpty()) {
        return deviceData;
    }

    // Extract device properties
    deviceData["path"] = path;
    deviceData["name"] = device1.value("Alias", device1.value("Name", "Unknown Device")).toString();
    deviceData["address"] = device1.value("Address", "").toString();
    deviceData["connected"] = device1.value("Connected", false).toBool();
    deviceData["icon"] = device1.value("Icon", "bluetooth").toString();
    deviceData["hasBattery"] = false;
    deviceData["batteryPercentage"] = -1;

    // Check for battery interface
    if (interfaces.contains("org.bluez.Battery1")) {
        QVariantMap battery = interfaces.value("org.bluez.Battery1").toMap();
        deviceData["hasBattery"] = true;
        deviceData["batteryPercentage"] = battery.value("Percentage", 0).toInt();
        m_experimentalEnabled = true;
        
        qDebug() << "BluetoothManager: Device" << deviceData["name"].toString() 
                 << "has battery:" << deviceData["batteryPercentage"].toInt() << "%";
    }

    return deviceData;
}
