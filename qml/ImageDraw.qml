import QtQuick 2.0

Item {
    id: root
    property url src: ""
    property bool isSelection: false
    property var rects: []

    signal rectAdded(var rect)

    Image {
        id: img
        anchors.fill: parent
        source: root.src

        Repeater {
            id: drawnRects
            model: root.rects
            Item {
                Rectangle {
                    id: drawnRect
                    border.color: modelData.borderColor
                    color: modelData.fillColor
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
        }
    }

    MouseArea {
        property bool create: false

        property var dragInfo: {
            rectIdx: -1
            shiftX: 0
            shiftY: 0
        }

        property var resizeInfo: {
            rectIdx: -1
            ver: 0  // -1 is left, 1 is right
            hor: 0  // -1 is top, 1 is bottom
        }

        anchors.fill: parent
        hoverEnabled: true

        Rectangle {
            id: horLine
            visible: root.isSelection && !parent.create

            anchors {
                left: parent.left
                right: parent.right
            }

            y: parent.mouseY
            height: 1

            color: "black"
        }

        Rectangle {
            id: verLine
            visible: root.isSelection && !parent.create

            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            x: parent.mouseX
            width: 1

            color: "black"
        }

        onPressed: {
            if(root.isSelection) {
                create = true
                var r = rectItem(mouse.x, mouse.y, 0, 0, '', 'red', Qt.rgba(0.05, 0.05, 0.5, 0.2))
                root.rects.push(r)
            } else {
                resizeInfo = root.onEdge(mouse.x, mouse.y)

                dragInfo = root.inRect(mouse.x, mouse.y)
                if (dragInfo.rectIdx >= 0) {
                    moveRectToBack(dragInfo.rectIdx) // dragged rect is drawn on top of the others
                    dragInfo.rectIdx = root.rects.length - 1
                }
            }
        }

        onReleased: {
            if(root.isSelection) {
                create = false
                isSelection = false
                root.rectAdded(root.rects[root.rects.length-1])
            } else {
                resizeInfo.rectIdx = -1
                dragInfo.rectIdx = -1
                console.log("stop drag")
            }
        }

        onPositionChanged: {
            var X = bounded(mouse.x, 0, width)
            var Y = bounded(mouse.y, 0, height)

            horLine.x = X
            verLine.y = Y

            if (resizeInfo.rectIdx >= 0) {
                var rect = root.rects[resizeInfo.rectIdx]
                var h = resizeInfo.hor
                var v = resizeInfo.ver

                if (v == -1) {
                    rect.width -= (X - rect.x)
                    rect.x = X
                    console.log("left")
                } else if (v == 1) {
                    rect.width = X - rect.x
                    console.log("right")
                    console.log(rect.width)
                }

                if (h == -1) {
                    rect.height -= (Y - rect.y)
                    rect.y = Y
                    console.log("top")
                } else if (h == 1) {
                    rect.height = Y - rect.y
                    console.log("bottom")
                    console.log(rect.height)
                }

                console.log(rect.width, rect.height)
                if (rect.width < 0) {
                    rect.x += rect.width
                    rect.width *= -1
                    resizeInfo.ver *= -1
                }

                if (rect.height < 0) {
                    rect.y += rect.height
                    rect.height *= -1
                    resizeInfo.hor *= -1
                }

                updateRects()

            } else if (dragInfo.rectIdx >= 0) {

                console.log("drag move")
                var idx = dragInfo.rectIdx
                var rect = root.rects[dragInfo.rectIdx]

                rect.x = bounded(X - dragInfo.shiftX, 0, width-rect.width)
                rect.y = bounded(Y - dragInfo.shiftY, 0, height-rect.height)

                root.updateRects()

            } else if (create) {

                var altX = false
                var altY = false
                var objRect = root.rects[root.rects.length-1]

                if(objRect.baseX > mouse.x)
                    altX = true
                if(objRect.baseY > mouse.y)
                    altY = true

                if(altX) {
                    objRect.x = X
                    objRect.width = objRect.baseX - X
                } else {
                    objRect.width = X - objRect.x
                    objRect.x = objRect.baseX
                }

                if(altY) {
                    objRect.y = Y
                    objRect.height = objRect.baseY - Y
                } else {
                    objRect.height = Y - objRect.y
                    objRect.y = objRect.baseY
                }

                root.updateRects()
            } else {
                // set cursor according to position

                var dinfo = inRect(X, Y)
                var rinfo = onEdge(X, Y)

                if (dinfo.rectIdx >= 0) {
                    cursorShape = Qt.DragMoveCursor
                } else if (rinfo.rectIdx >= 0) {
                    if (rinfo.hor && rinfo.ver)
                        cursorShape = Qt.SizeAllCursor
                    else if (rinfo.hor)
                        cursorShape = Qt.SizeVerCursor
                    else
                        cursorShape = Qt.SizeHorCursor
                } else {
                    cursorShape = Qt.ArrowCursor
                }
            }
        }
    }

   function rectItem (x, y, width, height, label, borderColor, fillColor) {
       var rect = {
           x: x,
           y: y,
           baseX: x,
           baseY: y,
           width: width,
           height: height,
           label: label,
           borderColor: borderColor,
           fillColor: fillColor
       }
       return rect
    }


   function inRect(X, Y) {
       for(var i = rects.length-1; i >= 0; --i) {
           var r = rects[i]
           if(X >= r.x && X <= (r.x + r.width) && Y >= r.y && Y <= (r.y + r.height)) {
               var shiftX = X - r.x
               var shiftY = Y - r.y
               return {
                   rectIdx: i,
                   shiftX: shiftX,
                   shiftY: shiftY
               }
           }
       }
       return {
           rectIdx: -1,
           shiftX: 0,
           shiftY: 0
       }
   }


   function moveRectToBack(idx) {
       var rect = rects[idx]
       for (var i = idx; i < rects.length-1; ++i) {
           rects[i] = rects[i+1]
       }
       rects[rects.length-1] = rect
   }


   function onEdge(X, Y) {
       var resizeInfo = {
           rectIdx: -1,
           ver: 0,
           hor: 0
       }

       for (var i in rects) {
           var r = rects[i]

           if(Y >= r.y - 2 && Y <= r.y + r.height + 2) {
               if(Math.abs(X - r.x) <= 2) {
                   resizeInfo.ver = -1
                   resizeInfo.rectIdx = i
               } else if (Math.abs(X - (r.x + r.width)) <= 2) {
                   resizeInfo.ver = 1
                   resizeInfo.rectIdx = i
               }
           }

           if(X >= r.x - 2 && X <= r.x + r.width + 2) {
               if(Math.abs(Y - r.y) <= 2) {
                   resizeInfo.hor = -1
                   resizeInfo.rectIdx = i
               } else if (Math.abs(Y - (r.y + r.height)) <= 2) {
                   resizeInfo.hor = 1
                   resizeInfo.rectIdx = i
               }
           }
       }

       return resizeInfo
   }

   function updateRects () {
       rects = rects
   }

   function bounded(val, min, max) {
       return Math.max(Math.min(val, max), min)
   }
}
