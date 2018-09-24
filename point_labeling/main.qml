import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
 
ApplicationWindow {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("Point Labeling")


    Item {
        id: root
        anchors.fill: parent

        property url src: "lol.jpg"

        property var points: []
        property int pointRadius: 6

        readonly property int drawnWidth: img.paintedWidth
        readonly property int drawnHeight: img.paintedHeight
        readonly property int xshift: (img.width - img.paintedWidth) / 2
        readonly property int yshift: (img.height - img.paintedHeight) / 2
        property double scale: 1.0
        property double maxScale: 4.0

        property bool createMode: true

        Rectangle {
            anchors.fill: parent
            color: "white"
            border.color: "black"
            border.width: 1
            opacity: 0.25
        }

        Flickable {
            id: flickable
            anchors.fill: parent

            contentWidth: img.width
            contentHeight: img.height
            interactive: mouseArea.dragInfo.pointIdx < 0
            boundsBehavior: Flickable.StopAtBounds

            Image {
                id: img
                source: root.src
                width: root.width * root.scale
                height: root.height * root.scale
                fillMode: Image.PreserveAspectFit
                onSourceChanged: root.scale = 1

                Item {
                    anchors {
                        fill: parent
                        topMargin: root.yshift
                        bottomMargin: root.yshift
                        leftMargin: root.xshift
                        rightMargin: root.xshift
                    }

                    Repeater {
                        id: drawnPoints
                        model: root.points
                        property int hoveredItem: -1 

                        Rectangle {
                            x: modelData.x * root.drawnWidth - 1
                            y: modelData.y * root.drawnHeight - 1
                            width: root.pointRadius * 2
                            height: root.pointRadius * 2
                            radius: root.pointRadius
                            color: drawnPoints.hoveredItem == index ? "green" : "red"
                        }
                    }
                }
            }


            MouseArea {
                id: mouseArea

                // info about dragged point and offsets from box topLeft to drag point
                property var dragInfo: {
                    pointIdx: -1
                    shiftX: 0
                    shiftY: 0
                }

                anchors {
                    fill: img
                    topMargin: root.yshift
                    bottomMargin: root.yshift
                    leftMargin: root.xshift
                    rightMargin: root.xshift
                }
                hoverEnabled: true

                Rectangle {  // horizontal line through pointer
                    id: horLine
                    visible: true

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    y: parent.mouseY
                    height: 1

                    color: "black"
                }

                Rectangle { // vertical line through pointer
                    id: verLine
                    visible: true

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }

                    x: parent.mouseX
                    width: 1

                    color: "black"
                }

                onPositionChanged: {
                    var X_ = bounded(mouse.x, 0, width)
                    var Y_ = bounded(mouse.y, 0, height)
                    var X = X_ / root.drawnWidth
                    var Y = Y_ / root.drawnHeight

                    var hoverInfo = inPoint(X, Y)
                    if (hoverInfo.pointIdx >= 0) {
                        drawnPoints.hoveredItem = hoverInfo.pointIdx
                    } else {
                        drawnPoints.hoveredItem = -1
                    }
                }

                onPressed: {
                    var X_ = bounded(mouse.x, 0, width)
                    var Y_ = bounded(mouse.y, 0, height)
                    var X = X_ / root.drawnWidth
                    var Y = Y_ / root.drawnHeight

                    if (root.createMode) {
                        var newPoint = {x: X, y: Y}
                        root.points.push(newPoint)
                        updatePoints()
                    } else {
                        var dragInfo = inPoint(X, Y)
                    }
                } 
            }

        } // Flickable

        MouseArea {

            id: mouseAreaZoom

            anchors.fill: flickable
            acceptedButtons: Qt.NoButton

            cursorShape: mouseArea.cursorShape

            onWheel: {
                var xmove = 0
                var ymove = 0
                var newScale = root.scale
                var mx = 0, my = 0

                if(wheel.angleDelta.y > 2) {
                    if(root.scale == root.maxScale)
                        return
                    newScale = root.scale * 1.1
                    mx = wheel.x
                    my = wheel.y
                } else if (wheel.angleDelta.y < -2) {
                    if(root.scale == 1)
                        return
                    newScale = root.scale / 1.1
                    mx = width / 2
                    my = height / 2
                } else {
                    return
                }

                var xold = (mx + flickable.contentX)
                var xnorm = xold / img.width
                var yold = (my + flickable.contentY)
                var ynorm = yold / img.height

                root.scale = bounded(newScale, 1, root.maxScale)

                var xnew = xnorm * img.width
                var ynew = ynorm * img.height

                xmove = xnew - xold
                ymove = ynew - yold

                flickable.contentX += xmove
                flickable.contentY += ymove
                flickable.returnToBounds()
            }
        }
    }

    function inPoint(X, Y) {
        var pw = 2.0 * root.pointRadius / root.drawnWidth
        var ph = 2.0 * root.pointRadius / root.drawnHeight

        for(var i = root.points.length-1; i >= 0; --i) {
            var p = root.points[i]
            if(X >= p.x && X <= (p.x + pw) && Y >= p.y && Y <= (p.y + ph)) {
                var shiftX = X - p.x
                var shiftY = Y - p.y
                return {
                    pointIdx: i,
                    shiftX: shiftX,
                    shiftY: shiftY
                }
            }
        }

        return {
            pointIdx: -1,
            shiftX: 0,
            shiftY: 0
        }

    }

    function bounded(val, min, max) {
        return Math.max(Math.min(val, max), min)
    }

    function updatePoints() {
        root.points = root.points
    }

}