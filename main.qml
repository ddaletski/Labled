import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "qml"


ApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Lable")

    property string inputDir: ""
    property string outputDir: ""
    property var images
    property url currentImage

    signal sigSaveLabels(var rects, string outdir)
    signal sigLoadImages(string indir, string outdir)

    function saveRects(rects) {
        sigSaveLabels(rects, outdir, currentImage)
        console.log(currentImage)
    }

    function loadImages() {
        sigLoadImages(inputDir, outputDir)
        console.log(inputDir)
    }

    function imagesLoaded(images) {
        root.images = images
    }

    function nextImage() {
        var pair = images.pop()
        currentImage = pair['img']
    }

    FileChooseDialog {
        id: indirDialog

        onAccepted: {
            mainItem.focus = true
            inputDir = fileUrl
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
            inputDir = fileUrl
            root.loadImages()
        }

        onRejected: {
            mainItem.focus = true
        }
    }

    LabelChooseDialog {
        id: labelDialog
        labelsList: [1, 2, 3, 4, 5, 6, 7, 8]

        onAccepted: {
            if(label != '') {
                imageArea.updateLabel(label)
                addLabel(label)
            }
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

            ColumnLayout {
                Layout.fillHeight: true

                Button {
                    id: inputDirButton
                    height: 15
                    width: 60
                    text: qsTr("Choose input dir")

                    onClicked: {
                        indirDialog.open()
                    }
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

                Layout.fillWidth: true
                Layout.fillHeight: true

                onRectAdded: {
                    labelDialog.open()
                    labelDialog.label = rect.label
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
                root.saveRects(imageArea.rects)
            }
        }

    } // mainItem

} // window
