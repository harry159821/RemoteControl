#ifndef CONTROLLER_H
#define CONTROLLER_H

#include "remoteevent.h"
#include <QObject>

class Socket;
class ImageProvider;
class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QObject *parent = nullptr);

    ImageProvider* getImageProvider() { return m_provider; }

    Q_INVOKABLE void finish();
    Q_INVOKABLE void mousePressed(const QPointF &position);
    Q_INVOKABLE void mouseReleased(const QPointF &position);
    Q_INVOKABLE void mouseMoved(const QPointF &position);
    Q_INVOKABLE void requestNewConnection(const QString &address);

signals:
    void connected();
    void disconnected();
    void needUpdate();

private:
    inline void sendRemoteEvent(RemoteEvent::EventType type, const QPointF &position);

    Socket *m_socket;
    ImageProvider *m_provider;
};

#endif // CONTROLLER_H
