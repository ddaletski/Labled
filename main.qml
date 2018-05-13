import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "qml"


ApplicationWindow {
    id: root
    visible: true
    width: 1024
    height: 720
    minimumWidth: 640
    minimumHeight: 480
    title: qsTr("Labled")

    property string inputDir: ""
    property string outputDir: ""
    property var labelsList: []
    property alias defaultLabel: sideMenu.defaultLabel
    property url currentImage
    property bool unsavedChanges: false


    /***************** signals ***************/

    signal sigNextImage(int step)
    signal sigLoadImages(url imagesDir, url labelsDir)
    signal sigSaveImage(var rects)


    function nextImage(step) {
        if(unsavedChanges) {
            unsavedChangesDialog.step = step
            unsavedChangesDialog.mode = "next"
            unsavedChangesDialog.open()
        } else {
            sigNextImage(step)
        }
    }


    function loadImages() {
        currentImage = ""
        imageArea.rects = []
        sigLoadImages(root.inputDir, root.outputDir)
    }


    function saveImage() {
        unsavedChanges = false

        if (imageArea.src == '')
            return

        var savedRects = []
        for(var i in imageArea.rects) {
            var r = imageArea.rects[i]
            try {
                var newRect = {
                    x: r.origX,
                    y: r.origY,
                    width: r.origWidth,
                    height: r.origHeight,
                    label: labelsList[r.label].name
                }
                savedRects.push(newRect)
            } catch (e) { }
        }

        sigSaveImage(savedRects)
    }

    /***************** slots ***************/

    function imagesLoaded() {
        sigNextImage(0)
    }

    function nextImageLoaded(imageUrl, boxes)  {
        imageArea.rects = []

        currentImage = imageUrl

        var xs = imageArea.xscale
        var ys = imageArea.yscale

        for(var i in boxes) {
            var box = boxes[i]
            imageArea.rects.push( imageArea.rectItemFromOrig(box.x, box.y, box.width, box.height, addLabel(box.label)) )
        }

        imageArea.updateRects()
    }

    ///////////////////////////////////////////


    CropTool {
        id: cropTool
        //Component.onCompleted: open()
    }


    FileChooseDialog {
        id: indirDialog

        onAccepted: {
            mainItem.focus = true
            root.inputDir = fileUrl
            if(root.outputDir == "")
                root.outputDir = root.inputDir

            root.loadImages()
        }

        onRejected: {
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: outdirDialog

        onAccepted: {
            mainItem.focus = true
            root.outputDir = fileUrl

            root.loadImages()
        }

        onRejected: {
            mainItem.focus = true
        }
    }


    LabelChooseDialog {
        id: labelDialog
        labelsList: root.labelsList

        onAccepted: {
            if(label.length) {
                var labelIdx = addLabel(label)
                imageArea.updateLabel(labelIdx)
            } else {
                open()
            }

            mainItem.focus = true
        }

        onRejected: {
            mainItem.focus = true
            if(imageArea.lastRect.label < 0)
                imageArea.deleteActiveRect()

            mainItem.focus = true
        }
    }


    UnsavedChangesDialog {
        id: unsavedChangesDialog

        onAccepted: {
            unsavedChanges = false
            sigNextImage(step)
            mainItem.focus = true
        }

        onRejected: {
            mainItem.focus = true
        }
    }


    Item {
        id: mainItem
        anchors.fill: parent
        focus: true

        RowLayout {
            anchors.fill: parent
            ImageDraw {
                id: imageArea

                src: root.currentImage
                labelsList: root.labelsList

                darkBoxes: sideMenu.darkBoxes
                showLabels: sideMenu.showLabels
                labelsSize: sideMenu.labelsSize

                Layout.fillWidth: true
                Layout.fillHeight: true
                rectBorderWidth: 2

                onRectAdded: {
                    if(defaultLabel < 0) {
                        labelDialog.label = ""
                        labelDialog.open()
                    } else {
                        imageArea.updateLabel(defaultLabel)
                    }
                }

                onUnsavedChanges: {
                    root.unsavedChanges = true
                }
            }

            VerticalLine {
                width: 1
                lineWidth: 1
                Layout.fillHeight: true
            }

            SideMenu {
                id: sideMenu
                width: 200
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                labelsList: root.labelsList

                onUnsavedChanges: root.unsavedChanges = true
                onUpdateLabels: root.updateLabels()
            }
        }

        Keys.onSpacePressed: {
            imageArea.isSelection = 1 - imageArea.isSelection
        }

        Keys.onEscapePressed: {
            imageArea.isSelection = false
        }

        Keys.onTabPressed: {
            imageArea.shiftRects()
            imageArea.updateRects()
        }

        Keys.onPressed: {
            switch(event.key) {
            case Qt.Key_Q:
                imageArea.deleteActiveRect()
                imageArea.updateRects()
                break
            case Qt.Key_E:
                if (imageArea.rects.length) {
                    labelDialog.label = imageArea.lastRect.label >= 0 ? root.labelsList[imageArea.lastRect.label].name : ""
                    labelDialog.open()
                }
                break
            case Qt.Key_W:
                imageArea.isSelection = 1 - imageArea.isSelection
                break
            case Qt.Key_S:
                root.saveImage()
                break
            case Qt.Key_D:
                root.nextImage(1)
                break
            case Qt.Key_A:
                root.nextImage(-1)
                break
            case Qt.Key_Z:
                unsavedChangesDialog.step = 0
                unsavedChangesDialog.mode = "undo"
                unsavedChangesDialog.open()
                break
            }
        }

    } // mainItem


    function addLabel(label) {
        for(var i in labelsList) {
            if(label == labelsList[i].name)
                return i
        }
        labelsList.push({name: label, color: 'red'})
        updateLabels()
        return labelsList.length - 1
    }

    function updateLabels() {
        labelsList = labelsList
    }

    function bounded(val, min, max) {
        return Math.max(Math.min(val, max), min)
    }

} // window
