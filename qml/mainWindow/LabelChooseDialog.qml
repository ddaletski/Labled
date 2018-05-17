import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import "../common"

DialogWindow {
    id: root
    property string label: ""
    property var labelsList: []
    property bool enableShortcuts: false

    content: ColumnLayout {
        id: col
        anchors.centerIn: parent
        spacing: 10

        Rectangle {
            id: listViewRect

            height: 300
            width: 200

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
                        font.pointSize: 12
                        text: "" + ((enableShortcuts && index < 9) ? (index+1) + ") " : "") + modelData.name
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
                if(enableShortcuts && event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                    var idx = event.key - Qt.Key_1
                    if(root.labelsList.length > idx) {
                        label = labelsList[idx].name
                    }
                }
            }

        }

        TextField { // new label field
            id: textInput
            Layout.fillWidth: true

            KeyNavigation.backtab: listViewRect
            focus: true

            placeholderText: "label"
            selectByMouse: true

            onTextChanged: root.label = text
            Connections {
                target: root
                onLabelChanged: textInput.text = label
            }
        }

        Row {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: 5

            Button {
                text: qsTr("Ok")
                onClicked: {
                    root.accept()
                }
            }
            Button {
                text: qsTr("Cancel")
                onClicked: {
                    root.reject()
                }

                KeyNavigation.tab: listViewRect
            }
        }

        Connections {
            target: root
            onVisibleChanged: {
                if(root.enableShortcuts)
                    listViewRect.focus = true
                else
                    textInput.focus = true
            }
        }
    }
}
