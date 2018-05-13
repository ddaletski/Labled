import QtQuick 2.7

Item {
    id: root
    property url src: ""
    property bool isSelection: false  // is selection in progress (new bar creation)

    property bool showLabels: true
    property var labelsSize: 8
    property int rectBorderWidth: 1
    property bool darkBoxes: false

    property var rects: []
    property var lastRect: rects[rects.length-1]
    property var labelsList: []

    readonly property double xscale: img.paintedWidth / img.sourceSize.width
    readonly property double yscale: img.paintedHeight / img.sourceSize.height
    readonly property int xshift: (img.width - img.paintedWidth) / 2
    readonly property int yshift: (img.height - img.paintedHeight) / 2

    signal rectAdded()
    signal unsavedChanges()

    onHeightChanged: {
        recalculateRectsScaled()
    }

    onWidthChanged: {
        recalculateRectsScaled()
    }

    Image {
        id: img
        source: root.src
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit

        Repeater {
            id: drawnRects
            model: root.rects

            RectBoxItem { // object bounding box
                showLabel: root.showLabels
                textSize: root.labelsSize
                _x: modelData.x + xshift
                _y: modelData.y + yshift
                _width: modelData.width
                _height: modelData.height
                xmax: img.width
                ymax: img.height

                label: modelData.label >= 0 ? labelsList[modelData.label].name : ""
                borderColor: modelData.label >= 0 ? labelsList[modelData.label].color : "red"
                borderWidth: root.rectBorderWidth
                fillColor: {
                    var col = darkBoxes ? 0 : 1
                    if(index == root.rects.length-1) {
                        Qt.rgba(1 - col, col, col, 0.4)
                    } else {
                        Qt.rgba(col, col, col, 0.2)
                    }
                }
                textBgColor: {
                    var col = darkBoxes ? 0 : 1
                    Qt.rgba(col, col, col, 0.7)
                }

                textColor: darkBoxes ? "white" : "black"
            }
        }
    }

    MouseArea {
        property bool create: false

        // info about dragged box and offsets from box topLeft to drag point
        property var dragInfo: {
            rectIdx: -1
            shiftX: 0
            shiftY: 0
        }

        // info about resized box and currently resized edge
        property var resizeInfo: {
            rectIdx: -1
            ver: 0  // -1 is left, 1 is right
            hor: 0  // -1 is top, 1 is bottom
        }

        anchors {
            fill: img
            topMargin: yshift
            bottomMargin: yshift
            leftMargin: xshift
            rightMargin: xshift
        }
        hoverEnabled: true

        Rectangle {  // horizontal line through pointer
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

        Rectangle { // vertical line through pointer
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
            root.focus = true

            if(root.isSelection) {
                create = true
                var r = rectItemFromScaled(mouse.x, mouse.y, 0, 0, -1)
                root.rects.push(r)
            } else {
                resizeInfo = root.onEdge(mouse.x, mouse.y)
                dragInfo = root.inRect(mouse.x, mouse.y)

                if (resizeInfo.rectIdx >= 0) {
                    //                    moveRectToBack(resizeInfo.rectIdx) // resized rect is drawn on top of the others
                    //                    resizeInfo.rectIdx = root.rects.length - 1
                } else if (dragInfo.rectIdx >= 0) {
                    moveRectToBack(dragInfo.rectIdx) // dragged rect is drawn on top of the others
                    dragInfo.rectIdx = root.rects.length - 1
                }
            }
            update(mouse)
        }

        onReleased: {
            if(root.isSelection) {
                create = false
                isSelection = false
                var newRect = root.rects[root.rects.length-1]

                if (newRect.width * newRect.height < 16) {
                    root.rects.pop()
                    updateRects()
                } else {
                    root.rectAdded()  // signal about new rect
                    unsavedChanges()
                }
            } else {
                resizeInfo.rectIdx = -1
                dragInfo.rectIdx = -1
            }
        }

        onPositionChanged: {
            update(mouse)
        }


        function update(mouse) {
            var X = bounded(mouse.x, 0, width)
            var Y = bounded(mouse.y, 0, height)

            horLine.x = X
            verLine.y = Y

            if (create) {
                var altX = false // pointer is left to selection start point
                var altY = false //  pointer is above selection start point
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

                recalculateRectsOriginal()
                unsavedChanges()
            } else if (resizeInfo.rectIdx >= 0) {
                var rect = root.rects[resizeInfo.rectIdx]
                var h = resizeInfo.hor
                var v = resizeInfo.ver

                if (v == -1) {
                    rect.width -= (X - rect.x)
                    rect.x = X
                } else if (v == 1) {
                    rect.width = X - rect.x
                }

                if (h == -1) {
                    rect.height -= (Y - rect.y)
                    rect.y = Y
                } else if (h == 1) {
                    rect.height = Y - rect.y
                }

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

                recalculateRectsOriginal()
                unsavedChanges()
            } else if (dragInfo.rectIdx >= 0) {

                var idx = dragInfo.rectIdx
                var rect = root.rects[dragInfo.rectIdx]

                rect.x = bounded(X - dragInfo.shiftX, 0, width-rect.width)
                rect.y = bounded(Y - dragInfo.shiftY, 0, height-rect.height)

                recalculateRectsOriginal()
                unsavedChanges()
            } else {
                // set cursor according to available action

                if(isSelection) {
                    cursorShape = Qt.ArrowCursor
                    return
                }

                var dinfo = inRect(X, Y)
                var rinfo = onEdge(X, Y)

                if (rinfo.rectIdx >= 0) {
                    if (rinfo.hor && rinfo.ver)
                        cursorShape = Qt.SizeAllCursor
                    else if (rinfo.hor)
                        cursorShape = Qt.SizeVerCursor
                    else
                        cursorShape = Qt.SizeHorCursor
                } else if (dinfo.rectIdx >= 0) {
                    cursorShape = Qt.DragMoveCursor
                } else {
                    cursorShape = Qt.ArrowCursor
                }
            }
        }
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
        if(rects.length <= 1)
            return

        var rect = rects[idx]
        for (var i = idx; i < rects.length-1; ++i) {
            rects[i] = rects[i+1]
        }
        rects[rects.length-1] = rect
    }


    function shiftRects() {
        if(rects.length <= 1)
            return

        rects.unshift(rects.pop())
    }


    function onEdge(X, Y) {
        var resizeInfo = {
            rectIdx: -1,
            ver: 0,
            hor: 0
        }

        var found = false
        for (var i = rects.length - 1; i >= 0 && !found; --i) {
            var r = rects[i]

            if(Y >= r.y - 2 && Y <= r.y + r.height + 2) {
                if(Math.abs(X - r.x) <= 2) {
                    resizeInfo.ver = -1
                    resizeInfo.rectIdx = i
                    found = true
                } else if (Math.abs(X - (r.x + r.width)) <= 2) {
                    resizeInfo.ver = 1
                    resizeInfo.rectIdx = i
                    found = true
                }
            }

            if(X >= r.x - 2 && X <= r.x + r.width + 2) {
                if(Math.abs(Y - r.y) <= 2) {
                    resizeInfo.hor = -1
                    resizeInfo.rectIdx = i
                    found = true
                } else if (Math.abs(Y - (r.y + r.height)) <= 2) {
                    resizeInfo.hor = 1
                    resizeInfo.rectIdx = i
                    found = true
                }
            }
        }

        return resizeInfo
    }

    function updateRects () {
        rects = rects
    }

    function updateLabel(label) {
        if (rects.length)
            rects[rects.length - 1].label = label
        updateRects()
        unsavedChanges()
    }

    function bounded(val, min, max) {
        return Math.max(Math.min(val, max), min)
    }

    function deleteActiveRect() {
        rects.pop()
        updateRects()
        unsavedChanges()
    }


    function rectItemFromOrig (x, y, width, height, label) {
        var rect = {
            x: 0,
            y: 0,
            baseX: 0,
            baseY: 0,
            width: 0,
            height: 0,
            origX: x,
            origY: y,
            origWidth: width,
            origHeight: height,
            label: label
        }

        updateRectScaledComponent(rect)
        return rect
    }


    function rectItemFromScaled (x, y, width, height, label) {
        var rect = {
            x: x,
            y: y,
            baseX: x,
            baseY: y,
            width: width,
            height: height,
            origX: 0,
            origY: 0,
            origWidth: 0,
            origHeight: 0,
            label: label
        }

        updateRectOrigComponent(rect)
        return rect
    }


    function scaleRect(rect, xscale, yscale) {
        rect.x *= xscale
        rect.y *= yscale
        rect.width *= xscale
        rect.height *= yscale
        rect.baseX *= xscale
        rect.baseY *= yscale
        updateRectOrigComponent(rect)
    }

    function recalculateRectsOriginal() {
        for (var i in rects) {
            updateRectOrigComponent(rects[i])
        }

        updateRects()
    }

    function recalculateRectsScaled() {
        for (var i in rects) {
            updateRectScaledComponent(rects[i])
        }

        updateRects()
    }

    function updateRectOrigComponent(rect) {
        // updates original coordinates after rect resizing
        rect.origX = rect.x / xscale
        rect.origY = rect.y / yscale
        rect.origWidth = rect.width / xscale
        rect.origHeight = rect.height / yscale
    }

    function updateRectScaledComponent(rect) {
        // updates visual (scaled to screen) coords after screen resizing
        rect.x = rect.origX * xscale
        rect.y = rect.origY * yscale
        rect.baseX = rect.origX * xscale
        rect.baseY = rect.origY * yscale
        rect.width = rect.origWidth * xscale
        rect.height = rect.origHeight * yscale
    }
}
