import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Window
{
    id: root
    visible: true
    width: 480
    height: 320
    title: qsTr("RemoteControl")
    color: "#D4E6FF"
    Component.onCompleted:
    {
        stackView.push(mainPage);
        flags |= Qt.FramelessWindowHint;
    }

    property bool mobile: Qt.platform.os == "android";
    property bool connected: false;
    property string localIpAddress: Api.getLocalIpAddress();

    Connections
    {
        target: controlled
        onConnected: root.connected = true;
        onDisconnected: root.connected = false;
    }

    Connections
    {
        target: controller
        onConnected:
        {
            root.connected = true;
            stackView.push("ControllerPage.qml");
        }
        onDisconnected:
        {
            root.connected = false;
            stackView.pop();
        }
    }

    ResizeMouseArea
    {
        anchors.fill: parent
        target: root
    }

    GlowRectangle
    {
        id: windowTitle
        clip: true
        radius: 5
        z: 5
        height: mobile && connected ? 0 : 40;   //如果是手机，并且已经连接就不显示
        width: parent.width
        color: "#F4D1B4"
        glowColor: color
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -radius

        Text
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            text: qsTr("远程控制")
        }

        MyButton
        {
            id: minButton
            fontSize: 12
            widthMargin: 8
            anchors.right: maxButton.left
            anchors.rightMargin: 6
            anchors.top: maxButton.top
            text: " - "
            onClicked: root.showMinimized();
        }

        MyButton
        {
            id: maxButton
            fontSize: 12
            widthMargin: 8
            anchors.right: closeButton.left
            anchors.rightMargin: 6
            anchors.top: closeButton.top
            text: " + "
            onClicked: root.showMaximized();
        }

        MyButton
        {
            id: closeButton
            fontSize: 12
            widthMargin: 8
            anchors.right: parent.right
            anchors.top: parent.top
            text: " x "
            onClicked:
            {
                if (stackView.depth == 1)
                    root.close();
                else controller.finish();
            }
        }
    }

    StackView
    {
        id: stackView
        width: parent.width
        anchors.top: windowTitle.bottom
        anchors.bottom: parent.bottom
    }

    Component
    {
        id: mainPage

        Item
        {
            Column
            {
                anchors.centerIn: parent
                spacing: 32

                Item
                {
                    width: 300
                    height: 30

                    Text
                    {
                        id: ipAddressText
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pointSize: 13
                        color: "red"
                        text: qsTr("本机IP地址：" + localIpAddress)
                    }
                }

                Item
                {
                    width: 300
                    height: 30

                    Text
                    {
                        id: remoteIpAddressText
                        font.pointSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("远程IP地址：")
                    }

                    TextField
                    {
                        id: remoteIpAddressEdit
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: remoteIpAddressText.right
                        anchors.rightMargin: 10
                        width: 200
                        height: parent.height
                        selectByMouse: true
                        placeholderText: qsTr("输入IPv4 / IPv6 地址")
                        background: Rectangle
                        {
                            radius: 6
                            border.color: "#09A3DC"
                        }
                        validator: RegExpValidator
                        {
                            regExp: /(2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2}(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}/
                        }
                    }
                }

                Item
                {
                    width: 300
                    height: 30

                    MyButton
                    {
                        id: connectButton
                        anchors.horizontalCenter: parent.horizontalCenter
                        heightMargin: 8
                        text: " <-连接-> "
                        onClicked: controller.requestNewConnection(remoteIpAddressEdit.text)
                    }
                }
            }
        }
    }
}
