import QtQuick 2.4

Rectangle {
    id: root
    property alias lineWidth: rect.width
    property alias lineColor: rect.color
    property alias lineBorder: rect.border

    Rectangle {
        id: rect
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        radius: 1
        border.color: 'black'
    }
}
