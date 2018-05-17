import QtQuick 2.4

Item {
    id: root
    property alias color: rect.color
    property alias border: rect.border
    property alias lineWidth: rect.width

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
