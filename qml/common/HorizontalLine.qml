import QtQuick 2.4

Rectangle {
    id: root
    property alias lineColor: rect.color
    property alias lineBorder: rect.border
    property alias lineHeight: rect.height

    Rectangle {
        id: rect
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        radius: 1
        border.color: 'black'
    }
}
