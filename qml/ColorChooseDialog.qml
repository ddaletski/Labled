import QtQuick 2.9
import QtQuick.Dialogs 1.2

ColorDialog {
    id: root

    property int labelIndex: -1

    function chooseColor(idx) {
        labelIndex = idx
        open()
    }
}
