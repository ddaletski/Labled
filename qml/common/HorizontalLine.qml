import QtQuick 2.4

Item {
    id: root
    property alias color: rect.color
    property alias border: rect.border
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
