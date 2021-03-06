#ifndef SOCKET_UDP_H
#define SOCKET_UDP_H

#include "protocol.h"
#include <QUdpSocket>

class RemoteEvent;
class Socket : public QUdpSocket
{
    Q_OBJECT

public:
    Socket(QObject *parent = nullptr);
    ~Socket();

    QHostAddress destAddr() const { return  m_destAddr; }
    Q_INVOKABLE void setDestAddr(const QHostAddress &addr) { m_destAddr = addr; }

    Q_INVOKABLE void finish();
    Q_INVOKABLE void writeToSocket(const QByteArray &d);

signals:
    void hasScreenData(const QByteArray &screenData);

private slots:
    void processRecvData();

private:
    QHostAddress m_destAddr;
};

#endif // SOCKET_UDP_H
