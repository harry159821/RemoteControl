#include "controller.h"
#include "imageprovider.h"
#include "networkapi.h"
#include "socket.h"

#include <QGuiApplication>
#include <QHostAddress>
#include <QThread>

Controller::Controller(QObject *parent)
    : QObject(parent)
{
    m_provider = new ImageProvider;

    m_socket = new Socket;
    QThread *thread = new QThread;
    connect(thread, &QThread::finished, thread, &QThread::deleteLater);
    connect(m_socket, &Socket::connected, this, &Controller::connected);
    connect(m_socket, &Socket::disconnected, this, &Controller::disconnected);
    connect(m_socket, &Socket::hasScreenData, this, [this](const QByteArray &screenData) {
        QPixmap pixmap;
        pixmap.loadFromData(screenData);
        m_provider->setPixmap(pixmap);
        emit needUpdate();
    });
    m_socket->moveToThread(thread);
    thread->start();
}

void Controller::finish()
{
     QMetaObject::invokeMethod(m_socket, "abort");
}

void Controller::mousePressed(const QPointF &position)
{
    sendRemoteEvent(RemoteEvent::EventType::Pressed, position);
}

void Controller::mouseReleased(const QPointF &position)
{
    sendRemoteEvent(RemoteEvent::EventType::Released, position);
}

void Controller::mouseMoved(const QPointF &position)
{
    sendRemoteEvent(RemoteEvent::EventType::Moved, position);
}

void Controller::requestNewConnection(const QString &address)
{
    QHostAddress hostAddress(address);
    //有效且不为本机地址
    if (!hostAddress.isNull() && !NetworkApi::isLocalAddress(hostAddress)) {
        QMetaObject::invokeMethod(m_socket, "abort");
        QMetaObject::invokeMethod(m_socket, "connectHost", Q_ARG(QHostAddress, hostAddress), Q_ARG(quint16, 43800));
    }
}

void Controller::sendRemoteEvent(RemoteEvent::EventType type, const QPointF &position)
{
    RemoteEvent event(type, position);
    QMetaObject::invokeMethod(m_socket, "writeToSocket", Q_ARG(RemoteEvent, event));
}
