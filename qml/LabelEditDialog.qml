import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

DialogWindow {
    property alias text: inputField.text
    property alias applyToAll: applyAllBox.checked
    property int label: -1

    _width: col.width + 10
    _height: col.height + 6

    ColumnLayout {
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
            }

            Label {
                text: qsTr("Apply to all files: ")
            }

            CheckBox {
                id: applyAllBox
                checked: false
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
