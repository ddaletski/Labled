import QtQuick 2.5
import QtQuick.Dialogs 1.2

MessageDialog{
    id: root
    width: text.width + 10
    property int step: 0
    property string mode: "undo"

    standardButtons: StandardButton.Cancel | StandardButton.Ok

    text: {
        var result = ""

        switch (mode) {
        case "undo":
            result = qsTr("Do you want to reset unsaved changes?")
            break
        case "next":
            result = qsTr("Do you want to ignore unsaved changes and load next image?")
            break
        }

        result
    }
}
