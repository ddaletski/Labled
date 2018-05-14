import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2


Dialog {
    id: root
    property url inputDir: ""
    property url outputDir: ""
    property url imgDir: ""
    property url labelsListFile: "labels.txt"
    property var formats: ["voc", "darknet"]
    property int destFormat: 1
    property int srcFormat: 0

    standardButtons: StandardButton.NoButton

    FileChooseDialog {
        id: indirDialog

        onAccepted: {
            root.inputDir = fileUrl
            mainItem.focus = true
            console.log(folder)
        }
    }

    FileChooseDialog {
        id: outdirDialog

        onAccepted: {
            root.outputDir = fileUrl
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: imgdirDialog

        onAccepted: {
            root.imgDir = fileUrl
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: labelFileDialog
        selectFolder: false

        onAccepted: {
            root.labelsListFile = fileUrl
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: labelFileSaveDialog
        selectFolder: false

        onAccepted: {
            mainItem.focus = true
            console.log("SAVE TO ", fileUrl)
        }
    }


    MessageDialog {
        id: completedDialog
        text: qsTr("Converted")
    }


    ColumnLayout {
        id: mainItem

        GridLayout {
            columns: 3

            Label {
                width: 100
                text: qsTr("Format: ")
            }

            Item {
                width: row.width
                height: row.height
                Row {
                    id: row
                    ComboBox {
                        model: formats
                        onCurrentIndexChanged: {
                            root.srcFormat = currentIndex
                        }
                    }

                    Label {
                        text: "  =>  "
                    }

                    ComboBox {
                        model: formats
                        onCurrentIndexChanged: {
                            root.destFormat = currentIndex
                        }
                    }
                }
            }

            Item{ width: 5; height: 5}

            Label {
                width: 100
                text: qsTr("Input dir: ")
            }

            TextField {
                id: inputDirField
                Layout.preferredWidth: 400
                text: root.inputDir
                selectByMouse: true
            }

            Image {
                width: height
                source: "/img/folder.svg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        indirDialog.setFolder(root.inputDir)
                        indirDialog.open()
                    }
                }
            }

            Label {
                width: 100
                text: qsTr("Output dir: ")
            }

            TextField {
                id: outputDirField
                Layout.preferredWidth: 400
                text: root.outputDir
                selectByMouse: true
            }

            Image {
                source: "/img/folder.svg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        outdirDialog.setFolder(root.inputDir)
                        outdirDialog.open()
                    }
                }
            }


            Label {
                width: 100
                text: qsTr("Darknet labels: ")
            }

            TextField {
                id: labelsListField
                Layout.preferredWidth: 400
                text: root.labelsListFile
                selectByMouse: true
            }

            Image {
                source: "/img/folder.svg"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        labelFileDialog.open()
                    }
                }
            }


            Label {
                width: 100
                text: qsTr("Images dir: ")
            }

            TextField {
                id: imgDirField
                enabled: root.srcFormat > root.destFormat
                Layout.preferredWidth: 400
                text: root.imgDir
                selectByMouse: true
            }

            Image {
                source: "/img/folder.svg"
                opacity: root.srcFormat > root.destFormat
                MouseArea {
                    enabled: root.srcFormat > root.destFormat
                    anchors.fill: parent
                    onClicked: {
                        imgdirDialog.setFolder(root.imgDir)
                        imgdirDialog.open()
                    }
                }
            }

        } // grid layout

        Item {width: 1; height: 10}

        RowLayout {
            anchors.right: parent.right

            ProgressBar {
                id: progressBar
                Layout.fillWidth: true
                minimumValue: 0
                maximumValue: 1
                value: 0

                Connections {
                    target: cropToolBackend
                    onProgressChanged: progressBar.value = progress
                }

                onValueChanged: {
                    if(value == 1) {
                        completedDialog.open()
                        value = 0
                    }
                }
            }

            Button {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                text: qsTr("Run")
                onClicked: {
                    convertToolBackend.darknetToVoc(root.inputDir, root.outputDir, root.imgDir, root.labelsListFile)
                }
            }
            Button {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                text: qsTr("Close")
                onClicked: {
                    root.rejected()
                    root.close()
                }
            }
        }
    } // column layout


}
