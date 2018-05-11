import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2


Item {
    id: root
    property alias model: labelsList.model
    signal sigChooseColor(int labelIndex)
    signal sigDeleteLabel(int labelIndex)

    ColumnLayout {
        anchors.fill: parent

        Label {
            id: menuTitle
            text: qsTr("Labels:")
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
                height: txt.height
                border.color: modelData.color
                Text {
                    id: txt
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10 + height
                    }
                    text: modelData.name
                }

                Image {
                    id: deleteLabel
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
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
                        root.sigChooseColor(index)
                    }
                }
            }
        }
    }
}
