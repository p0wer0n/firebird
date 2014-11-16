#ifndef EMUTHREAD_H
#define EMUTHREAD_H

#include <QThread>

class EmuThread : public QThread
{
    Q_OBJECT
public:
    explicit EmuThread(QObject *parent = 0);

    void doStuff();

    volatile bool paused = false;

    std::string emu_path_boot1 = "", emu_path_flash = "";

signals:
    void exited(int retcode);
    void serialChar(char c);
    void debugStr(QString str);
    void statusMsg(QString str);

public slots:
    virtual void run() override;
    void enterDebugger();
    void setPaused(bool paused);
    bool stop();
    void reset();

private:
    bool enter_debugger = false;
};

extern EmuThread *emu_thread;

#endif // EMUTHREAD_H
