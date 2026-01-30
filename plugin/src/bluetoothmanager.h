#ifndef BLUETOOTHMANAGER_H
#define BLUETOOTHMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QTimer>

class BluetoothManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList devices READ devices NOTIFY devicesChanged)
    Q_PROPERTY(bool experimentalEnabled READ experimentalEnabled NOTIFY experimentalEnabledChanged)

public:
    explicit BluetoothManager(QObject *parent = nullptr);
    ~BluetoothManager();

    QVariantList devices() const { return m_devices; }
    bool experimentalEnabled() const { return m_experimentalEnabled; }

    Q_INVOKABLE void updateDevices();

signals:
    void devicesChanged();
    void experimentalEnabledChanged();

private:
    void queryBlueZDevices();
    QVariantMap parseDevice(const QString &path, const QVariantMap &interfaces);
    
    QVariantList m_devices;
    bool m_experimentalEnabled;
    QDBusConnection m_systemBus;
};

#endif // BLUETOOTHMANAGER_H
