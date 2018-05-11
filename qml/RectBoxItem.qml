import QtQuick 2.4

Item {
    id: root

    property bool showLabel: true
    property alias label: drawnLabel.text
    property color borderColor: "red"
    property color fillColor: "transparent"
    property color textBgColor: "white"
    property color textColor: "black"

    property int borderWidth: 1
    property alias _width: drawnRect.width
    property alias _height: drawnRect.height
    property alias _x: drawnRect.x
    property alias _y: drawnRect.y

    Rectangle {
        id: drawnRect
        border.color: borderColor
        border.width: root.borderWidth
        color: fillColor
    }

    Rectangle {
        visible: root.showLabel && drawnLabel.text != ''
        anchors {
            fill: drawnLabel
            leftMargin: -drawnLabel.anchors.leftMargin
            rightMargin: -drawnLabel.anchors.rightMargin
            topMargin: -1
            bottomMargin: -1
        }

        color: root.textBgColor
        border.color: drawnRect.border.color
        border.width: root.borderWidth
    }

    Text {
        id: drawnLabel
        visible: root.showLabel
        anchors {
            bottom: if (drawnRect.y > height) drawnRect.top
            top: if (drawnRect.y <= height) drawnRect.bottom
            left: drawnRect.left
            leftMargin: 3
            rightMargin: 3
        }
        color: root.textColor
        font.bold: true
    }
}
