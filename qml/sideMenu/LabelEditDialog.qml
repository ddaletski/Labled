import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import "../common"

DialogWindow {
    id: root

    property string text: ""
    property bool applyToAll: false
    property int label: -1

    content: ColumnLayout {
        id: col
        anchors.centerIn: parent

        GridLayout {
            id: grid
            columns: 2

            Label {
                text: qsTr("New value:")
            }

            TextField {
                id: inputField
                width: 200
                selectByMouse: true

                onTextChanged: root.text = text
                Connections {
                    target: root
                    onTextChanged: inputField.text = text
                }
            }

            Label {
                text: qsTr("Apply to all files: ")
            }

            CheckBox {
                id: applyAllBox
                checked: false
                onCheckedChanged: root.applyToAll = checked
                Connections {
                    target: root
                    onApplyToAllChanged: applyAllBox.checked = applyToAll
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Button {
                id: ok
                text: qsTr("Rename")
                onClicked: accept()
            }

            Button {
                id: cancel
                text: qsTr("Cancel")
                onClicked: reject()
            }
        }
    }
}
