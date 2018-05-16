import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

GridLayout {
    id: root

    property alias boxesFillMode: boxesSlider.value
    property alias showLabels: showLabelsSwitch.checked
    property alias labelsSize: labelsTextSizeSlider.value
    property alias enableLabelsShortcuts: enableLabelsShotcutsSwitch.checked

    columns: 2

    Label {
        text: qsTr("Label choice shortcuts:")
    }
    Switch {
        id: enableLabelsShotcutsSwitch
        checked: false
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    }


    Label {
        text: qsTr("Fill mode:")
    }
    Slider {
        id: boxesSlider
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.preferredWidth: showLabelsSwitch.width
        value: 2
        minimumValue: 0
        maximumValue: 2
        stepSize: 1
    }

    Label {
        text: qsTr("Show box label:")
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
        Layout.preferredWidth: showLabelsSwitch.width

        minimumValue: 8
        maximumValue: 64
        stepSize: 1
        value: 0.75 * minimumValue + 0.25 * maximumValue
    }
}
