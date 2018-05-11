import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: root
    property alias darkBoxes: boxesSwitch.checked
    property alias showLabels: showLabelsSwitch.checked

    ColumnLayout {
        anchors.fill: parent

        Switch {
            id: boxesSwitch
            text: qsTr("Dark boxes")
        }

        Switch {
            id: showLabelsSwitch
            text: qsTr("Show box label")
            checked: true
        }
    }
}
