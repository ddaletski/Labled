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


    /***************** signals ***************/

    signal sigNextImage(int step)
    signal sigLoadImages(url imagesDir, url labelsDir)
    signal sigSaveImage(var rects)


    /***************** slots ***************/

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
            root.sigLoadImages(root.inputDir, root.outputDir)
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
            root.sigLoadImages(root.inputDir, root.outputDir)
        }

        onRejected: {
            mainItem.focus = true
        }
    }


    LabelChooseDialog {
        id: labelDialog
        labelsList: root.labelsList

        onAccepted: {
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

            ColumnLayout {
                Layout.fillHeight: true

                Button {
                    id: inputDirButton
                    height: 15
                    width: 60
                    text: qsTr("Choose input dir")

                    onClicked: indirDialog.open()
                }

                Button {
                    id: outputDirButton
                    height: 15
                    width: 60

                    text: qsTr("Choose output dir")

                    onClicked: outdirDialog.open()
                }
            }

            ImageDraw {
                id: imageArea

                src: root.currentImage
                labelsList: root.labelsList

                Layout.fillWidth: true
                Layout.fillHeight: true
                rectBorderWidth: 2

                onRectAdded: {
                    labelDialog.open()
                    labelDialog.label = rect.label
                }

                onSrcChanged: {
                    console.log(src)
                }
            }

            LabelsMenu {
                id: labelsMenu
                width: 100
                Layout.fillHeight: true
                model: root.labelsList

                onSigChooseColor: {
                    colorDialog.chooseColor(labelIndex)
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
                    labelDialog.open()
                    labelDialog.label = imageArea.lastRect.label
                }
                break
            case Qt.Key_S:
                sigSaveImage(imageArea.rects)
                break
            case Qt.Key_D:
                sigNextImage(1)
                break
            case Qt.Key_A:
                sigNextImage(-1)
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
