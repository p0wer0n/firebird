#ifndef QMLBRIDGE_H
#define QMLBRIDGE_H

#include <QObject>
#include <QtQml>

#include "emuthread.h"

class QMLBridge : public QObject
{
    Q_OBJECT
public:
    explicit QMLBridge(QObject *parent = 0);
    ~QMLBridge() {}

    Q_INVOKABLE void keypadStateChanged(int keymap_id, bool state);
    Q_INVOKABLE void registerNButton(int keymap_id, QVariant button);

    // Coordinates: (0/0) = top left (1/1) = bottom right
    Q_INVOKABLE void touchpadStateChanged(qreal x, qreal y, bool state);
    Q_INVOKABLE void registerTouchpad(QVariant touchpad);

    #ifdef MOBILE_UI
        Q_INVOKABLE bool restart();
        Q_INVOKABLE void setPaused(bool b);
        Q_INVOKABLE void reset();
        Q_INVOKABLE bool stop();

        EmuThread emu_thread;
    #endif
};

void notifyKeypadStateChanged(int row, int col, bool state);
void notifyTouchpadStateChanged();
void notifyTouchpadStateChanged(qreal x, qreal y, bool state);
QObject *qmlBridgeFactory(QQmlEngine *engine, QJSEngine *scriptEngine);


#endif // QMLBRIDGE_H
