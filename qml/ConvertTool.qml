import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2


Dialog {
    id: root
    property url inputDir: ""
    property url outputDir: ""
    property string destFormat: "darknet"
    property string srcFormat: "voc"

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
                text: qsTr("Pattern:")
            }

            TextField {
                id: patternField
                Layout.preferredWidth: 400
                placeholderText: {
                    switch(destFormat) {
                    case "voc":
                        return "{name}.txt"
                    case "darknet":
                        return "{name}.xml"
                    }
                }
                text: placeholderText
                selectByMouse: true
            }

            Image {
                source: "/img/backspace.svg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        patternField.text = patternField.placeholderText
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
