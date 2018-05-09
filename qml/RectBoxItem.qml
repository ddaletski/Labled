import QtQuick 2.4

Item {
    Rectangle {
        id: drawnRect
        border.color: modelData.borderColor
        color: index == root.rects.length -1 ? modelData.fillColor : "transparent"
        x: modelData.x
        y: modelData.y
        width: modelData.width
        height: modelData.height
    }

    Rectangle {
        anchors {
            fill: drawnLabel
            leftMargin: -drawnLabel.anchors.leftMargin
            rightMargin: -drawnLabel.anchors.rightMargin
            topMargin: -1
            bottomMargin: -1
        }
        visible: drawnLabel.text != ''

        color: drawnRect.color
        border.color: drawnRect.border.color
    }

    Text {
        id: drawnLabel
        anchors {
            bottom: if (drawnRect.y > height) drawnRect.top
            top: if (drawnRect.y <= height) drawnRect.bottom
            left: drawnRect.left
            leftMargin: 3
            rightMargin: 3
        }
        text: modelData.label
    }
}
