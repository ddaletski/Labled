import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.3

Dialog {
    id: root
    property alias label: textInput.text
    property var labelsList: []

    standardButtons: StandardButton.Cancel | StandardButton.Ok

    ColumnLayout {
        id: col
        width: 300

        Rectangle {
            id: listViewRect

            height: 300
            Layout.fillWidth: true
            visible: root.labelsList.length

            color: "transparent"
            border.color: activeFocus ? "red" : "transparent"

            KeyNavigation.tab: textInput

            ListView {
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

                    Text {
                        anchors.fill: parent
                        text: "" + (index < 9 ? (index+1) + ": " : "") + modelData
                    }
                }
            }

            Keys.onPressed: {
                if(event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                    var idx = event.key - Qt.Key_1
                    if(root.labelsList.length > idx) {
                        label = labelsList[idx]
                    }
                }
            }

        }

        Item {
            height: 20
            visible: root.labelsList.length
        }

        TextField {
            id: textInput
            Layout.fillWidth: true

            KeyNavigation.backtab: listViewRect

            placeholderText: "label"
        }
    }

    onVisibleChanged: {
        listViewRect.focus = true
    }

    function addLabel(label) {
        for(var i in labelsList) {
            if(label === labelsList[i])
                return
        }
        labelsList.push(label)
        updateLabels()
    }

    function updateLabels() {
        labelsList = labelsList
    }
}
