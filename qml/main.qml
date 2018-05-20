import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import "common"
import "drawArea"
import "sideMenu"
import "mainWindow"

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
    property int imagesCount: 0
    property var labelsList: []
    property alias defaultLabel: sideMenu.defaultLabel
    property string currentImage
    property string currentLabel
    property int currentImageIdx: 0
    property bool unsavedChanges: false

    function nextImage(step) {
        if(unsavedChanges) {
            unsavedChangesDialog.step = step
            unsavedChangesDialog.mode = "next"
            unsavedChangesDialog.open()
        } else {
            var annotation = Backend.next(step)

            try {
                var imageUrl = annotation['imgPath']
                var labelUrl = annotation['lblPath']
                var boxes = annotation['boxes']

                imageArea.rects = []

                currentImage = imageUrl
                currentLabel = labelUrl

                for(var i in boxes) {
                    var box = boxes[i]
                    imageArea.rects.push( imageArea.rectItem(box.x, box.y, box.width, box.height, addLabel(box.label)) )
                }

                imageArea.updateRects()
            } catch (e) {
            }
        }
        currentImageIdx = Backend.currentIdx()
        imagesSlider.value = currentImageIdx
    }


    function loadImages() {
        currentImage = ""
        imageArea.rects = []
        Backend.loadImages(root.imagesDir, root.annotationsDir)
        imagesCount = Backend.imagesCount()
        nextImage(0)
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
                    x: r.x,
                    y: r.y,
                    width: r.width,
                    height: r.height,
                    label: labelsList[r.label].name
                }
                savedRects.push(newRect)
            } catch (e) { }
        }

        var result = {
            imgPath: currentImage,
            lblPath: currentLabel,
            boxes: savedRects
        }

        Backend.save(result)
    }


    FileChooseDialog {
        id: indirDialog

        onAccepted: {
            mainItem.focus = true
            root.imagesDir = filePath()
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
            root.annotationsDir = filePath()

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
            nextImage(step)
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


    ConvertTool {
        id: convertTool
        objectName: "convertTool"

        inputDir: root.annotationsDir
        outputDir: root.annotationsDir
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

            MenuItem {
                text: qsTr("Convert labels")
                onTriggered: {
                    convertTool.open()
                }
            }
        }
    }

    statusBar: StatusBar {
        Label {
            anchors.fill: parent
            text: root.currentImage
        }
    }

    Item {
        id: mainItem
        anchors.fill: parent
        focus: true

        RowLayout {
            anchors.fill: parent
            spacing: 0

            ColumnLayout {
                spacing: 0
                ImageDraw {
                    id: imageArea

                    src: "file:" + root.currentImage
                    labelsList: root.labelsList

                    showLabels: sideMenu.showLabels
                    labelsSize: sideMenu.labelsSize

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    rectBorderWidth: 2
                    boxesFillMode: sideMenu.boxesFillMode

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

                Rectangle {
                    Layout.fillWidth: true
                    height: childrenRect.height
                    Slider {
                        id: imagesSlider
                        width: parent.width

                        minimumValue: 0
                        maximumValue: Math.max(imagesCount-1, 0)
                        stepSize: 1
                        onValueChanged: {
                            if(value < 0)
                                return
                            if(root.currentImageIdx != value) {
                                var diff = value - root.currentImageIdx
                                root.currentImageIdx = value
                                nextImage(diff)
                            }
                        }
                    }
                }
            }

            VerticalLine {
                width: 11
                lineWidth: 1
                Layout.fillHeight: true
            }


            Rectangle {
                Layout.fillHeight: true
                width: childrenRect.width + 8
                color: "white"

                SideMenu {
                    id: sideMenu
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        margins: 8
                    }

                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    Layout.rightMargin: 10
                    labelsList: root.labelsList

                    onUnsavedChanges: root.unsavedChanges = true
                    onUpdateLabels: root.updateLabels()
                    onRenameLabel: {
                        if(all) {
                            saveImage()
                            Backend.renameLabel(root.annotationsDir,
                                                root.labelsList[labelIndex].name,
                                                newName)
                            nextImage(0)
                        } else {
                            if(root.labelExists(newName)) {
                                var idx = addLabel(newName)

                                for(var i in imageArea.rects) {
                                    var rect = imageArea.rects[i]
                                    if(rect.label == labelIndex)
                                        rect.label = idx
                                }

                                deleteLabel(labelIndex)
                            } else {
                                root.labelsList[labelIndex].name = newName
                                updateLabels()
                            }

                            unsavedChanges()
                        }
                    }
                }
            }

        } // RowLayout

        Keys.onEscapePressed: {
            imageArea.isSelection = false
        }

        Keys.onTabPressed: {
            imageArea.shiftRects()
            imageArea.updateRects()
        }
    } // mainItem


    function labelExists(label) {
        for(var i in labelsList) {
            if(label == labelsList[i].name)
                return true
        }
        return false
    }


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
