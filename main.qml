import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "qml"

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Lable")

    FileDialog {
        id: fileDialog
        visible: false
        title: "Please choose a file"
        folder: shortcuts.home

        onAccepted: {
            imageArea.src = fileDialog.fileUrls[0]
            visible = false
            mainItem.focus = true
        }
        onRejected: {
            visible = false
            mainItem.focus = true
        }
    }


    Dialog {
        contentItem: Rectangle {
            color: "red"
            width: 300
            height: 300
        }
    }


    Item {
        id: mainItem
        anchors.fill: parent
        focus: true

        Column {
            anchors.fill: parent

            Button {
                id: buttons
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 30
                text: qsTr("Open image")

                onClicked: {
                    fileDialog.visible = true
                }
            }

            ImageDraw {
                id: imageArea
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: parent.height - buttons.height

                onRectAdded: {
                    rect.label = 'label'
                    updateRects()
                }
            }
        }

        Keys.onSpacePressed: {
            imageArea.isSelection = 1 - imageArea.isSelection
        }
    }
}
