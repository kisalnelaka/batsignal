#include <QQmlExtensionPlugin>
#include <QtQml>
#include "bluetoothmanager.h"

class BatSignalPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(uri == QLatin1String("org.kde.plasma.batsignal"));
        qmlRegisterType<BluetoothManager>(uri, 1, 0, "BluetoothManager");
    }
};

#include "plugin.moc"
