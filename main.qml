import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "qml"


ApplicationWindow {
    id: root
    visible: true
    width: 1024
    height: 720
    title: qsTr("Lable")

    property string inputDir: ""
    property string outputDir: ""
    property var labelsList: []
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
            savedRects.push (
                {
                    x: r.origX,
                    y: r.origY,
                    width: r.origWidth,
                    height: r.origHeight,
                    label: labelsList[r.label].name
                }
            )
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
            imageArea.rects.push( imageArea.rectItem(box.x * xs, box.y * ys, box.width * xs, box.height * ys, addLabel(box.label)) )
        }

        imageArea.updateRects()
    }

    ///////////////////////////////////////////


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
            console.log(label)
            if(label != '') {
                var labelIdx = addLabel(label)
                imageArea.updateLabel(labelIdx)
            }
            mainItem.focus = true
        }

        onRejected: {
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


    ColorChooseDialog {
        id: colorDialog

        onAccepted: {
            if(labelIndex >= 0) {
                labelsList[labelIndex].color = color
            }
            root.updateLabels()
        }

        onRejected: {
            labelIndex = -1
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

                darkBoxes: configMenu.darkBoxes
                showLabels: configMenu.showLabels

                Layout.fillWidth: true
                Layout.fillHeight: true
                rectBorderWidth: 2

                onRectAdded: {
                    labelDialog.label = ""
                    labelDialog.open()
                }

                onUnsavedChanges: {
                    root.unsavedChanges = true
                }
            }

            ColumnLayout {
                width: 150

                Button {
                    id: inputDirButton
                    height: 15
                    width: parent.width

                    text: qsTr("Choose input dir")

                    onClicked: indirDialog.open()
                }

                Button {
                    id: outputDirButton
                    height: 15
                    width: parent.width

                    text: qsTr("Choose output dir")

                    onClicked: outdirDialog.open()
                }

                LabelsMenu {
                    id: labelsMenu
                    width: parent.width
                    Layout.fillHeight: true
                    Layout.preferredHeight: 3
                    model: root.labelsList

                    onSigChooseColor: {
                        colorDialog.chooseColor(labelIndex)
                    }

//                    onSigDeleteLabel: {
//                        var end = imageArea.rects.length
//                        for(var i = 0; i < end; ) {
//                            if (imageArea.rects[i].label == labelIndex ) {
//                                imageArea[i] = imageArea.rects[end-1]
//                                imageArea.rects.pop()
//                                end = imageArea.rects.length
//                            } else {
//                                ++i
//                            }
//
//                        }
//                        imageArea.updateRects()
//
//                        root.labelsList[labelIndex] = root.labelsList[root.labelsList.length-1]
//                        root.labelsList.pop()
//                        root.updateLabels()
//
//                        root.unsavedChanges = true
//                    }

                }

                ConfigurationMenu {
                    id: configMenu
                    width: parent.width
                    Layout.fillHeight: true
                    Layout.preferredHeight: 1
                }
            }
        } // RowLayout

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

} // window
