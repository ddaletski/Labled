import QtQuick 2.9
import QtQuick.Dialogs 1.3

Dialog {
    id: root
    width: text.width + 10
    property int step: 0
    property string mode: "undo"

    standardButtons: StandardButton.Cancel | StandardButton.Ok

    Text {
        id: text
        anchors.centerIn: parent
        text: {
            var result = ""

            switch (mode) {
            case "undo":
                result = qsTr("Do you want to undo your changes?")
                break
            case "next":
                result = qsTr("Do you want to ignore unsaved changes and load next image?")
                break
            }

            result
        }
    }
}