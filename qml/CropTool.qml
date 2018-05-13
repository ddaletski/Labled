import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2


Dialog {
    id: root
    property url inputDir: ""
    property url annotationsDir: ""
    property url outputDir: ""

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
        id: annotationsdirDialog

        onAccepted: {
            root.annotationsDir = fileUrl
            mainItem.focus = true
        }
    }

    FileChooseDialog {
        id: outdirDialog

        onAccepted: {
            root.outputDir = fileUrl
            mainItem.focus = true
        }
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
                text: qsTr("Annotations dir: ")
            }

            TextField {
                id: annotationsDirField
                Layout.preferredWidth: 400
                text: root.annotationsDir
                selectByMouse: true
            }

            Image {
                source: "/img/folder.svg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        annotationsdirDialog.setFolder(root.annotationsDir)
                        annotationsdirDialog.open()
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
                placeholderText: "{name}__{label}_{index}.{ext}"
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
            Button {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                text: qsTr("Run")
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

    Component.onCompleted: {
        console.log(contentItem)
    }
}
