import QtQuick 2.4
import "../common"

Item {
    id: root

    property bool showLabel: true
    property alias label: drawnLabel.text
    property int textSize: 8

    property color borderColor: "red"
    property color fillColor: "transparent"
    property color textBgColor: "white"
    property color textColor: "black"

    property double fillOpacity: 0.2
    property double borderOpacity: 1
    property int borderWidth: 1
    property bool underlined: false

    property alias _width: borderRect.width
    property alias _height: borderRect.height
    property alias _x: borderRect.x
    property alias _y: borderRect.y

    property int xmin: 0
    property int xmax: 10000
    property int ymin: 0
    property int ymax: 10000

    Rectangle {
        id: borderRect
        border.color: borderColor
        border.width: root.borderWidth
        color: "transparent"
        opacity: borderOpacity
    }

    Rectangle {
        id: fillRect
        anchors {
            fill: borderRect
            margins: borderRect.border.width
        }
        opacity: fillOpacity
        color: fillColor
    }

    Rectangle {
        visible: root.showLabel && drawnLabel.text != ''
        anchors {
            fill: drawnLabel
            leftMargin: -drawnLabel.anchors.leftMargin
            rightMargin: -drawnLabel.anchors.rightMargin
            topMargin: -borderWidth
            bottomMargin: -borderWidth
        }

        color: root.textBgColor
        border.color: borderRect.border.color
        border.width: root.borderWidth
    }

    Text {
        id: drawnLabel
        visible: root.showLabel
        anchors {
            bottom: if (borderRect.y - contentHeight > ymin) borderRect.top
            top: if (borderRect.y - contentHeight <= ymin) borderRect.bottom
            left: if (borderRect.x + contentWidth < xmax) borderRect.left
            right: if (borderRect.x + contentWidth >= xmax) borderRect.right
            leftMargin: borderWidth + 2
            rightMargin: borderWidth + 2
        }
        color: root.textColor
        font.bold: false
        font.pixelSize: root.textSize
        font.underline: root.underlined
    }
}
