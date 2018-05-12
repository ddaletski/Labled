import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2


Item {
    id: root
    property alias model: labelsList.model
    property int defaultLabel: -1
    signal sigChangeColor(int labelIndex, color newColor)
    signal sigDeleteLabel(int labelIndex)


    ColorChooseDialog {
        id: colorDialog

        onAccepted: {
            if(label >= 0) {
                sigChangeColor(label, color)
                label = -1
            }
        }

        onRejected: {
            label = -1
        }
    }


    ColumnLayout {
        anchors.fill: parent

//        Label {
//            id: defaultLabelTitle
//            text: qsTr("Default label:")
//            Layout.fillWidth: true
//        }
//
//        TextField {
//            id: defaultLabelInput
//            placeholderText: "label"
//            Layout.fillWidth: true
//        }

        Label {
            id: menuTitle
            text: qsTr("All labels:")
            Layout.fillWidth: true
        }

        ListView {
            id: labelsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            orientation: ListView.Vertical
            spacing: 10

            delegate: Rectangle {
                width: root.width
                height: txt.height + 10
                border.color: modelData.color
                Text {
                    id: txt
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                        rightMargin: 10 + height
                    }
                    text: modelData.name
                }

                Image {
                    id: deleteLabel
                    anchors {
                        right: parent.right
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }
                    height: txt.height
                    width: height
                    source: "/img/garbage_can.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.sigDeleteLabel(index)
                    }
                }

                MouseArea {
                    anchors.fill: txt
                    onClicked: {
                        colorDialog.label = index
                        colorDialog.open()
                    }
                }
            }
        }
    }
}
