import QtQuick 2.5
import "../common"

Item {
    id: root
    property url src: ""
    property bool isSelection: false  // is selection in progress (new bar creation)

    property bool showLabels: true
    property int labelsSize: 8
    property int rectBorderWidth: 1
    property int boxesFillMode: 0  // 0 - auto, 1 - dark, 2 - white

    property var rects: []
    property var lastRect: rects[rects.length-1]
    property var labelsList: []

    readonly property int xshift: (img.width - img.paintedWidth) / 2
    readonly property int yshift: (img.height - img.paintedHeight) / 2
    readonly property int drawnWidth: img.paintedWidth
    readonly property int drawnHeight: img.paintedHeight
    property double scale: 1.0
    property double maxScale: 4.0

    signal rectAdded()
    signal unsavedChanges()

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
        interactive: !mouseArea.create && mouseArea.dragInfo.rectIdx < 0 && mouseArea.resizeInfo.rectIdx < 0
        boundsBehavior: Flickable.StopAtBounds

        Image {
            id: img
            source: root.src
            width: root.width * root.scale
            height: root.height * root.scale
            fillMode: Image.PreserveAspectFit
            onSourceChanged: root.scale = 1

            Item {
                id: drawnRectsItem
                anchors {
                    fill: parent
                    topMargin: yshift
                    bottomMargin: yshift
                    leftMargin: xshift
                    rightMargin: xshift
                }
                Repeater {
                    id: drawnRects
                    model: root.rects

                    RectBoxItem { // object bounding box
                        showLabel: root.showLabels
                        textSize: root.labelsSize
                        _x: modelData.x * drawnWidth
                        _y: modelData.y * drawnHeight
                        _width: modelData.width * drawnWidth
                        _height: modelData.height * drawnHeight
                        xmax: drawnRectsItem.width
                        ymax: drawnRectsItem.height

                        label: modelData.label >= 0 ? labelsList[modelData.label].name : ""

                        borderColor: modelData.label >= 0 ? labelsList[modelData.label].color : "red"
                        borderOpacity: index == root.rects.length - 1 ? 0.9 : 0.8
                        borderWidth: {
                            var w = root.rectBorderWidth
                            index == root.rects.length - 1 ? w + 1 : w
                        }
                        fillOpacity: 0.2

                        fillColor: {
                            switch(boxesFillMode) {
                            case 0:
                                borderColor
                                break
                            case 1:
                                "white"
                                break
                            case 2:
                                "black"
                                break
                            }
                        }
                        textBgColor: {
                            switch(boxesFillMode) {
                            case 0:
                                Backend.subRgba(borderColor, Qt.rgba(0, 0, 0, 0.3))
                                break
                            case 1:
                                Qt.rgba(1, 1, 1, 0.5)
                                break
                            case 2:
                                Qt.rgba(0, 0, 0, 0.5)
                                break
                            }
                        }

                        textColor: {
                            switch(boxesFillMode) {
                            case 0:
                                Backend.invertColor(borderColor)
                                break
                            case 1:
                                "black"
                                break
                            case 2:
                                "white"
                                break
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
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
                var X_ = bounded(mouse.x, 0, width)
                var Y_ = bounded(mouse.y, 0, height)
                var X = X_ / drawnWidth
                var Y = Y_ / drawnHeight

                if(root.isSelection) {
                    create = true
                    var r = rectItem(X, Y, 0, 0, -1)
                    root.rects.push(r)
                } else {
                    resizeInfo = root.onEdge(X, Y)
                    dragInfo = root.inRect(X, Y)

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

                    if (newRect.width * newRect.height * drawnHeight * drawnWidth < 16) {
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
                var X_ = bounded(mouse.x, 0, width)
                var Y_ = bounded(mouse.y, 0, height)

                var X = X_ / drawnWidth
                var Y = Y_ / drawnHeight

                horLine.x = X_
                verLine.y = Y_


                var rectObj = drawnRects.itemAt(0)

                if (create) {
                    var altX = false // pointer is left to selection start point
                    var altY = false //  pointer is above selection start point
                    var objRect = root.rects[root.rects.length-1]

                    if(objRect.baseX > X)
                        altX = true
                    if(objRect.baseY > Y)
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

                    updateRects()
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

                    updateRects()
                    unsavedChanges()
                } else if (dragInfo.rectIdx >= 0) {

                    var idx = dragInfo.rectIdx
                    var rect = root.rects[dragInfo.rectIdx]

                    rect.x = bounded(X - dragInfo.shiftX, 0, 1-rect.width)
                    rect.y = bounded(Y - dragInfo.shiftY, 0, 1-rect.height)

                    updateRects()
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
    } // Flickable

    MouseArea {
        anchors.fill: flickable
        acceptedButtons: Qt.NoButton
        onWheel: {
            var xmove = 0
            var ymove = 0
            var newScale = root.scale
            console.log(wheel.angleDelta)
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
        var delta = 4 / (drawnWidth + drawnHeight)

        var resizeInfo = {
            rectIdx: -1,
            ver: 0,
            hor: 0
        }

        var found = false
        for (var i = rects.length - 1; i >= 0 && !found; --i) {
            var r = rects[i]

            if(Y >= r.y - delta && Y <= r.y + r.height + delta) {
                if(Math.abs(X - r.x) <= delta) {
                    resizeInfo.ver = -1
                    resizeInfo.rectIdx = i
                    found = true
                } else if (Math.abs(X - (r.x + r.width)) <= delta) {
                    resizeInfo.ver = 1
                    resizeInfo.rectIdx = i
                    found = true
                }
            }

            if(X >= r.x - delta && X <= r.x + r.width + delta) {
                if(Math.abs(Y - r.y) <= delta) {
                    resizeInfo.hor = -1
                    resizeInfo.rectIdx = i
                    found = true
                } else if (Math.abs(Y - (r.y + r.height)) <= delta) {
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


    function rectItem (x, y, width, height, label) {
        var rect = {
            x: x,
            y: y,
            baseX: x,
            baseY: y,
            width: width,
            height: height,
            label: label
        }

        return rect
    }


    function scaleRect(rect, xscale, yscale) {
        rect.x *= xscale
        rect.y *= yscale
        rect.width *= xscale
        rect.height *= yscale
        rect.baseX *= xscale
        rect.baseY *= yscale
    }
}
