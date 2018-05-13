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

    property string imagesDir: ""
    property string annotationsDir: ""
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
        sigLoadImages(root.imagesDir, root.annotationsDir)
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


    FileChooseDialog {
        id: indirDialog

        onAccepted: {
            mainItem.focus = true
            root.imagesDir = fileUrl
            if(root.annotationsDir == "")
                root.annotationsDir = root.imagesDir

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
            root.annotationsDir = fileUrl

            root.loadImages()
        }

        onRejected: {
            mainItem.focus = true
        }
    }


    LabelChooseDialog {
        id: labelDialog
        labelsList: root.labelsList
        enableShortcuts: sideMenu.enableLabelsShortcuts

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

    CropTool {
        id: cropTool
        objectName: "cropTool"

        inputDir: root.imagesDir
        annotationsDir: root.annotationsDir
    }


    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem {
                text: "Choose input directory"
                shortcut: "I"
                onTriggered: {
                    indirDialog.setFolder(root.imagesDir)
                    indirDialog.open()
                }
            }
            MenuItem {
                text: "Choose output directory"
                shortcut: "O"
                onTriggered: {
                    outdirDialog.setFolder(root.annotationsDir)
                    outdirDialog.open()
                }
            }
            MenuSeparator { }
            MenuItem {
                text: qsTr("Save labeling for current image")
                shortcut: "S"
                onTriggered: root.saveImage()
            }
            MenuItem {
                text: qsTr("Load next image")
                shortcut: "D"
                onTriggered: root.nextImage(1)
            }
            MenuItem {
                text: qsTr("Load previous image")
                shortcut: "A"
                onTriggered: root.nextImage(-1)
            }
        }
        Menu {
            title: "Edit"
            MenuItem {
                text: qsTr("Add new box")
                shortcut: "W"
                onTriggered: {
                    imageArea.isSelection = 1 - imageArea.isSelection
                }
            }
            MenuItem {
                text: qsTr("Delete active box")
                shortcut: "Q"
                onTriggered: {
                    imageArea.deleteActiveRect()
                    imageArea.updateRects()
                }
            }
            MenuItem {
                text: qsTr("Edit current box's label")
                shortcut: "E"
                onTriggered: {
                    if (imageArea.rects.length) {
                        labelDialog.label = imageArea.lastRect.label >= 0 ? root.labelsList[imageArea.lastRect.label].name : ""
                        labelDialog.open()
                    }
                }
            }
            MenuItem {
                text: qsTr("Undo all changes")
                shortcut: "Z"
                onTriggered: {
                    unsavedChangesDialog.step = 0
                    unsavedChangesDialog.mode = "undo"
                    unsavedChangesDialog.open()
                }
            }
        }

        Menu {
            title: qsTr("Tools")

            MenuItem {
                text: qsTr("Cut images from boxes")
                onTriggered: {
                    cropTool.open()
                }
            }
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

        Keys.onEscapePressed: {
            imageArea.isSelection = false
        }

        Keys.onTabPressed: {
            imageArea.shiftRects()
            imageArea.updateRects()
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
