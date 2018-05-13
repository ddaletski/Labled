import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.3

Dialog {
    id: root
    property alias label: textInput.text
    property var labelsList: []
    width: 200

    standardButtons: StandardButton.Cancel | StandardButton.Ok

    ColumnLayout {
        id: col
        width: parent.width

        Rectangle {
            id: listViewRect

            height: 300
            Layout.fillWidth: true
            visible: root.labelsList.length

            color: Qt.rgba(10, 10, 10, 0.1)
            border.color: activeFocus ? "red" : "transparent"

            KeyNavigation.tab: textInput

            ListView { // list of labels to choose

                id: labelsListView
                anchors {
                    fill: parent
                    margins: 2
                }

                orientation: ListView.Vertical

                model: root.labelsList

                delegate: Rectangle {
                    width: labelsListView.width
                    height: 30
                    color: "transparent"
                    border.color: Qt.rgba(0, 0, 0, 0.1)

                    Label {
                        id: lbl
                        anchors {
                            left: parent.left
                            right: parent.right
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        font.pixelSize: 12
                        text: "" + (index < 9 ? (index+1) + ") " : "") + modelData.name
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.label = labelsList[index].name
                        }
                    }
                }
            }

            Keys.onPressed: { // quick choice shortcuts
                if(event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                    var idx = event.key - Qt.Key_1
                    if(root.labelsList.length > idx) {
                        label = labelsList[idx].name
                    }
                }
            }

        }

        Item {
            height: 20
            Layout.fillWidth: true
            visible: root.labelsList.length
        }

        TextField { // new label field
            id: textInput
            Layout.fillWidth: true
            KeyNavigation.backtab: listViewRect
            placeholderText: "label"
            selectByMouse: true
        }
    }

    onVisibleChanged: {
        listViewRect.focus = true
    }
}
