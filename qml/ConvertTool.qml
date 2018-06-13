import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import "common"

Dialog {
    id: root
    property alias inputDir: inputDirField.text
    property alias outputDir: outputDirField.text
    property alias imgDir: imgDirField.text
    property alias labelsListFile: labelsListField.text
    property var inp_formats: ["voc", "darknet"]
    property var out_formats: ["voc", "darknet"]
    property int destFormat: 1
    property int srcFormat: 0

    Connections {
        target: ConvertToolBackend
        onProgressChanged: progressBar.value = progress
        onConvertedDarknetToVoc: {
            progressBar.value = 0
            completedDialog.open()
        }
        onConvertedVocToDarknet: {
            progressBar.value = 0
            completedDialog.open()
        }
    }


    FileChooseDialog {
        id: indirDialog

        onAccepted: {
            root.inputDir = filePath()
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: outdirDialog

        onAccepted: {
            root.outputDir = filePath()
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: imgdirDialog

        onAccepted: {
            root.imgDir = filePath()
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: labelFileDialog
        selectFolder: false

        onAccepted: {
            root.labelsListFile = filePath()
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: labelFileSaveDialog
        selectFolder: false

        onAccepted: {
            mainItem.focus = true
            console.log("SAVE TO ", filePath())
        }
    }


    MessageDialog {
        id: completedDialog
        text: qsTr("Converted")
    }


    ColumnLayout {
        id: mainItem
        anchors.centerIn: parent

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
                        id: comboBoxInput
                        model: inp_formats
                        onCurrentIndexChanged: {
                            root.srcFormat = currentIndex
                        }
                    }

                    Label {
                        text: "  =>  "
                    }

                    ComboBox {
                        id: comboBoxOutput
                        model: out_formats.filter(function(x) { return x != comboBoxInput.currentText })
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
            Layout.alignment: Qt.AlignRight

            ProgressBar {
                id: progressBar
                Layout.fillWidth: true
                minimumValue: 0
                maximumValue: 1
                value: 0
            }

            Button {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                text: qsTr("Run")
                onClicked: {
                    if(root.srcFormat == 1 && root.destFormat == 0)
                        ConvertToolBackend.darknetToVoc(root.inputDir, root.outputDir, root.imgDir, root.labelsListFile)
                    else
                        ConvertToolBackend.vocToDarknet(root.inputDir, root.outputDir, root.labelsListFile)
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
