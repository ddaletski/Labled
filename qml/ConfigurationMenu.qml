import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Item {
    id: root
    property alias darkBoxes: boxesSwitch.checked
    property alias showLabels: showLabelsSwitch.checked
    property alias labelsSize: labelsTextSizeSlider.value
    property alias enableLabelsShortcuts: enableLabelsShotcutsSwitch.checked

    GridLayout {
        anchors.fill: parent
        columns: 2

        Label {
            text: qsTr("Enable label choice shortcuts")
        }
        Switch {
            id: enableLabelsShotcutsSwitch
            checked: false
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        }


        Label {
            text: qsTr("Dark boxes")
        }
        Switch {
            id: boxesSwitch
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        }

        Label {
            text: qsTr("Show box label")
        }

        Switch {
            id: showLabelsSwitch
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            checked: true
        }

        Label {
            text: qsTr("Labels size:")
        }

        Slider {
            id: labelsTextSizeSlider
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            minimumValue: 8
            maximumValue: 64
            stepSize: 1
            value: 0.75 * minimumValue + 0.25 * maximumValue
            Layout.fillWidth: true
        }
    }
}
