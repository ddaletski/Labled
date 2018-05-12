import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: root
    property alias darkBoxes: boxesSwitch.checked
    property alias showLabels: showLabelsSwitch.checked
    property alias labelsSize: labelsTextSizeSlider.value

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

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Labels size:")
            }

            Slider {
                id: labelsTextSizeSlider
                from: 8
                to: 64
                stepSize: 1
                value: (to + from) / 2
                Layout.fillWidth: true
            }
        }
    }
}
